import 'dart:core';

import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:postgres/postgres.dart';

class OrderPostgres {
  static Future<PostgreSQLConnection> openConnection() async {
    print('Opening connection...');
    final connection = PostgreSQLConnection(
      'https://104.13.227.204', // Database host
      5432, // Port number
      'craftedmanager_db', // Database name
      username: 'craftedmanager_dbuser', // Database username
      password: '!!Laganga1983', // Database password
    );
    await connection.open();
    print('Connection opened');
    return connection;
  }

  static Future<void> closeConnection(PostgreSQLConnection connection) async {
    print('Closing connection...');
    await connection.close();
    print('Connection closed');
  }

  static Future<int?> getProductId(
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

  static Future<Map<String, dynamic>?> getAddressFields(
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

  static Future<bool> updateOrder(
      Order order, List<OrderedItem> orderedItems) async {
    try {
      final connection = await openConnection();
      print('Connection opened');
      await connection.transaction((ctx) async {
        print('Updating order with values: ${order.toMap()}');
        // Update order in orders table
        await ctx.query('''
    UPDATE orders
    SET people_id = @people_id, order_date = @orderDate, shipping_address = @shippingAddress, billing_address = @billingAddress, total_amount = @totalAmount, order_status = @orderStatus
    WHERE order_id = @order_id
  ''', substitutionValues: {
          ...order.toMap(),
          // Make sure that order.toMap() returns a map with the key 'people_id'
          'people_id': order.customerId,
        });
        print('Order updated');

        print('Deleting existing ordered items with orderId: ${order.id}');
        // Delete existing ordered items for this order
        await ctx.query('''
      DELETE FROM ordered_items WHERE order_id = @orderId
    ''', substitutionValues: {
          'orderId': order.id,
        });
        print('Existing ordered items deleted');

        // Insert updated ordered items into ordered_items table
        for (OrderedItem item in orderedItems) {
          print('Inserting updated ordered item with values: ${{
            ...item.toMap(),
            'orderId': order.id,
          }}');
          await ctx.query('''
    INSERT INTO ordered_items 
      (order_id, product_id, quantity, price, discount, description)
    VALUES (@orderId, @productId, @quantity, @price, @discount, @description)
  ''', substitutionValues: {
            ...item.toMap(),
            'orderId': order.id,
            'productId': item.productId,
          });
          print('Updated ordered item inserted');
        }
      });
      await closeConnection(connection);
      print('Connection closed');
      return true;
    } catch (e) {
      print('Error: ${e.toString()}');
      return false;
    }
  }

  static Future<List<Order>> getAllOrders() async {
    List<Order> orders = [];
    try {
      final connection = await openConnection();
      List<Map<String, Map<String, dynamic>>> results =
          await connection.mappedResultsQuery('''
    SELECT * FROM orders
  ''');

      for (var row in results) {
        orders.add(Order.fromMap(row.values.first));
      }
      await closeConnection(connection);
    } catch (e) {
      print(e.toString());
    }

    return orders;
  }

  static Future<Order?> getOrderById(String id) async {
    try {
      final connection = await openConnection();
      List<Map<String, Map<String, dynamic>>> results =
          await connection.mappedResultsQuery('''
    SELECT * FROM orders WHERE order_id = @id
  ''', substitutionValues: {
        'id': id,
      });

      await closeConnection(connection);

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

  static Future<void> deleteOrder(String id) async {
    try {
      final connection = await openConnection();
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
      await closeConnection(connection);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> createOrder(Order order, List<OrderedItem> orderedItems) async {
    PostgreSQLConnection? connection;
    try {
      print('Opening connection...');
      connection = await openConnection();
      print('Connection opened.');

      await connection.transaction((ctx) async {
        // Insert order into orders table
        print('Inserting order into orders table...');
        print('Order data: ${order.toMap()}');
        final resultOrder = await ctx.query('''
INSERT INTO orders (order_id, people_id, order_date, shipping_address, billing_address, total_amount, order_status)
VALUES (@order_id, @customerId, @orderDate, @shippingAddress, @billingAddress, @totalAmount, @orderStatus)
''', substitutionValues: order.toMap());
        print('Order inserted into orders table. Result: $resultOrder');

        // Insert ordered items into ordered_items table
        for (OrderedItem item in orderedItems) {
          print('Inserting ordered item with values: ${{
            ...item.toMap(),
            'orderId': order.id,
          }}');
          await ctx.query('''
INSERT INTO ordered_items 
  (order_id, product_id, quantity, price, discount, description)
VALUES (@orderId, @productId, @quantity, @price, @discount, @description)
''', substitutionValues: {
            ...item.toMap(),
            'orderId': order.id,
            'productId': item.productId,
          });
          print('Ordered item inserted');
        }
      });

      print('Order created.');
    } catch (e) {
      print('Error creating order: ${e.toString()}');
    } finally {
      if (connection != null) {
        print('Closing connection...');
        await closeConnection(connection);
        print('Connection closed.');
      }
    }
  }
}
