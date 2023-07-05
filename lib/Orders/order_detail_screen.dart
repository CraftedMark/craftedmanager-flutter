import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/utils/getColorByStatus.dart';
import 'package:crafted_manager/widgets/grey_scrollable_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/order_provider.dart';
import '../config.dart';
import '../widgets/big_button.dart';
import '../widgets/edit_button.dart';
import '../widgets/order_id_field.dart';
import 'edit_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final People customer;

  OrderDetailScreen({
    required this.order,
    required this.customer,
  });

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderProvider _provider;
  List<OrderedItem> orderedItems = [];

  List<String> orderStatuses = AppConfig.ENABLE_WOOSIGNAL
      ? AppConfig.ORDER_STATUSES_WOOSIGNAL
      : AppConfig.ORDER_STATUSES_POSTGRES;

  void updateOrderStatusInUI(String newStatus) {
    widget.order.orderStatus = newStatus;
    setState(() {});
    // _provider.updateOrder(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<OrderProvider>(context);
    final order = _provider.orders
        .firstWhere((o) => o.id == widget.order.id);
    orderedItems = order.orderedItems;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          EditButton(
            onPressed: _onEditButtonPress,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GreyScrollablePanel(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _orderTextInfo(),
                    const SizedBox(height: 24),
                    _changeOrderStateButton(),
                    const SizedBox(height: 24),
                    _OrderedItemList(items: orderedItems),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const Spacer(),
                _OrderTotalAndPaid(
                  total: order.totalAmount,
                  paid: order.paidAmount,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onEditButtonPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderScreen(
          order: widget.order,
          customer: widget.customer,
          products: orderedItems.map((i) => i.product).toList(),
        ),
      ),
    );
  }

  Widget _orderTextInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderIdField(orderId: widget.order.id),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer:',
            ),
            Text(
              '${widget.customer.firstName} ${widget.customer.lastName}',
              style: const TextStyle(color: UIConstants.WHITE_LIGHT),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Order Status:'),
            Text(
              widget.order.orderStatus,
              style: TextStyle(
                  color: StatusColor.getColor(widget.order.orderStatus)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _changeOrderStateButton() {
    return SizedBox(
      width: double.infinity,
      child: BigButton(
        text: 'Change Order Status',
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
                        //TODO:replace with OrderProvider.updateOrderStatus
                        final orderForSend = widget.order
                            .copyWith(orderStatus: orderStatuses[index]);
                        Navigator.pop(context);
                        // displayLoading();
                        final result = await _provider.updateOrder(orderForSend,
                            status: WSOrderStatus.values[index]);
                        // Navigator.pop(context);
                        if (result) {
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
    );
  }

  Widget _orderCost() {
    return ColoredBox(
      color: UIConstants.GREY_MEDIUM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                ),
                Text(
                  '\$ ${widget.order.totalAmount}',
                  style:
                      TextStyle(color: UIConstants.WHITE_LIGHT, fontSize: 19),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid Amount:',
                ),
                Text(
                  '\$ ${widget.order.paidAmount}',
                  // assuming 'paidAmount' exists in 'Order' class
                  style:
                      TextStyle(color: UIConstants.WHITE_LIGHT, fontSize: 19),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void displayLoading() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 120),
        content: AspectRatio(
          aspectRatio: 1 / 1,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _OrderedItemList extends StatefulWidget {
  final List<OrderedItem> items;
  const _OrderedItemList({Key? key, required this.items}) : super(key: key);

  @override
  State<_OrderedItemList> createState() => _OrderedItemListState();
}

class _OrderedItemListState extends State<_OrderedItemList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PRODUCTS (${widget.items.length})',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          shrinkWrap: true,
          itemBuilder: (_, index) => itemTile(widget.items[index]),
        ),
      ],
    );
  }

  Widget itemTile(OrderedItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: UIConstants.GREY_LIGHT,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            item.productName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: itemTilePicture(),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemTileRow('Quantity', item.quantity.toString()),
                    const SizedBox(height: 4),
                    itemTileRow('Price', item.price.toString()),
                    const SizedBox(height: 4),
                    itemTileRow('Flavor', item.flavor),
                    const SizedBox(height: 4),
                    itemTileRow('Status', item.status,
                        valuColor: StatusColor.getColor(item.status)),
                    const SizedBox(height: 4),
                    itemTileRow('Dose', item.dose.toString()),
                    const SizedBox(height: 4),
                    itemTileRow('Packaging', item.packaging),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget itemTileRow(String field, String value, {Color? valuColor}) {
    return FittedBox(
      child: Row(
        children: [
          Text('$field: '),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: valuColor ?? UIConstants.WHITE_LIGHT),
          overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget itemTilePicture({String? url, Image? image}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: UIConstants.TEXT_COLOR,
      ),
      width: 140,
      height: 140,
    );
  } //TODO: implement
}

class _OrderTotalAndPaid extends StatelessWidget {
  const _OrderTotalAndPaid({
    Key? key,
    required this.total,
    required this.paid
  }) : super(key: key);

  final double total;
  final double paid;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: UIConstants.GREY_MEDIUM,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                ),
                Text(
                  '\$ $total',
                  style:
                  const TextStyle(color: UIConstants.WHITE_LIGHT, fontSize: 19),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Paid Amount:',
                ),
                Text(
                  '\$ $paid',
                  // assuming 'paidAmount' exists in 'Order' class
                  style:
                  const TextStyle(color: UIConstants.WHITE_LIGHT, fontSize: 19),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
