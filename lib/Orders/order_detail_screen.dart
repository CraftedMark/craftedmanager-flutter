import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final People customer;
  final VoidCallback onStateChanged;

  OrderDetailScreen(
      {required this.order,
      required this.customer,
      required this.onStateChanged});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<String> orderStatuses = [
    'Processing - Pending Payment',
    'Processing - Paid',
    'In Production',
    'Ready to Pickup/ Ship',
    'Delivered / Shipped',
    'Completed',
    'Archived',
    'Cancelled'
  ];

  void onStatusChanged(String newStatus) {
    bool isArchived = (newStatus == 'Archived' || newStatus == 'Completed');
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.updateOrderStatus(
        widget.order.id.toString(), newStatus, isArchived);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Details', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditOrderScreen(
                    order: widget.order,
                    customer: widget.customer,
                    products: [],
                    onStateChanged: widget.onStateChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Text(
              'Order ID: ${widget.order.id}',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Customer: ${widget.customer.firstName} ${widget.customer.lastName}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'Total Amount: \$${widget.order.totalAmount}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'Order Status: ${widget.order.orderStatus}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text('Change Order Status'),
              onPressed: () {
                /*...*/
              },
            ),
            SizedBox(height: 24),
            Text(
              'Products:',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) => Column(
                children: widget.order.orderedItems
                    .map(
                      (OrderedItem orderedItem) => Card(
                        color: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Name: ${orderedItem.productName}',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Divider(color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                'Quantity: ${orderedItem.quantity}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Price: \$${orderedItem.price}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Flavor: ${orderedItem.flavor}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Status: ${orderedItem.status}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Dose: ${orderedItem.dose}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Packaging: ${orderedItem.packaging}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
