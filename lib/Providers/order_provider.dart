import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/employee_model.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../PostresqlConnection/postqresql_connection_manager.dart';
import '../ProductionList/production_list_db_manager.dart';
import '../services/PostgreApi.dart';

class FullOrder {
  final Order order;
  final People person;
  final List<Employee> employees;

  FullOrder(this.order, this.person, this.employees);
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<OrderedItem> _orderedItems = []; // Added this line
  double _subTotal = 0.0; // Added this line
  List<OrderedItem> _filteredItems = [];
  bool _isLoading = true;

  List<Order> get orders => _orders;

  bool get isLoading => _isLoading;

  List<OrderedItem> get filteredItems => _filteredItems;

  void addOrderedItem(OrderedItem item) {
    _orderedItems.add(item);
    notifyListeners();
    print('_orderedItems: $_orderedItems');
  }

  void filterOrderedItems(String itemSource) {
    _filteredItems =
        _orderedItems.where((item) => item.itemSource == itemSource).toList();
    notifyListeners();
  }


  Future<bool> createOrder(Order order, List<OrderedItem> orderedItems) async {
    bool result = await createOrder(order, orderedItems);
    if (result) {
      _orders.add(order);
      notifyListeners();
    }
    return result;
  }

  Future<bool> updateOrder(
      Order updatedOrder, List<OrderedItem> updatedOrderedItems) async {
    bool result = await updateOrder(updatedOrder, updatedOrderedItems);
    if (result) {
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      _orders[index] = updatedOrder;

      // Fetch and update all orders
      _orders = await fetchOrders();

      notifyListeners();
    }
    return result;
  }

