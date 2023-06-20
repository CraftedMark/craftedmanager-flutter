import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'edit_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    Key? key,
    required this.order,
    required this.customer,
    required this.onStateChanged,
  }) : super(key: key);

  final People customer;
  final Order order;
  final VoidCallback onStateChanged;

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late EasyRefreshController _controller;
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
    orderProvider.updateOrderStatus(widget.order.id, newStatus, isArchived);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.getOrderedItemsForOrder(widget.order.id);

    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.black,
          leading: _topBarGoBack(),
          middle: _topBarTittle(),
          trailing: _topBarEditButton(),
        ),
        backgroundColor: CupertinoColors.black,
        child: SafeArea(
          child: CupertinoScrollbar(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Customer: ${widget.customer.firstName} ${widget.customer.lastName}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Total Amount: \$${order.totalAmount}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order Status: ${order.orderStatus}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                const SizedBox(height: 4),
                _changeStateButton(),
                const SizedBox(height: 24),
                _orderedItemsList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBarGoBack() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
      },
      child: const Icon(
        CupertinoIcons.back,
        color: CupertinoColors.activeBlue,
      ),
    );
  }

  Widget _topBarTittle() {
    return const Text(
      'Order Details',
      style: TextStyle(color: CupertinoColors.white),
    );
  }

  Widget _topBarEditButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditOrderScreen(
              order: widget.order,
              customer: widget.customer,
              products: const [],
            ),
          ),
        );
      },
      child: const Icon(
        CupertinoIcons.pencil,
        color: CupertinoColors.activeBlue,
      ),
    );
  }

  Widget _changeStateButton() {
    return CupertinoButton(
      child: const Text('Change Order Status'),
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoActionSheet(
              title: const Text('Select Order Status'),
              actions: orderStatuses.map((status) {
                return CupertinoActionSheetAction(
                  child: Text(status),
                  onPressed: () {
                    onStatusChanged(status);
                    // widget.onStateChanged();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _orderedItemsList() {
    return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
      final order = orderProvider.getOrderedItemsForOrder(widget.order.id);
      final orderedItems = order.orderedItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordered Items:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (OrderedItem orderedItem in orderedItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Name: ${orderedItem.productName}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${orderedItem.quantity}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: \$${orderedItem.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      'Item status: ${orderedItem.status}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
