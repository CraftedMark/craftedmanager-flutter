import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/utils/getColorByStatus.dart';
import 'package:crafted_manager/widgets/plus_button.dart';
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
import '../widgets/divider.dart';
import '../widgets/order_id_field.dart';
import '../widgets/tile.dart';
import 'order_detail_screen.dart';

enum OrderListType {
  newOrders,
  productionAndCancelled,
  archived,
}

class OrdersList extends StatefulWidget {
  final OrderListType listType;

  const OrdersList({
    Key? key,
    this.listType = OrderListType.productionAndCancelled,
  }) : super(key: key);

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  Future<void> _refreshOrdersList() async {
    setState(() {});
  }

  String getListTitle() {
    switch (widget.listType) {
      case OrderListType.productionAndCancelled:
        {
          return 'Orders';
        }
      case OrderListType.archived:
        {
          return 'Archive';
        }
      default:
        return 'New Orders';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(getListTitle(),
            style: Theme.of(context).textTheme.titleMedium),
        actions: [
          if (widget.listType != OrderListType.archived)
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PlusButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPeopleScreen(),
                      ),
                    );
                  },
                )),
        ],
      ),
      body: SafeArea(
        child: Consumer<OrderProvider>(
          builder: (ctx, orderProvider, _) {
            final orders = orderProvider.orders;

            if (orders.isEmpty) {
              return const Center(child: Text('No orders found'));
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
        .peoples
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

    return Tile(
      child: customer != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OrderIdField(
                      orderId: widget.order.id,
                      style: Theme.of(context).textTheme.bodySmall,
                  ),
                  orderDateField(),
                  customerInfoField(),
                  const DividerCustom(),
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

  Widget orderDateField() {
    return Text(
      'Order Date: ${DateFormat('MM-dd-yyyy').format(widget.order.orderDate)}',
        style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget customerInfoField() {
    return Text(
      'Customer: ${customer!.firstName} ${customer!.lastName}',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget statusField() {
    final color = StatusColor.getColor(widget.order.orderStatus);

    return Row(
      children: [
        Text('Status: ', style: Theme.of(context).textTheme.bodySmall),
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: color),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Text(
              widget.order.orderStatus,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: UIConstants.WHITE),
            ),
          ),
        )
      ],
    );
  }

  Widget totalField() {
    return Row(
      children: [
        Text('Total: ', style: Theme.of(context).textTheme.bodySmall),
        Text(
          '\$ ${widget.order.totalAmount}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: UIConstants.WHITE_LIGHT),
        )
      ],
    );
  }
}
