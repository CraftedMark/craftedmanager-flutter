import 'dart:async';

import 'package:crafted_manager/postgres.dart';

import '../PostresqlConnection/postqresql_connection_manager.dart';

class OrdersPostgres {
  static Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final connection = PostgreSQLConnectionManager.connection;
    // Replace 'orders' with your table name
    final results = await connection.query('SELECT * FROM orders');

    List<Map<String, dynamic>> orders = [];
    for (final row in results) {
      orders.add(row.toColumnMap());
    }
    return orders;
  }
}
