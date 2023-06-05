import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/database_functions.dart';

class OrderedItemPostgres {
  // Fetch ordered items by orderId
  static Future<List<OrderedItem>> fetchOrderedItems(int orderId) async {
    final connection = await connectToPostgres();
    final result = await connection.query(
        'SELECT * FROM ordered_items WHERE order_id = @orderId',
        substitutionValues: {'orderId': orderId});

    await connection.close();
    return result.isNotEmpty
        ? result.map((row) => OrderedItem.fromMap(row.toColumnMap())).toList()
        : [];
  }


  static Future<void> updateOrderedItemStatus(int orderedItemId, String status) async {
    final connection = await connectToPostgres();

    final query = "UPDATE ordered_items SET status = @status WHERE ordered_item_id = @orderedItemId";
    final values = {
      'status': status,
      'orderedItemId': orderedItemId
    };

    final result = await connection.query(query, substitutionValues: values);


    await connection.close();
  }
}
