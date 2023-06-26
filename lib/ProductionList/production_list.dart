import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
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

  void getOrdersAndItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .filterOrderedItems(widget.itemSource);
      setState(() {
        isLoading = false;
      });
    });
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOrdersAndItems();
    });
  }

  void updateLoadingState() {
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
        builder: (context, AsyncSnapshot<List<Order>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.hasError) {
            // handle error or no data scenario
            return Text("Error fetching the orders!");
          } else {
            OrderProvider orderProvider = Provider.of<OrderProvider>(context);
            // give dart event loop chance to finish building widgets
            Future.microtask(
                () => orderProvider.filterOrderedItems(widget.itemSource));
            List<OrderedItem> filteredItems = orderProvider.filteredItems;

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
        });
  }
}
