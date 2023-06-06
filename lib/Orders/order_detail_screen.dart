import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'edit_order_screen.dart';
import 'ordered_item_postgres.dart';
import 'orders_db_manager.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    Key? key,
    required this.order,
    required this.customer,
    required this.orderedItems,
    required this.products,
    required this.onStateChanged,
  }) : super(key: key);

  final People customer;
  final Order order;
  final List<OrderedItem> orderedItems;
  final List<Product> products;
  final VoidCallback onStateChanged;

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ValueNotifier<Order> _orderNotifier = ValueNotifier<Order>(
    Order(
      id: -1,
      customerId: '',
      orderDate: DateTime.now(),
      shippingAddress: '',
      billingAddress: '',
      productName: '',
      totalAmount: 0,
      orderStatus: '',
      archived: false,
      notes: '',
    ),
  );

  late EasyRefreshController _controller;
  List<String> orderStatuses = [
    'Processing - Pending Payment',
    'Processing - Paid',
    'In Production',
    'Ready to Pickup/ Ship',
    'Delivered / Shipped',
    'Completed',
    'Archived',
    'Cancelled',
  ];

  void onStatusChanged(String newStatus) {
    bool isArchived = (newStatus == 'Archived' || newStatus == 'Completed');
    _orderNotifier.value = _orderNotifier.value.copyWith(
      orderStatus: newStatus,
      archived: isArchived,
    );

    final orderPostgres = OrderPostgres();
    orderPostgres
        .updateOrderStatusAndArchived(_orderNotifier.value)
        .then((success) {
      if (success) {
        print('Order status and archived updated successfully');
        widget.onStateChanged();
      } else {
        print('Failed to update order status and archived');
      }
    });
  }

  void updateOrderDetails(Order updatedOrder) {
    _orderNotifier.value = updatedOrder;
  }

  @override
  void initState() {
    super.initState();
    // Initialize the orderNotifier with the initial order
    _orderNotifier.value = widget.order;
  }

  @override
  Widget build(BuildContext context) {
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
            child: ValueListenableBuilder<Order>(
              valueListenable: _orderNotifier,
              builder: (context, order, child) {
                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    //_updateOrderStatusButton(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBarGoBack() {
    return GestureDetector(
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
              orderedItems: widget.orderedItems,
              products: widget.products,
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
                child: const Text('Cancel'),
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  static const ORDERED_ITEMS_STATUSES = [
    "In-Process",
    "Ready for Delivery",
    "Delivered",
  ];

  void _applyUpdateTo(OrderedItem item) async {
    final index = widget.orderedItems.indexOf(item);
    widget.orderedItems[index].status = selection;
    setState(() {});

    await OrderedItemPostgres.updateOrderedItemStatus(item.id, selection);
    Navigator.of(context).pop();
  }

  var selection = ORDERED_ITEMS_STATUSES.first;

  Future<void> _changeItemStatus(OrderedItem item) async {
    final res = await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150,
                  child: CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32,
                    // This sets the initial item.
                    scrollController: FixedExtentScrollController(
                      initialItem: 0,
                    ),
                    // This is called when selected item is changed.
                    onSelectedItemChanged: (int selectedItem) {
                      selection = ORDERED_ITEMS_STATUSES[selectedItem];
                    },
                    children: List<Widget>.generate(
                      ORDERED_ITEMS_STATUSES.length,
                      (int index) {
                        return Center(
                          child: Text(
                            ORDERED_ITEMS_STATUSES[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () => _applyUpdateTo(item),
                    child: const Text("Save"))
              ],
            )),
      ),
    );
  }

  Widget _orderedItemsList() {
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
        for (OrderedItem orderedItem in widget.orderedItems)
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
                  TextButton(
                    onPressed: () => _changeItemStatus(orderedItem),
                    child: Text(
                      'Item status: ${orderedItem.status}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
