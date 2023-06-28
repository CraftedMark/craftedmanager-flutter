import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/old_order_provider.dart';
// import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:provider/provider.dart';

class ProductionList extends StatefulWidget {
  final String itemSource;
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  final List<OrderedItem> orderedItems;

  ProductionList(
      {Key? key, required this.itemSource, required this.orderedItems})
      : super(key: key);

  @override
  _ProductionListState createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {
  List<OrderedItem> filteredItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            widget._sliderDrawerKey.currentState?.toggle();
          },
        ),
        title: Text(
          'Production List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Consumer<OrderProvider>(builder: (_, provider, __) {
          filteredItems = provider.getFilteredOrderedItems(widget.itemSource);
          return SliderDrawer(
            appBar: const SizedBox.shrink(),
            key: widget._sliderDrawerKey,
            sliderOpenSize: 250,
            slider: SliderView(onItemClick: (title) {
              // Handle the menu item click as necessary
            }),
            child: filteredItems.isNotEmpty
                ? _productionList()
                : _emptyListPlaceHolder(),
          );
        }),
      ),
    );
  }

  Widget _productionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        OrderedItem item = filteredItems[index];
        return ListTile(
          title: Text(
            item.productName,
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            'Quantity: ${item.quantity}',
            style: TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  Widget _emptyListPlaceHolder() {
    return const Center(
      child: Text(
        'No items to show',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }
}
