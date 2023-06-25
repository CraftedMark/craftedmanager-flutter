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
  bool _isLoading = true;

  List<Order> get orders => _orders;

  bool get isLoading => _isLoading;

  List<OrderedItem> get filteredItems => _filteredItems;

  void addOrderedItem(String orderId, OrderedItem item) {
    // Find the order by id
    int orderIndex = _orders.indexWhere((o) => o.id == orderId);

    if (orderIndex != -1) {
      // Add the item to the order
      _orders[orderIndex].orderedItems.add(item);

      // Notify listeners to update UI
      notifyListeners();
    } else {
      print('Order not found: $orderId');
    }
  }

  void filterOrderedItems(String itemSource) {
    _filteredItems = _orders
        .expand((order) => order.orderedItems)
        .where((item) => item.itemSource == itemSource)
        .toList();
    notifyListeners();
  }

  Future<bool> createOrder(Order order, List<OrderedItem> orderedItems) async {
    bool result = await OrderPostgres().createOrder(order, orderedItems);
    if (result) {
      _orders.add(order);
      notifyListeners();
    }
    return result;
  }

  Future<bool> updateOrder(
      Order updatedOrder, List<OrderedItem> updatedOrderedItems) async {
    bool result =
        await OrderPostgres.updateOrder(updatedOrder, updatedOrderedItems);
    if (result) {
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      _orders[index] = updatedOrder;
      notifyListeners();
    }
    return result;
  }

  Future<void> deleteOrder(Order order) async {
    await OrderPostgres.deleteOrder(order.id);
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  Future<Order?> searchOrderById(String id) async {
    Order? result = await OrderPostgres.getOrderById(id);
    return result;
  }

  Future<List<Order>> fetchOrders() async {
    if (_orders.isEmpty) {
      _orders =
          await ProductionListDbManager.getOpenOrdersWithAllOrderedItems();
    }
    return _orders;
  }

  void updateOrderStatus(String orderId, String newStatus, bool isArchived) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderStatus = newStatus;
    if (isArchived) {
      order.isArchived = true;
    }
    notifyListeners();
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
}

Future<bool> createOrder(Order order, List<OrderedItem> orderedItems) async {
  try {
    final connection = PostgreSQLConnectionManager.connection;

// insert order and orderedItems into database

    return true;
  } catch (e) {
    print('Error creating order: ${e.toString()}');
    return false;
  }
}

Future<List<Employee>> fetchEmployeesByOrderId(String orderId) async {
  List<Employee> employees = [];
  try {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query(
      'SELECT * FROM employees WHERE order_id = @orderId',
      substitutionValues: {
        'orderId': orderId,
      },
    );

    for (var row in result) {
      employees.add(Employee.fromMap(row.toColumnMap()));
    }
  } catch (e) {
    print('Error fetching employees by order id: ${e.toString()}');
  }
  return employees;
}
