import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:flutter/foundation.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/employee_model.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../Orders/orders_db_manager.dart';
import '../PostresqlConnection/postqresql_connection_manager.dart';
import '../ProductionList/production_list_db_manager.dart';
import '../config.dart';
import '../services/one_signal_api.dart';

class FullOrder {
  final Order order;
  final People person;
  final List<Employee> employees;

  FullOrder(this.order, this.person, this.employees);
}

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  List<OrderedItem> _filteredItems = [];

  List<Order> get orders => _orders;

  // Define the filteredItems getter
  List<OrderedItem> get filteredItems => _filteredItems;

  // Define the filterOrderedItems method
  void filterOrderedItems(String itemSource) {
    // Assuming that your Order object has an 'itemSource' property
    _filteredItems = _orders
        .expand((order) => order.orderedItems)
        .where((item) => item.itemSource == itemSource)
        .toList();
    notifyListeners();
  }

  Future<List<OrderedItem>> getOrderedItemsForOrder(String orderId) async {
      final connection = PostgreSQLConnectionManager.connection;

      var items = <OrderedItem>[];
      await connection.transaction((ctx) async {
        final result = await ctx.query('''
        SELECT * FROM ordered_items WHERE order_id = @order_id
      ''', substitutionValues: {"order_id":orderId});

        items = result.map((item)=>OrderedItem.fromMap(item.toColumnMap())).toList();
      });
      return items;
  }

  Future<void> fetchOrders() async {
    try {
      if(AppConfig.ENABLE_WOOSIGNAL){
        // _orders = await WooSignalService.getOrders();
      }else{
        _orders =
        await ProductionListDbManager.getOpenOrdersWithAllOrderedItems();
        for(var o in _orders){
          o.orderedItems = await getOrderedItemsForOrder(o.id);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> createOrder(Order newOrder, People customer) async {

    if(AppConfig.ENABLE_WOOSIGNAL){
      var result = await WooSignalService.createOrder(newOrder, newOrder.orderedItems);
      print(result);
    }else{
      await OrderPostgres().createOrder(newOrder, newOrder.orderedItems);
    }

    var customerFullName = "${customer.firstName} ${customer.lastName}";
    var payload = "New order from: $customerFullName";
    _sendPushNotification(payload);
  }

  Future<bool> updateOrder(
      Order updatedOrder, {
        WSOrderStatus status = WSOrderStatus.Processing,
        List<OrderedItem> newItems = const []}
      ) async {

    var result = false;
    if(AppConfig.ENABLE_WOOSIGNAL){
      result = await WooSignalService.updateOrder(updatedOrder, status, newItems);
    }else{
      result = await OrderPostgres.updateOrder(updatedOrder);
    }
    fetchOrders();
    return result;
  }

  void deleteOrder(Order order) {
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void addOrderedItem(String orderId, OrderedItem orderedItem) {
    print('try to add ${orderedItem.name}');
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderedItems.add(orderedItem);
    notifyListeners();
  }

  // void deleteOrderedItem(int orderId, OrderedItem item) {
  //   final order = _orders.firstWhere((order) => order.id == orderId);
  //   order.orderedItems.removeWhere((i) => i.id == item.id);
  //   notifyListeners();
  // }


  Future<List<Employee>> fetchEmployeesByOrderId(String orderId) async {
    final connection = PostgreSQLConnectionManager.connection;

    final query = '''
    SELECT * 
    FROM tasks 
    WHERE order_id = @orderId;
  ''';

    final results = await connection
        .mappedResultsQuery(query, substitutionValues: {'orderId': orderId});

    List<Employee> employees = [];

    for (final row in results) {
      final employeeQuery = '''
      SELECT * 
      FROM employee 
      WHERE id = @employeeId;
    ''';

      final employeeResults = await connection.mappedResultsQuery(employeeQuery,
          substitutionValues: {'employeeId': row['tasks']?['employee_id']});

      if (employeeResults.isNotEmpty) {
        final employeeMap = employeeResults.first['employees'];
        final employee = Employee.fromMap(employeeMap!);
        employees.add(employee);
      }
    }

    return employees;
  }

  Future<List<FullOrder>> getFullOrders() async {
    if (_orders.isEmpty) {
      await fetchOrders();
    }

    Set<People> customers = {};
    List<FullOrder> full = [];
    for (final o in _orders) {
      if (customers.where((c) => c.id.toString() == o.customerId).isEmpty) {
        final customer = await fetchCustomerById(o.customerId);
        customers.add(customer);
      }

      final employees = await fetchEmployeesByOrderId(o.id);

      full.add(FullOrder(
          o,
          customers.firstWhere((c) => c.id.toString() == o.customerId),
          employees));
    }

    return full;
  }

  Future<People> fetchCustomerById(String id) async {
    People? customer = await PeoplePostgres.fetchCustomer(id);

    if (customer == null) {
      throw Exception('No customer data found with ID: $id');
    }

    return customer;
  }

  Future<void> _sendPushNotification(String payload) async {
    await OneSignalAPI.sendNotification(payload);
  }



}