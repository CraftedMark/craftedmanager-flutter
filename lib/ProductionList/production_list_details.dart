import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/order_id_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/ordered_item_model.dart';
import '../widgets/tile.dart';

class ProductionListDetails extends StatefulWidget {
  const ProductionListDetails({
    Key? key,
    required this.productName,
    required this.productId,
    required this.ordersIds,
    required this.expectedProductAmount
  }) : super(key: key);

  final String productName;
  final int productId;
  final List<String> ordersIds;
  final int expectedProductAmount;

  @override
  State<ProductionListDetails> createState() => _ProductionListDetailsState();
}

class _ProductionListDetailsState extends State<ProductionListDetails> {
  List<OrderedItem> orderedItems = [];
  int producedAmount = 0;

  Future<int> getProducedAmount() async {
    //fake API call
    await Future.delayed(Duration(milliseconds: 300));
    return 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      producedAmount =  await getProducedAmount();
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _expectedAndProducedInfo(
              widget.expectedProductAmount,
              producedAmount,
            ),
            ListView.builder(
              itemCount: widget.ordersIds.length,
              itemBuilder: (_,index){
                final orderId = widget.ordersIds[index];
                final order = Provider.of<OrderProvider>(context, listen: false).orders.firstWhere((o) => o.id == orderId);
                final orderedItem = order.orderedItems.firstWhere((i) => i.productId == widget.productId);
                return Tile(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      OrderIdField(orderId: orderId),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Need to produce:'),
                          Text('${orderedItem.quantity}'),
                        ],
                      )
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      )
    );
  }

  Widget _expectedAndProducedInfo(int expected, int produced){
    return Column(
      children: [
        const Spacer(),
        Container(
          color: UIConstants.BACKGROUND_COLOR,
          child:  Column(
            children: [
              const DividerCustom(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Produced:'),
                  Text('$produced'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected:'),
                  Text('$expected'),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}