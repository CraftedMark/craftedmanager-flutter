import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:crafted_manager/config.dart';
import 'package:postgres/postgres.dart';

import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';

class PostgresOrdersAPI {
  PostgresOrdersAPI._();

  static Future<bool> createOrder(Order order, List<OrderedItem> orderedItems) async {
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

  static Future<List<Order>> getOrders() async {
    try {
      final connection = PostgreSQLConnectionManager.connection;
      List<Map<String, Map<String, dynamic>>> results =
      await connection.mappedResultsQuery('''
    SELECT * FROM orders
    
  ''');
//WHERE order_status = \'Open\'
      return results.map((e) => Order.fromMap(e.values.first)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
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

  static Future<bool> updateOrder(Order order) async {
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

        for (OrderedItem item in order.orderedItems) {
          print('Inserting updated ordered item with values: ${{
            ...item.toMap(),
            'orderId': order.id,
          }}');
          await ctx.query('''
INSERT INTO ordered_items
(order_id, product_id, product_name, quantity, price, discount, description, item_source, flavor, dose, packaging, status)
VALUES (@orderId, @productId, @productName, @quantity, @price, @discount, @description, @itemSource, @flavor, @dose, @packaging, @status)
''', substitutionValues: {
            ...item.toMap(),
            'orderId': order.id,
            'productId': item.productId,
            'productName': item.productName,
            'itemSource': item.itemSource,
            'flavor': item.flavor,
            'dose': item.dose,
            'packaging': item.packaging,
            'status':item.status,
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

  static Future<bool> updateOrderStatus(Order updatedOrder) async {
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

}

class PostgresOrderedItemAPI {
  // Fetch ordered items by orderId
  static Future<List<OrderedItem>> getOrderedItemsForOrder(String orderId) async {
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

  static Future<List<OrderedItem>> getOrderedItemsForOrderByProductIdAndFlavor(String orderId, int productId, String flavor) async {
    final connection = PostgreSQLConnectionManager.connection;

    var items = <OrderedItem>[];
    await connection.transaction((ctx) async {
      final result = await ctx.query('''
        SELECT * FROM ordered_items WHERE order_id = @order_id AND product_id = @product_id AND flavor = @flavor AND status != @status
      ''', substitutionValues: {"order_id":orderId, "product_id":productId, "flavor":flavor, "status": AppConfig.ORDERED_ITEM_STATUSES[3]});

      items = result.map((item)=>OrderedItem.fromMap(item.toColumnMap())).toList();
    });
    return items;
  }


  static Future<void> updateOrderedItemStatus(int orderedItemId, String status) async {
    final connection = PostgreSQLConnectionManager.connection;

    const query = "UPDATE ordered_items SET status = @status WHERE ordered_item_id = @orderedItemId";
    final values = {
      'status': status,
      'orderedItemId': orderedItemId
    };

    final result = await connection.query(query, substitutionValues: values);

  }
}

class PostgreCustomersAPI{
  static Future<Map<String, dynamic>?> getAddressForUserById(
      String customerId) async {
    PostgreSQLExecutionContext ctx = PostgreSQLConnectionManager.connection;
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
}

