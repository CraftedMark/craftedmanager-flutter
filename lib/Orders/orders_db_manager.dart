import 'dart:core';

import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:postgres/postgres.dart';

import '../PostresqlConnection/postqresql_connection_manager.dart';

class OrderPostgres {
  OrderPostgres();

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

  static Future<bool> updateOrder(
      Order order, List<OrderedItem> orderedItems) async {
    try {
      final connection = PostgreSQLConnectionManager.connection;

      await connection.transaction((ctx) async {
        print('Updating order with values: ${order.toMap()}');
        // Update order in orders table
        await ctx.query('''
        UPDATE orders
        SET people_id = @people_id, order_date = @orderDate, shipping_address = @shippingAddress, billing_address = @billingAddress, total_amount = @totalAmount, order_status = @orderStatus
        WHERE order_id = @order_id
      ''', substitutionValues: {
          ...order.toMap(),
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
  (order_id, product_id, product_name, quantity, price, discount, description, item_source)
VALUES (@orderId, @productId, @productName, @quantity, @price, @discount, @description, @itemSource)
''', substitutionValues: {
            ...item.toMap(),
            'orderId': order.id,
            'productId': item.productId,
            'productName': item.productName,
            'itemSource': item.itemSource, // Include the item_source
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

  Future<bool> updateOrderStatusAndArchived(Order updatedOrder) async {
    try {
      final connection = PostgreSQLConnectionManager.connection;

      await connection.transaction((ctx) async {
        print(
            'Updating order status and archived with values: ${updatedOrder.toMap()}');
        // Update order in orders table
        await ctx.query('''
        UPDATE orders
        SET order_status = @orderStatus, archived = @archived
        WHERE order_id = @order_id
      ''', substitutionValues: {
          'order_id': updatedOrder.id,
          'orderStatus': updatedOrder.orderStatus,
          'archived': updatedOrder.archived,
        });
        print('Order status and archived updated');
      });
      return true;
    } catch (e) {
      print('Error: ${e.toString()}');
      return false;
    }
  }

  static Future<List<Order>> getAllOrders() async {
    final orders = <Order>[];
    try {
      final connection = PostgreSQLConnectionManager.connection;
      List<Map<String, Map<String, dynamic>>> results =
          await connection.mappedResultsQuery('''
    SELECT * FROM orders
    ORDER BY order_date DESC
  ''');

      for (var row in results) {
        orders.add(Order.fromMap(row.values.first));
      }
    } catch (e) {
      print(e.toString());
    }

    orders.sort((a, b) => a.orderDate.compareTo(b.orderDate));

    return orders;
  }

  static Future<Order?> getOrderById(String id) async {
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

  static Future<void> deleteOrder(String id) async {
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

  Future<void> createOrder(Order order, List<OrderedItem> orderedItems) async {
    PostgreSQLConnection connection = PostgreSQLConnectionManager.connection;
    try {
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
  (order_id, product_id, product_name, quantity, price, discount, description, item_source)
VALUES (@orderId, @productId, @productName, @quantity, @price, @discount, @description, @itemSource)
''', substitutionValues: {
            ...item.toMap(),
            'orderId': order.id,
            'productId': item.productId,
            'productName': item.productName,
            'itemSource': item.itemSource, // Include the item_source
          });
          print('Ordered item inserted');
        }
      });

      // Adding order to the provider
      // orderProvider.addOrder(order);

      print('Order created.');
    } catch (e) {
      print('Error creating order: ${e.toString()}');
    }
  }
}
