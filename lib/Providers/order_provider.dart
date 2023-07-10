import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:flutter/foundation.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/employee_model.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../PostresqlConnection/postqresql_connection_manager.dart';
import '../config.dart';
import '../services/PostgreApi.dart';
import '../services/one_signal_api.dart';

class FullOrder {
  final Order order;
  final People person;
  final List<Employee> employees;

  FullOrder(this.order, this.person, this.employees);
}

class OrderProvider extends ChangeNotifier {
  bool isLoading = true;
  List<Order> _orders = [];

  Future<void> fetchOpenOrders() async {
    // Fetch orders from your database
    final List<Order> fetchedOrders = []; // Result from your database

    _orders = fetchedOrders
        .where((order) =>
            order.isPaid == false && order.paidAmount < order.totalAmount)
        .toList();
    notifyListeners();
  }

  List<Order> get orders => _orders;

  List<Order> get openOrders =>
      List.of(_orders.where((o) => o.orderStatus != 'Archived'));

  // Define the filterOrderedItems method
  List<OrderedItem> getFilteredOrderedItems(String itemSource) {
    // Assuming that your Order object has an 'itemSource' property
    return openOrders
        .expand((order) => order.orderedItems)
        .where((item) => item.itemSource
            .toLowerCase()
            .trim()
            .contains(itemSource.toLowerCase().trim()))
        .toList();
  }

