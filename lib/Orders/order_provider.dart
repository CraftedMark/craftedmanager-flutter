import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:flutter/foundation.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/employee_model.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../Orders/orders_db_manager.dart';
import '../ProductionList/production_list_db_manager.dart';

class FullOrder {
  final Order order;
  final People person;
  final List<Employee> employees;

  FullOrder(this.order, this.person, this.employees);
}

class OrderProvider with ChangeNotifier {
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

  Order getOrderedItemsForOrder(String orderId) {
    return _orders.firstWhere((order) => order.id == orderId);
  }

  Future<void> fetchOrders() async {
    try {
      _orders =
          await ProductionListDbManager.getOpenOrdersWithAllOrderedItems();
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<bool> updateOrder(
      Order updatedOrder, List<OrderedItem> updatedOrderedItems) async {
    // Find the index of the order in the list
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);

    // Check if the order exists in the list
    if (index != -1) {
      // Update the order in the list
      _orders[index] = updatedOrder;
      print(updatedOrderedItems.first.flavor);
      // Update the order in the database
      final result =
          await OrderPostgres.updateOrder(updatedOrder, updatedOrderedItems);

      // If the update was successful, notify listeners
      if (result) {
        notifyListeners();
      }

      return result;
    }

    return false;
  }

  void deleteOrder(Order order) {
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void addOrderedItem(String orderId, OrderedItem orderedItem) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderedItems.add(orderedItem);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus, bool isArchived) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderStatus = newStatus;
    if (isArchived) {
      order.isArchived = true;
    }
    notifyListeners();
  }

  Future<List<Employee>> fetchEmployeesByOrderId(String orderId) async {
    final connection = await PostgreSQLConnectionManager.connection;

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
    People? customer = await PeoplePostgres.fetchCustomer(int.parse(id));

    if (customer == null) {
      throw Exception('No customer data found with ID: $id');
    }

    return customer;
  }
}
