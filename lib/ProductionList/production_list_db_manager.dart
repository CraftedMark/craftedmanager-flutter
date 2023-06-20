import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';

class ProductionListDbManager {

  static Future<List<Order>> getOpenOrdersWithAllOrderedItems() async {
    var connection = PostgreSQLConnectionManager.connection;
    final ordersResult = await connection.query('SELECT * FROM orders');

    final List<Order> openOrders = ordersResult
        .map((data) => Order.fromMap(data.toColumnMap()))
        // .where((order) => order.orderStatus == 'open')
        .toList();

    for (var order in openOrders) {
      final orderedItemsResult = await connection.query(
        'SELECT * FROM ordered_items WHERE order_Id = @orderId',
        substitutionValues: {'orderId': order.id},
      );

      order.orderedItems = orderedItemsResult
          .map((data) => OrderedItem.fromMap(data.toColumnMap()))
          .toList();
    }
    return openOrders;
  }
}