  Future<void> fetchOrders() async {
    try {
      if (AppConfig.ENABLE_WOOSIGNAL) {
        // _orders = await WooSignalService.getOrders();
      } else {
        _orders = await PostgresOrdersAPI.getOrders();
        for (var o in _orders) {
          o.orderedItems =
              await PostgresOrderedItemAPI.getOrderedItemsForOrder(o.id);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Order?> getOrderByIdFromDB(String id) async {
    Order? result = await PostgresOrdersAPI.getOrderById(id);
    return result;
  }

  Future<void> createOrder(Order newOrder, People customer) async {
    if (AppConfig.ENABLE_WOOSIGNAL) {
      var result = await WooSignalService.createOrder(
          newOrder, newOrder.orderedItems, customer.wooSignalId);
      print(result);
    } else {
      await PostgresOrdersAPI.createOrder(newOrder, newOrder.orderedItems);
    }

    var customerFullName = "${customer.firstName} ${customer.lastName}";
    var payload = "New order from: $customerFullName";
    _sendPushNotification(payload);
  }

  Future<bool> updateOrder(Order updatedOrder,
      {WSOrderStatus status = WSOrderStatus.Processing,
      List<OrderedItem> newItems = const []}) async {
    var result = false;
    if (AppConfig.ENABLE_WOOSIGNAL) {
      result =
          await WooSignalService.updateOrder(updatedOrder, status, newItems);
    } else {
      result = await PostgresOrdersAPI.updateOrder(updatedOrder);
    }
    fetchOrders();
    return result;
  }

  //TODO: if order deleted from one device should refresh orders on others devices
  void deleteOrder(Order order) async {
    if (AppConfig.ENABLE_WOOSIGNAL) {
      await WooSignalService.deleteOrder(order.wooSignalId ?? 0); //TODO:FIX
    } else {
      await PostgresOrdersAPI.deleteOrder(order.id);
    }
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void addOrderedItemToOrderForUpdateUI(
      String orderId, OrderedItem orderedItem) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderedItems.add(orderedItem);
    notifyListeners();
  }

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

// import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
// import 'package:flutter/foundation.dart';
//
// import '../Contacts/people_db_manager.dart';
// import '../Models/employee_model.dart';
// import '../Models/order_model.dart';
// import '../Models/ordered_item_model.dart';
// import '../Models/people_model.dart';
// import '../PostresqlConnection/postqresql_connection_manager.dart';
// import '../config.dart';
// import '../services/PostgreApi.dart';
// import '../services/one_signal_api.dart';
//
// class FullOrder {
//   final Order order;
//   final People person;
//   final List<Employee> employees;
//
//   FullOrder(this.order, this.person, this.employees);
// }
//
// class OrderProvider extends ChangeNotifier {
//   bool isLoading = true;
//   List<Order> _orders = [];
//
//   Future<void> fetchOpenOrders() async {
//     // Fetch orders from your database
//     final List<Order> fetchedOrders = []; // Result from your database
//
//     _orders = fetchedOrders
//         .where((order) => order.paidAmount < order.totalAmount)
//         .toList();
//     notifyListeners();
//   }
//
//   List<Order> get orders => _orders;
//
//   // Define the filterOrderedItems method
//   List<OrderedItem> getFilteredOrderedItems(String itemSource) {
//     // Assuming that your Order object has an 'itemSource' property
//     return _orders
//         .expand((order) => order.orderedItems)
//         .where((item) => item.itemSource == itemSource)
//         .toList();
//   }
//
//   Future<void> fetchOrders() async {
//     try {
//       if (AppConfig.ENABLE_WOOSIGNAL) {
//         // _orders = await WooSignalService.getOrders();
//       } else {
//         _orders = await PostgresOrdersAPI.getOrders();
//         for (var o in _orders) {
//           o.orderedItems =
//               await PostgresOrderedItemAPI.getOrderedItemsForOrder(o.id);
//         }
//       }
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching orders: $e');
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//
//   Future<Order?> getOrderByIdFromDB(String id) async {
//     Order? result = await PostgresOrdersAPI.getOrderById(id);
//     return result;
//   }
//
//   Future<void> createOrder(Order newOrder, People customer) async {
//     if (AppConfig.ENABLE_WOOSIGNAL) {
//       var result = await WooSignalService.createOrder(
//           newOrder, newOrder.orderedItems, customer.wooSignalId);
//       print(result);
//     } else {
//       await PostgresOrdersAPI.createOrder(newOrder, newOrder.orderedItems);
//     }
//
//     var customerFullName = "${customer.firstName} ${customer.lastName}";
//     var payload = "New order from: $customerFullName";
//     _sendPushNotification(payload);
//   }
//
//   Future<bool> updateOrder(Order updatedOrder,
//       {WSOrderStatus status = WSOrderStatus.Processing,
//       List<OrderedItem> newItems = const []}) async {
//     var result = false;
//     if (AppConfig.ENABLE_WOOSIGNAL) {
//       result =
//           await WooSignalService.updateOrder(updatedOrder, status, newItems);
//     } else {
//       result = await PostgresOrdersAPI.updateOrder(updatedOrder);
//     }
//     fetchOrders();
//     return result;
//   }
//
//   //TODO: if order deleted from one device should refresh orders on others devices
//   void deleteOrder(Order order) async {
//     if (AppConfig.ENABLE_WOOSIGNAL) {
//       await WooSignalService.deleteOrder(order.wooSignalId ?? 0); //TODO:FIX
//     } else {
//       await PostgresOrdersAPI.deleteOrder(order.id);
//     }
//     _orders.removeWhere((o) => o.id == order.id);
//     notifyListeners();
//   }
//
//   void addOrderedItemToOrderForUpdateUI(
//       String orderId, OrderedItem orderedItem) {
//     final order = _orders.firstWhere((order) => order.id == orderId);
//     order.orderedItems.add(orderedItem);
//     notifyListeners();
//   }
//
//   // void deleteOrderedItem(int orderId, OrderedItem item) {
//   //   final order = _orders.firstWhere((order) => order.id == orderId);
//   //   order.orderedItems.removeWhere((i) => i.id == item.id);
//   //   notifyListeners();
//   // }
//
//   Future<List<Employee>> fetchEmployeesByOrderId(String orderId) async {
//     final connection = PostgreSQLConnectionManager.connection;
//
//     final query = '''
//     SELECT *
//     FROM tasks
//     WHERE order_id = @orderId;
//   ''';
//
//     final results = await connection
//         .mappedResultsQuery(query, substitutionValues: {'orderId': orderId});
//
//     List<Employee> employees = [];
//
//     for (final row in results) {
//       final employeeQuery = '''
//       SELECT *
//       FROM employee
//       WHERE id = @employeeId;
//     ''';
//
//       final employeeResults = await connection.mappedResultsQuery(employeeQuery,
//           substitutionValues: {'employeeId': row['tasks']?['employee_id']});
//
//       if (employeeResults.isNotEmpty) {
//         final employeeMap = employeeResults.first['employees'];
//         final employee = Employee.fromMap(employeeMap!);
//         employees.add(employee);
//       }
//     }
//
//     return employees;
//   }
//
//   Future<List<FullOrder>> getFullOrders() async {
//     if (_orders.isEmpty) {
//       await fetchOrders();
//     }
//
//     Set<People> customers = {};
//     List<FullOrder> full = [];
//     for (final o in _orders) {
//       if (customers.where((c) => c.id.toString() == o.customerId).isEmpty) {
//         final customer = await fetchCustomerById(o.customerId);
//         customers.add(customer);
//       }
//
//       final employees = await fetchEmployeesByOrderId(o.id);
//
//       full.add(FullOrder(
//           o,
//           customers.firstWhere((c) => c.id.toString() == o.customerId),
//           employees));
//     }
//
//     return full;
//   }
//
//   Future<People> fetchCustomerById(String id) async {
//     People? customer = await PeoplePostgres.fetchCustomer(id);
//
//     if (customer == null) {
//       throw Exception('No customer data found with ID: $id');
//     }
//
//     return customer;
//   }
//
//   Future<void> _sendPushNotification(String payload) async {
//     await OneSignalAPI.sendNotification(payload);
//   }
// }
