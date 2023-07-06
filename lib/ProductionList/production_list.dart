import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list_details.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/main.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/tile.dart';

class ProductionList extends StatefulWidget {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  ProductionList({Key? key}): super(key: key);

  @override
  _ProductionListState createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {

  List<OrderedItem> filteredItems = [];
  List<OrderedItem> unitedItems = [];
  Map<int, Set<String>> ordersGroupedByOrderedItemId = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchOrderedItemsByItemSource('');
    });
  }

  void uniteOrderedItemsById(){

    unitedItems = filteredItems;
    unitedItems.sort((a, b) => a.productId.compareTo(b.productId));
    for(var i = 1; i<unitedItems.length;i++){
      var prev = unitedItems[i-1];
      var current = unitedItems[i];
      if(prev.productId == current.productId){
        unitedItems[i-1] = prev.copyWith(quantity: prev.quantity+current.quantity);
        unitedItems.removeAt(i);
        i--;
      }
    }
  }

  void createMap(){
    var map = <int, Set<String>>{};
    for(final i in filteredItems){
      final key = i.productId;
      if(map.containsKey(key)){
        map.update(key, (value) => {...value,i.orderId});
      }
      else{
        map.addAll({key: {i.orderId}});
      }
    }
    ordersGroupedByOrderedItemId = map;
  }

  void searchOrderedItemsByItemSource(String query){
    filteredItems = List.from(Provider.of<OrderProvider>(context, listen: false).getFilteredOrderedItems(query));
    createMap();
    uniteOrderedItemsById();
    setState(() {});
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
        bottom: searchField(
          context,
          searchOrderedItemsByItemSource,
          label: 'Filter by item source',
        ),
      ),
      body: SafeArea(
        child: SliderDrawer(
            appBar: null,
            key: widget._sliderDrawerKey,
            sliderOpenSize: 250,
            slider: SliderView(onItemClick: (title) {
              // Handle the menu item click as necessary
            }),
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: unitedItems.isNotEmpty
                      ? _productionList()
                      : _emptyListPlaceHolder(),
            ),
          ),
      ),
    );
  }

  Widget _productionList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
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
      child: Text('No items to show'),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      item.productName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Product ID: ${item.productId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
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


