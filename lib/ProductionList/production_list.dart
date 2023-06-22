import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
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
  bool isLoading = true;
  List<Order> orders = [];
  List<OrderedItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      Provider.of<OrderProvider>(context, listen: false)
          .filterOrderedItems(widget.itemSource);
      updateLoadingState();
    });
  }

  void updateLoadingState() {
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var orderProvider = context.watch<OrderProvider>();
    var filteredItems = orderProvider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            widget._sliderDrawerKey.currentState?.toggle();
          },
        ),
        title: const Text(
          'Production List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SliderDrawer(
          appBar: const SizedBox.shrink(),
          key: widget._sliderDrawerKey,
          sliderOpenSize: 250,
          slider: SliderView(onItemClick: (title) {
            // Handle the menu item click as necessary
          }),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ))
              : filteredItems.isNotEmpty
                  ? ListView.builder(
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
                    )
                  : Center(
                      child: Text(
                        'No items to show',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
