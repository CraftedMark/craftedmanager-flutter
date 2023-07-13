import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/Providers/people_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/config.dart';
import 'package:crafted_manager/services/PostgreApi.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/order_id_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/product_model.dart';
import '../widgets/alert.dart';
import '../widgets/big_button.dart';
import '../widgets/dropdown_menu.dart';
import '../widgets/text_input_field.dart';
import '../widgets/tile.dart';

class ProductionListDetails extends StatefulWidget {
  const ProductionListDetails({
    Key? key,
    required this.productName,
    required this.productId,
    required this.ordersIds,
    required this.flavor,
  }) : super(key: key);

  final String productName;
  final int productId;
  final List<String> ordersIds;
  final String flavor;

  @override
  State<ProductionListDetails> createState() => _ProductionListDetailsState();
}

class _ProductionListDetailsState extends State<ProductionListDetails> {
  final amountCtrl = TextEditingController(text: '0');
  List<OrderedItem> items = [];
  List<OrderWithOrderedItem> ordersWithItem =[];

  int producedAmount = 0;
  int expextedAmount = 0;

  ///fake API call
  Future<int> getProducedAmount() async {//TODO: make api
    await Future.delayed(Duration(milliseconds: 300));
    return 0;
  }

  int getExpectedAmount() {
    return items.fold(0, (prev, item) => prev+=item.quantity);
  }



  Future<void> getOrderedItems() async {
    final orders = Provider.of<OrderProvider>(context, listen: false).openOrders;
    for(final id in widget.ordersIds){
      final order = orders.firstWhere((o) => o.id == id);
      final orderedItems = order.orderedItems.where((item) =>item.flavor == widget.flavor && item.productId == widget.productId);
      // final orderedItems = await PostgresOrderedItemAPI.getOrderedItemsForOrderByProductIdAndFlavor(id, widget.productId, widget.flavor);
      items.addAll(orderedItems);
    }

  }

  void onAddButtonPressed(){
    //Provider.updateProducedAmount(productId, flavor, amount);//TODO:add
    final producedAmount = int.parse(amountCtrl.text);
    if(producedAmount > 0){
      print(amountCtrl.text);
    }
  }

  Future<void> addProducedQuantity() async {
    showDialog(
        context: context,
        builder: (_){
          return AlertCustom(
            title: 'Enter produced amount',
            rightButton: BigButton(
              text: 'Add',
              onPressed: onAddButtonPressed,
            ),
            children: [
              Text(items.first.name),
              const SizedBox(height: 8),
              Text('( ${items.first.flavor} )', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextInputField(
                labelText: 'Produced amount',
                controller: amountCtrl,
                keyboardType: TextInputType.number,
              )
            ],
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getOrderedItems();
      producedAmount =  await getProducedAmount();
      expextedAmount = getExpectedAmount();
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.openOrders;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.productName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            items.isEmpty
            ? const _LoadingIndicator(text: 'Loading data')
            : provider.isLoading
            ?const _LoadingIndicator(text: 'Synchronize with DB')
            : ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (_,index){
                final orderId = items[index].orderId;
                final order = orders.firstWhere((o) => o.id == orderId);

                return _OrderTile(
                  orderAndItem: OrderWithOrderedItem(order, items[index]),
                );
              }
            ),
            _BottomPanel(
              expectedOrderedItemsAmount: expextedAmount,
              producedOrderedItemsAmount: producedAmount,
              onAddButtonPressed: addProducedQuantity,
            ),
          ],
        ),
      )
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    Key? key,
    required this.orderAndItem,
  }) : super(key: key);

  final OrderWithOrderedItem orderAndItem;


  @override
  Widget build(BuildContext context) {
    final order = orderAndItem.order;

    final orderedItem = order.orderedItems.firstWhere((oi) => oi.flavor == orderAndItem.item.flavor && oi.productId == orderAndItem.item.productId);

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final customer = Provider.of<PeopleProvider>(context, listen: false).peoples.firstWhere((p) => p.id == order.customerId);


    return Tile(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          OrderIdField(orderId: order.id),
          const SizedBox(height: 8),
          const DividerCustom(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Need to produce:'),
              Text('${orderedItem.quantity}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer:'),
              Text('${customer.firstName} ${customer.lastName}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Flavor:'),
              Text(orderedItem.flavor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dose:'),
              Text('${orderedItem.dose}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Packaging:'),
              Text(orderedItem.packaging),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: Text('Item status')),
              Flexible(
                child: DropdownMenuCustom(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  label: '',
                  value: orderedItem.status,
                  items: List.generate(
                    AppConfig.ORDERED_ITEM_STATUSES.length,
                    (index) => DropdownMenuItem<String>(
                      value: AppConfig.ORDERED_ITEM_STATUSES[index],
                      child: Text(AppConfig.ORDERED_ITEM_STATUSES[index]),
                    )
                  ),
                  onChanged: (newStatus) {
                    if(newStatus == orderedItem.status) return;
                    orderedItem.status = newStatus!;
                    provider.updateOrderedItemStatus(orderedItem, orderedItem.status);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(text),
          ],
        ),
      ),
    );
  }
}


class _BottomPanel extends StatelessWidget{
  const _BottomPanel({
    super.key,
    required this.expectedOrderedItemsAmount,
    required this.producedOrderedItemsAmount,
    required this.onAddButtonPressed,
  });

  final int expectedOrderedItemsAmount;
  final int producedOrderedItemsAmount;
  final void Function() onAddButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          color: UIConstants.BACKGROUND_COLOR,
          child:  Column(
            children: [
              const DividerCustom(),
              BigButton(onPressed: onAddButtonPressed, text: 'Add Produced Amount'),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Produced:'),
                  Text('$producedOrderedItemsAmount'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected:'),
                  Text('$expectedOrderedItemsAmount'),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

}

class OrderWithOrderedItem{
  final Order order;
  final OrderedItem item;

  OrderWithOrderedItem(this.order,this.item);
}
