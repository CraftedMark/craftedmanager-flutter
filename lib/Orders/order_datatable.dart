import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDataTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (_, orderProvider, __) {
        return DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer Name')),
            DataColumn(label: Text('Order Status')),
            // Add more columns as needed
          ],
          rows: orderProvider.orders
              .map(
                (order) => DataRow(cells: [
                  DataCell(Text(order.id.toString())),
                  // DataCell(Text(order.customerName)),
                  DataCell(Text(order.orderStatus)),
                  // Add more cells as needed
                ]),
              )
              .toList(),
        );
      },
    );
  }
}
