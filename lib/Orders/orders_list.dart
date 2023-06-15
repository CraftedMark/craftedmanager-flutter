import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:crafted_manager/Orders/search_people_screen.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/people_model.dart';
import '../Models/product_model.dart';
import 'order_detail_screen.dart';
import 'ordered_item_postgres.dart';

enum OrderListType {
  productionAndCancelled,
  archived,
}

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
  Future<List<OrderedItem>> fetchOrderedItems(int orderId) async {
    return await OrderedItemPostgres.fetchOrderedItems(orderId);
  }

  Future<List<Product>> fetchProducts(List<OrderedItem> orderedItems) async {
    // Implement the logic to fetch the list of products from the database based on the orderedItems list
    return [];
  }

  Future<void> _refreshOrdersList() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPeopleScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final orders = orderProvider.orders;

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
                itemCount: sortedOrders.length,
                itemBuilder: (BuildContext context, int index) {
                  return _orderWidget(sortedOrders[index]);
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

  Future<People> _getCustomerById(int customerId) async {
    //TODO: find out why the customer can be null
    People fakeCustomer = People(
      id: 1,
      firstName: 'Fake',
      lastName: "Customer",
      phone: '123',
      email: 'email',
      brand: 'brand',
      notes: 'notes',
    );
    return await PeoplePostgres.fetchCustomer(customerId) ?? fakeCustomer;
  }

  Widget _orderWidget(Order order) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: FutureBuilder<People>(
        future: _getCustomerById(int.parse(order.customerId)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var customer = snapshot.data!;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                // Fetch customer, orderedItems, and products data here
                final customer =
                    await _getCustomerById(int.parse(order.customerId));
                List<OrderedItem> orderedItems =
                    await fetchOrderedItems(order.id);
                List<Product> products = await fetchProducts(orderedItems);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(
                      order: order,
                      customer: customer,
                      orderedItems: orderedItems,
                      onStateChanged: () {
                        // Handle state change if needed
                      },
                    ),
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
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
