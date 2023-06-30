import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/utils/getColorByStatus.dart';
import 'package:flutter/material.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Providers/order_provider.dart';
import '../config.dart';
import '../widgets/divider.dart';
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

  void updateOrderStatusInUI(String newStatus) {
    widget.order.orderStatus = newStatus;
    setState(() {});
    // _provider.updateOrder(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<OrderProvider>(context);
    orderedItems = _provider.orders
        .firstWhere((o) => o.id == widget.order.id)
        .orderedItems;
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
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: UIConstants.GREY_MEDIUM,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    _orderTextInfo(),
                    const SizedBox(height: 24),
                    _changeOrderStateButton(),
                    const SizedBox(height: 24),
                    _OrderedItemList(items: orderedItems),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                const Expanded(child: SizedBox.shrink()),
                _orderCost(),
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Change Order Status',
            style: TextStyle(color: UIConstants.WHITE)),
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
                  style: TextStyle(color: UIConstants.WHITE_LIGHT, fontSize: 19),
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
        Text('PRODUCTS (${widget.items.length})', style: Theme.of(context).textTheme.bodyLarge),
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
                child: Column(
                  children: [
                    itemTileRow('Quantity', item.quantity.toString()),
                    const SizedBox(height: 4),
                    itemTileRow('Price', item.price.toString()),
                    const SizedBox(height: 4),
                    itemTileRow('Flavor', item.flavor),
                    const SizedBox(height: 4),
                    itemTileRow('Status', item.status, valuColor: StatusColor.getColor(item.status)),
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
  Widget itemTileRow(String field, String value, {Color? valuColor}){
    return Row(
      children: [
        Text('$field: '),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valuColor ?? UIConstants.WHITE_LIGHT)),
      ],
    );
  }
  Widget itemTilePicture({String? url, Image? image} ){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: UIConstants.TEXT_COLOR,
      ),
      width: 140,
      height: 140,
    );
  }//TODO: implement
}
