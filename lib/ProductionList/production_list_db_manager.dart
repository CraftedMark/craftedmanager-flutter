import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:postgres/postgres.dart';

class ProductionListDbManager {
  final connection = PostgreSQLConnection(
    'web.craftedsolutions.co', // Database host
    5432, // Port number
    'craftedmanager_db', // Database name
    username: 'craftedmanager_dbuser', // Database username
    password: '!!Laganga1983', // Database password
  );

  Future<List<Order>> getOpenOrdersWithAllOrderedItems() async {
    await connection.open();
    final ordersResult = await connection.query('SELECT * FROM orders');

    final List<Order> openOrders = ordersResult
        .map((data) => Order.fromMap(data.toColumnMap()))
        .where((order) => order.orderStatus == 'open')
        .toList();

    for (var order in openOrders) {
      final orderedItemsResult = await connection.query(
        'SELECT * FROM ordered_items WHERE orderId = @orderId',
        substitutionValues: {'orderId': order.id},
      );

      order.orderedItems = orderedItemsResult
          .map((data) => OrderedItem.fromMap(data.toColumnMap()))
          .toList();
    }

    await connection.close();
    return openOrders;
  }
}
