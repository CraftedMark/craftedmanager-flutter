import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/create_order_screen.dart';
import 'package:flutter/material.dart';

class SelectCustomerScreen extends StatelessWidget {
  final List<People> customers;

  const SelectCustomerScreen({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Customer'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (BuildContext context, int index) {
          final customer = customers[index];

          return ListTile(
            title: Text('${customer.firstName} ${customer.lastName}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateOrderScreen(client: customer),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
