import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/order_model.dart';
import '../Models/people_model.dart';
import 'order_detail_screen.dart';

class OrderList extends StatelessWidget {
  final List<Order> orders;
  final List<People> customers;

  const OrderList({
    Key? key,
    required this.orders,
    required this.customers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        final order = orders[index];
        final customer = customers.firstWhere((c) => c.id == order.customerId);

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(
                  order: order,
                  customer: customer,
                  onStateChanged: () {},
                ),
              ),
            );
          },
          title: Text(
            '${customer.firstName} ${customer.lastName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                DateFormat.yMMMMd().format(order.orderDate),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
