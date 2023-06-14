import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list_db_manager.dart';
import 'package:crafted_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

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
  List<Order> orders = [];
  List<OrderedItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    manageOrders();
  }

  Future<void> manageOrders() async{
    await fetchOrders();
    filteredItems = getFilteredOrderedItems();
    setState(() {});

  }

  Future<void> fetchOrders() async {
    orders = await ProductionListDbManager.getOpenOrdersWithAllOrderedItems();
  }

  List<OrderedItem> getFilteredOrderedItems() {
    List<OrderedItem> filteredItems = [];
    for (var order in orders) {
      for (var item in order.orderedItems) {
        // if (item.itemSource == widget.itemSource) {
          filteredItems.add(item);
        // }
      }
    }

    filteredItems.sort((a, b) => a.productId.compareTo(b.productId));

    for(var i = 1; i<filteredItems.length;i++){
      var prev = filteredItems[i-1];
      var current = filteredItems[i];
      if(prev.productId == current.productId){
        prev.quantity += current.quantity;
        filteredItems.removeAt(i);
        i--;
      }
    }
    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    // Log the itemSource and orders values received
    debugPrint('ItemSource: ${widget.itemSource}');
    debugPrint('Orders: ${orders.map((e) => e.toString()).join(", ")}');

    // filteredItems = getFilteredOrderedItems();
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
        child: SliderDrawer(
          appBar: SizedBox.shrink(),
          key: widget._sliderDrawerKey,
          sliderOpenSize: 250,
          slider: SliderView(onItemClick: (title) {
            // Handle the menu item click as necessary
          }),
          child: filteredItems.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    OrderedItem item = filteredItems[index];
                    return ListTile(
                      title: Text(item.productName, style: TextStyle(color: Colors.black),),
                      subtitle: Text('Quantity: ${item.quantity}', style: TextStyle(color: Colors.black),),
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
