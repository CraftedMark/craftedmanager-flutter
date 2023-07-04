import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list_details.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/tile.dart';

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
  List<OrderedItem> unitedItems = [];
  Map<int, Set<String>> ordersGroupedByOrderedItemId = {};

  void createMap(){
    for(final i in unitedItems){
      final key = i.productId;
      if(ordersGroupedByOrderedItemId.containsKey(key)){
        ordersGroupedByOrderedItemId.update(key, (value) => {...value,i.orderId});
      }
      else{
        ordersGroupedByOrderedItemId.addAll({key: {i.orderId}});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _AppBarMenuButton(menuKey:widget._sliderDrawerKey),
        title: Text(
          'Production List',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Consumer<OrderProvider>(builder: (_, provider, __) {
          filteredItems = provider.getFilteredOrderedItems(widget.itemSource);
          unitedItems = filteredItems;
          unitedItems.sort((a, b) => a.productId.compareTo(b.productId));

          createMap();

          for(var i = 1; i<unitedItems.length;i++){
            var prev = unitedItems[i-1];
            var current = unitedItems[i];
            if(prev.productId == current.productId){
              unitedItems[i-1] = prev.copyWith(quantity: prev.quantity+current.quantity);
              unitedItems.removeAt(i);
              i--;
            }
          }

          return SliderDrawer(
            appBar: null,
            key: widget._sliderDrawerKey,
            sliderOpenSize: 250,
            slider: SliderView(onItemClick: (title) {
              // Handle the menu item click as necessary
            }),
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: provider.isLoading
                  ? _loadingIndicator()
                  : unitedItems.isNotEmpty
                      ? _productionList()
                      : _emptyListPlaceHolder(),
            ),
          );
        }),
      ),
    );
  }


  Widget _loadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _productionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: unitedItems.length,
      itemBuilder: (context, index) {
        OrderedItem item = unitedItems[index];
        return _ProductionListItem(
          item: item,
          ordersIds:ordersGroupedByOrderedItemId[item.productId]!,
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
class _AppBarMenuButton extends StatelessWidget {
  final GlobalKey<SliderDrawerState> menuKey;

  const _AppBarMenuButton({Key? key, required this.menuKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.menu, color: Colors.white),
      onPressed: () {
        if(!menuKey.currentState!.isDrawerOpen){
          menuKey.currentState?.toggle();

        }
      },
    );
  }
}

class _ProductionListItem extends StatelessWidget {
  final OrderedItem item;
  final Set<String> ordersIds;
  const _ProductionListItem({Key? key, required this.item, required this.ordersIds}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductionListDetails(
              productName: item.productName,
              productId: item.productId,
              ordersIds: ordersIds.toList(),
              expectedProductAmount: item.quantity,
            ),
          ),
        );
      },
      child: Tile(
        height: 110,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.productName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Product ID: ${item.productId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text('Status ${item.status}'),
                ],
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.info_outline)],
            )
          ],
        ),
      ),
    );
  }
}


