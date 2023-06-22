import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import 'edit_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final People customer;

  OrderDetailScreen(
      {required this.order,
      required this.customer,
      });

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderProvider _provider;
  List<String> orderStatuses = AppConfig.ENABLE_WOOSIGNAL
      ? [
          'pending',
          'processing',
          'on-hold',
          'completed',
          'cancelled',
          'refunded',
          'failed',
          'trash'
        ]
      : [
          'Processing - Pending Payment',
          'Processing - Paid',
          'In Production',
          'Ready to Pickup/ Ship',
          'Delivered / Shipped',
          'Completed',
          'Archived',
          'Cancelled'
        ];

  @override
  void initState() {
    super.initState();
  }

  void updateOrderStatusInUI(String newStatus) {
    widget.order.orderStatus = newStatus;
    setState(() {});
    // _provider.updateOrder(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<OrderProvider>(context);
    final order = _provider.getOrderedItemsForOrder(widget.order.id);

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
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.black,
                      child: ListView.builder(
                        itemCount: orderStatuses.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(orderStatuses[index],
                                style: TextStyle(color: Colors.white)),
                            onTap: () async {
                              final orderForSend = widget.order.copyWith(orderStatus:  orderStatuses[index]);
                              Navigator.pop(context);
                              // displayLoading();
                              final result = await _provider.updateOrder(orderForSend, status: WSOrderStatus.values[index]);
                              // Navigator.pop(context);
                              if(result){
                                updateOrderStatusInUI(orderStatuses[index]);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                );
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
            for (OrderedItem orderedItem in widget.order.orderedItems)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Name: ${orderedItem.productName}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quantity: ${orderedItem.quantity}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Price: \$${orderedItem.price}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Flavor: ${orderedItem.flavor}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Status: ${orderedItem.status}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Dose: ${orderedItem.dose}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Packaging: ${orderedItem.packaging}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  void displayLoading(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context)=> const AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 120),
        content: AspectRatio(
          aspectRatio: 1/1,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
