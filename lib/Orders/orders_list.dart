import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/search_people_screen.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/people_model.dart';
import '../config.dart';
import 'order_detail_screen.dart';
import 'ordered_item_postgres.dart';

enum OrderListType {
  productionAndCancelled,
  archived,
}

var _cachedCustomers = <People>{};//replace with Provider


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
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          if( widget.listType != OrderListType.archived)
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
            if (orderProvider == null) {
              print('OrderProvider is null');
              return Center(child: CircularProgressIndicator());
            }

            final orders = orderProvider.orders;
            if (orders == null) {
              print('Orders are null');
              return Center(child: CircularProgressIndicator());
            }

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
                cacheExtent: 10000,//for cache more orders in one time(UI)
                itemCount: sortedOrders.length,
                itemBuilder: (BuildContext context, int index) {
                  return _OrderWidget(order: sortedOrders[index], onStateChanged: () async {
                    await orderProvider
                        .fetchOrders(); // Refresh the orders from the provider
                    _refreshOrdersList();
                  },);
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
  if(cachedUser.isEmpty){
    var newUser = People.empty();
    if(AppConfig.ENABLE_WOOSIGNAL){
      // newUser = await WooSignalService.getCustomerById(customerId) ?? newUser   ;
    }
    else {
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
  const _OrderWidget({Key? key, required this.order, required this.onStateChanged}) : super(key: key);

  @override
  State<_OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<_OrderWidget> {
  People? customer;

  Future<void> loadCustomer() async {
    customer = await _getCustomerById(widget.order.customerId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: customer != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(
                      order: widget.order,
                      customer: customer!,
                      onStateChanged: () {
                        // Handle state change if needed
                      },
                    ),
                  );
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Total: \$${order.totalAmount}'),
                      Text('Status: ${order.orderStatus}'),
                      Text(
                        'Order Date: ${DateFormat('MM-dd-yyyy').format(order.orderDate)}',
                      ),
                      Text(
                          'Customer: ${customer.firstName} ${customer.lastName}'),
                    ],
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${widget.order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Total: \$${widget.order.totalAmount}'),
                    Text('Status: ${widget.order.orderStatus}'),
                    Text(
                      'Order Date: ${DateFormat('MM-dd-yyyy').format(widget.order.orderDate)}',
                    ),
                    Text(
                        'Customer: ${customer!.firstName} ${customer!.lastName}'),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