  Future<void> deleteOrder(Order order) async {
    await deleteOrder(order.id as Order);
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  Future<Order?> searchOrderById(String id) async {
    Order? result = await getOrderById(id);
    return result;
  }

  Future<List<Order>> fetchOrders() async {
    if (_orders.isEmpty) {
      _orders =
          await PostgresOrdersAPI.getOrders();
    }
    return _orders;
  }

  Future<List<OrderedItem>> fetchOrderedItems(String orderId) async {
    List<OrderedItem> orderedItems = [];
    try {
      final connection = PostgreSQLConnectionManager.connection;
      final result = await connection.query(
        'SELECT * FROM ordered_Items WHERE order_id = @orderId',
        substitutionValues: {
          'orderId': orderId,
        },
      );

      for (var row in result) {
        orderedItems.add(OrderedItem.fromMap(row.toColumnMap()));
      }
    } catch (e) {
      print('Error fetching ordered items by order id: ${e.toString()}');
    }
    return orderedItems;
  }

  Future<People> fetchCustomerById(String id) async {
    People? customer = await PeoplePostgres.fetchCustomer(id);

    if (customer == null) {
      throw Exception('No customer data found with ID: $id');
    }

    return customer;
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
}




Future<int?> getProductId(
    PostgreSQLExecutionContext ctx, String productName) async {
  List<Map<String, Map<String, dynamic>>> results =
      await ctx.mappedResultsQuery('''
    SELECT id FROM products WHERE name = @name
  ''', substitutionValues: {'name': productName});

  if (results.isNotEmpty) {
    return results.first['products']?['id'];
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> getAddressFields(
    PostgreSQLExecutionContext ctx, String customerId) async {
  List<Map<String, Map<String, dynamic>>> results =
      await ctx.mappedResultsQuery('''
SELECT address1, city, state, zip FROM people WHERE id = @customer_id
''', substitutionValues: {'customer_id': customerId});

  if (results.isNotEmpty) {
    return results.first['people'];
  } else {
    return null;
  }
}

Future<bool> updateOrderStatus(Order updatedOrder) async {
  try {
    final connection = PostgreSQLConnectionManager.connection;

    await connection.transaction((ctx) async {
      print('Updating order status with values: ${updatedOrder.toMap()}');
      // Update order in orders table
      await ctx.query('''
        UPDATE orders
        SET order_status = @orderStatus
        WHERE order_id = @order_id
      ''', substitutionValues: {
        'order_id': updatedOrder.id,
        'orderStatus': updatedOrder.orderStatus,
      });
      print('Order status updated');
    });

    return true;
  } catch (e) {
    print('Error: ${e.toString()}');
    return false;
  }
}

Future<bool> updateOrder(Order order, List<OrderedItem> orderedItems) async {
  try {
    final connection = PostgreSQLConnectionManager.connection;
    await connection.transaction((ctx) async {
      // Print the order details
      print('Order details: ${order.toMap()}');

      try {
        await ctx.query('''
  UPDATE orders
  SET people_id = @people_id, order_date = @order_date, shipping_address = @shipping_address, billing_address = @billing_address, total_amount = @total_amount, order_status = @order_status
  WHERE order_id = @order_id
''', substitutionValues: {
          ...order.toMap(),
          'people_id': order.customerId,
        });
        print('Order updated');
      } catch (e) {
        print('Error updating order: $e');
      }

      print('Deleting existing ordered items with orderId: ${order.id}');
      await ctx.query('''
      DELETE FROM ordered_items WHERE order_id = @orderId
    ''', substitutionValues: {
        'orderId': order.id,
      });
      print('Existing ordered items deleted');

      for (OrderedItem item in orderedItems) {
        print('Inserting updated ordered item with values: ${{
          ...item.toMap(),
          'orderId': order.id,
        }}');
        await ctx.query('''
INSERT INTO ordered_items 
(order_id, product_id, product_name, quantity, price, discount, description, item_source, flavor, dose, packaging)
VALUES (@orderId, @productId, @productName, @quantity, @price, @discount, @description, @itemSource, @flavor, @dose, @packaging)
''', substitutionValues: {
          ...item.toMap(),
          'orderId': order.id,
          'productId': item.productId,
          'productName': item.productName,
          'itemSource': item.itemSource,
          'flavor': item.flavor,
          'dose': item.dose,
          'packaging': item.packaging,
        });
        print('Updated ordered item inserted');
      }
    });

    return true;
  } catch (e) {
    print('Error: ${e.toString()}');
    return false;
  }
}

Future<Order?> getOrderById(String id) async {
  try {
    final connection = PostgreSQLConnectionManager.connection;
    List<Map<String, Map<String, dynamic>>> results =
        await connection.mappedResultsQuery('''
    SELECT * FROM orders WHERE order_id = @id
  ''', substitutionValues: {
      'id': id,
    });

    if (results.isNotEmpty) {
      return Order.fromMap(results.first.values.first);
    } else {
      return null;
    }
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<void> deleteOrder(String id) async {
  try {
    final connection = PostgreSQLConnectionManager.connection;
    await connection.transaction((ctx) async {
      // Delete ordered items for this order
      await ctx.query('''
        DELETE FROM ordered_items WHERE order_id = @orderId
      ''', substitutionValues: {
        'orderId': id,
      });

      // Delete order from orders table
      await ctx.query('''
        DELETE FROM orders WHERE order_id = @id
      ''', substitutionValues: {
        'id': id,
      });
    });
  } catch (e) {
    print(e.toString());
  }
}

Future<List<Order>> getOrders() async {
  try {
    final connection = PostgreSQLConnectionManager.connection;
    List<Map<String, Map<String, dynamic>>> results =
        await connection.mappedResultsQuery('''
    SELECT * FROM orders
  ''');

    return results.map((e) => Order.fromMap(e.values.first)).toList();
  } catch (e) {
    print(e.toString());
    return [];
  }
}

Future<bool> createOrder(Order order, List<OrderedItem> orderedItems) async {
  PostgreSQLConnection connection = PostgreSQLConnectionManager.connection;
  try {
    await connection.transaction((ctx) async {
      // Insert order into orders table
      print('Inserting order into orders table...');
      print('Order data: ${order.toMap()}');
      await ctx.query('''
INSERT INTO orders (order_id, people_id, order_date, shipping_address, billing_address, total_amount, order_status, notes, archived) 
VALUES (@order_id, @people_id, @order_date, @shipping_address, @billing_address, @total_amount, @order_status, @notes, @archived)
''', substitutionValues: order.toMap());

      print('Order inserted into orders table. Order ID: ${order.id}');

      // Insert ordered items into ordered_items table
      for (OrderedItem item in orderedItems) {
        print('Inserting ordered item with values: ${{
          ...item.toMap(),
          'orderId': item.orderId
        }}');
        await ctx.query('''
INSERT INTO ordered_items
  (order_id, product_id, product_name, quantity, price, discount, description, item_source, flavor, dose, packaging)
VALUES (@orderId, @productId, @productName, @quantity, @price, @discount, @description, @itemSource, @flavor, @dose, @packaging)
''', substitutionValues: {
          ...item.toMap(),
          'orderId': item.orderId,
          'productId': item.productId,
          'productName': item.productName,
          'itemSource': item.itemSource,
          'flavor': item.flavor,
          'dose': item.dose,
          'packaging': item.packaging,
        });
        print('Ordered item inserted');
      }
    });
    return true; // Return true if operation is successful
  } catch (e) {
    print('Exception occurred while creating order: $e');
    return false; // Return false if operation fails
  }
}
