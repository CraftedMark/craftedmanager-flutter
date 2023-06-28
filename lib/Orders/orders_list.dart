import 'package:flutter/services.dart';
import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Orders/search_people_screen.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/people_model.dart';
import '../Providers/people_provider.dart';
import '../config.dart';
import 'order_detail_screen.dart';

enum OrderListType {
  productionAndCancelled,
  archived,
}

var _cachedCustomers = <People>{}; //replace with Provider

class OrdersList extends StatefulWidget {
  final OrderListType listType;
  final String title;

  const OrdersList({
    Key? key,
    required this.title,
    this.listType = OrderListType.productionAndCancelled,
  }) : super(key: key);

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  var cachedCustomers = <People>{};

  Future<void> _refreshOrdersList() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(color: Colors.white, )),
        actions: [
          if (widget.listType != OrderListType.archived)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPeopleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
        ],
      ),
      body: SafeArea(
        child: Consumer<OrderProvider>(
          builder: (ctx, orderProvider, _) {
            final orders = orderProvider.orders;

            if (orders.isEmpty) {
              print('No orders found');
              return Center(child: Text('No orders found'));
            }

            var sortedOrders = <Order>[];
            if (widget.listType == OrderListType.archived) {
              var archivedOrders = _getArchivedOrders(orders);
              _sortOrderByDate(archivedOrders);
              sortedOrders = archivedOrders;
            } else {
              sortedOrders = _sortOrder(orders);
            }

            return EasyRefresh(
              child: ListView.builder(
                cacheExtent: 10000, //for cache more orders in one time(UI)
                itemCount: sortedOrders.length,
                itemBuilder: (BuildContext context, int index) {
                  return _OrderWidget(
                    order: sortedOrders[index],
                    onStateChanged: () async {
                      await orderProvider
                          .fetchOrders(); // Refresh the orders from the provider
                      _refreshOrdersList();
                    },
                  );
                },
              ),
              onRefresh: () async {
                await orderProvider
                    .fetchOrders(); // Refresh the orders from the provider
                _refreshOrdersList();
              },
            );
          },
        ),
      ),
    );
  }

  List<Order> _getArchivedOrders(List<Order> orders) {
    return orders.where((o) => o.orderStatus == "Archived").toList();
  }

  List<Order> _sortOrder(List<Order> orders) {
    var otherOrders = orders
        .where(
            (o) => o.orderStatus != "Cancelled" && o.orderStatus != "Archived")
        .toList();
    var cancelledOrders =
        orders.where((o) => o.orderStatus == "Cancelled").toList();

    _sortOrderByDate(otherOrders);
    _sortOrderByDate(cancelledOrders);

    return [...otherOrders, ...cancelledOrders];
  }

  void _sortOrderByDate(List<Order> orders) {
    orders.sort((o1, o2) => o2.orderDate.compareTo(o1.orderDate));
  }
}

Future<People> _getCustomerById(String customerId) async {
  //TODO: find out why the customer can be null
  People fakeCustomer = People(
    id: '1',
    wooSignalId: 1,
    firstName: 'Fake',
    lastName: "Customer",
    phone: '123',
    email: 'email',
    brand: 'brand',
    notes: 'notes',
  );

  var cachedUser = _cachedCustomers.where((c) => c.id == customerId);
  if (cachedUser.isEmpty) {
    var newUser = People.empty();
    if (AppConfig.ENABLE_WOOSIGNAL) {
      // newUser = await WooSignalService.getCustomerById(customerId) ?? newUser   ;
    } else {
      newUser = await PeoplePostgres.fetchCustomer(customerId) ?? fakeCustomer;
    }
    _cachedCustomers.addAll([newUser]);
    return newUser;
  }
  return cachedUser.first;
}

class _OrderWidget extends StatefulWidget {
  final Order order;
  final VoidCallback onStateChanged;
  const _OrderWidget(
      {Key? key, required this.order, required this.onStateChanged})
      : super(key: key);

  @override
  State<_OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<_OrderWidget> {
  People? customer;

  People getCustomer() {
    return Provider.of<PeopleProvider>(context)
        .people
        .firstWhere((c) => c.id == widget.order.customerId);
  }

  Future<void> onTileTap() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          order: widget.order,
          customer: customer!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    customer = getCustomer();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      height: 160,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 34, 42),
        borderRadius: BorderRadius.circular(15),
      ),
      child: customer != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  orderIdField(),
                  orderDateField(),
                  customerInfoField(),
                  divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      statusField(),
                      totalField(),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget orderIdField() {
    Future<void> onCopyButtonTap() async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          'Copied to clipboard',
          style: TextStyle(color: Colors.white),
        ),
      ));
      await Clipboard.setData(ClipboardData(text: widget.order.id));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order ID:'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.order.id,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            GestureDetector(
              onTap: onCopyButtonTap,
              child: const Icon(Icons.copy, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget orderDateField() {
    return Text(
      'Order Date: ${DateFormat('MM-dd-yyyy').format(widget.order.orderDate)}',
    );
  }

  Widget customerInfoField() {
    return Text('Customer: ${customer!.firstName} ${customer!.lastName}');
  }

  Widget divider() {
    return const Divider(height: 2, color: Colors.white);
  }

  Widget statusField(){
    return Text('Status: ${widget.order.orderStatus}');
  }
  Widget totalField(){
    return Row(
      children: [
        const Text('Total: '),
        Text('\$${widget.order.totalAmount}', style: TextStyle(color: Colors.white70),)
      ],
    );
  }
}
