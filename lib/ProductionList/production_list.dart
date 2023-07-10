import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list_details.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/Providers/product_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/main.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/order_model.dart';
import '../widgets/tile.dart';

class ProductionList extends StatefulWidget {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  ProductionList({Key? key}) : super(key: key);

  @override
  _ProductionListState createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {
  List<Order> openOrders = [];
  List<OrderedItem> filteredItems = [];

  List<DateProductIdOrdersId> sortedByDateAndGroupedByProductIdsOrders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      openOrders = Provider.of<OrderProvider>(context, listen: false).openOrders;
      search('');
    });
  }

  void search(String query) {
    filteredItems = getFilteredOrderedItems(query);

    if(filteredItems.isEmpty) {
      setState(() {});
      return;
    }

    final dateWithOrderedItems = getDateWithOrderedItemsSorted();

    //create list of ProductId:[OrderId,..]
    var listOfOrdersGroupedByOrderedItemId = dateWithOrderedItems.map((e) => createOrderedItemIdWithOrdersId(e.orderedItems)).toList();

    List<DateProductIdOrdersId> result = [];
    for(int i= 0; i<dateWithOrderedItems.length; i++){
      final date = dateWithOrderedItems[i].date;
      final productIdWithOrdersIds = listOfOrdersGroupedByOrderedItemId[i];
      result.add(DateProductIdOrdersId(date: date, itemsWithOrderIds: productIdWithOrdersIds));
    }

    sortedByDateAndGroupedByProductIdsOrders = result;
    setState(() {});
  }

  List<OrderedItem> getFilteredOrderedItems(String query){
    return Provider.of<OrderProvider>(context, listen: false).getFilteredOrderedItems(query);
  }

  ///Create a list with elements: { date : orderedItem, orderedItem.. }
  ///
  /// OrderedItems sorted by date
  List<DateWithOrderedItems> getDateWithOrderedItemsSorted(){
    //create orderedItems with orderDate
    Map<DateTime, List<OrderedItem>> map = {};
    for(final item in filteredItems){
      final itemOrder = openOrders.firstWhere((o) => o.id == item.orderId);
      final key = itemOrder.orderDate;

      if(map.containsKey(key)){
        map.update(key, (value) => List.from([...value, item]));
      }
      else{
        map.addAll({key: [item]});
      }
    }
    var orderedItemsGroupedByDate = map.entries.map(
            (e) => DateWithOrderedItems(date: e.key, orderedItems: e.value)
    ).toList();

    //sort elements by orderDate
    orderedItemsGroupedByDate.sort((a, b) => a.date.compareTo(b.date));
    return orderedItemsGroupedByDate;
  }

  ///Create a list with elements: { orderedItemId : orderId, orderId.. }
  List<OrderedItemIdWithOrdersIds> createOrderedItemIdWithOrdersId(List<OrderedItem> items) {
    var map = <int, Set<String>>{};
    for (final i in items) {
      final key = i.productId;
      if (map.containsKey(key)) {
        map.update(key, (value) => {...value, i.orderId});
      } else {
        map.addAll({
          key: {i.orderId}
        });
      }
    }


    return map.entries.map(
            (e) => OrderedItemIdWithOrdersIds(
            orderedItemId: e.key,
            ordersIds: e.value
        )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: _AppBarMenuButton(menuKey: widget._sliderDrawerKey),
        title: Text(
          'Production List',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        bottom: searchField(
          context,
          search,
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
            child: filteredItems.isNotEmpty
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
      itemCount: sortedByDateAndGroupedByProductIdsOrders.length,
      itemBuilder: (_, index) =>
          _ProductionListItem(dateProductIdOrdersId: sortedByDateAndGroupedByProductIdsOrders[index]),
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
        if (!menuKey.currentState!.isDrawerOpen) {
          menuKey.currentState?.toggle();
        }
      },
    );
  }
}

class _ProductionListItem extends StatefulWidget {
  const _ProductionListItem({
    Key? key,
    required this.dateProductIdOrdersId,
  }) : super(key: key);

  final DateProductIdOrdersId dateProductIdOrdersId;

  @override
  State<_ProductionListItem> createState() => _ProductionListItemState();
}

class _ProductionListItemState extends State<_ProductionListItem> {
  @override
  Widget build(BuildContext context) {
    final item = widget.dateProductIdOrdersId;

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String date = formatter.format(item.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(date.toString()),
        Tile(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.itemsWithOrderIds.length,
            itemBuilder: (_, index){
              final productIdWithOrdersIds = item.itemsWithOrderIds[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _itemWidget(
                  productIdWithOrdersIds.orderedItemId,
                  productIdWithOrdersIds.ordersIds.toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _itemWidget(int productId, List<String> ordersId){
    final currentProduct = Provider.of<ProductProvider>(context).allProducts.firstWhere((p) => p.id == productId);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: UIConstants.GREY_LIGHT,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductionListDetails(
                productName: currentProduct.name,
                productId: productId,//TODO: fix
                ordersIds: ordersId,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      currentProduct.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: UIConstants.WHITE_LIGHT),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Product ID: $productId'),
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

class DateWithOrderedItems{
  final DateTime date;
  final List<OrderedItem> orderedItems;

  DateWithOrderedItems({
    required this.date,
    required this.orderedItems,
  });
}

class OrderedItemIdWithOrdersIds{
  final int orderedItemId;
  final Set<String> ordersIds;

  OrderedItemIdWithOrdersIds({
    required this.orderedItemId,
    required this.ordersIds,
  });
  @override
  String toString(){
    return '$orderedItemId: ${ordersIds.toString()}';
  }
}

class DateProductIdOrdersId{
  final DateTime date;
  List<OrderedItemIdWithOrdersIds> itemsWithOrderIds;

  DateProductIdOrdersId({required this.date, required this.itemsWithOrderIds});

  @override
  String toString() {
    final items = itemsWithOrderIds.map((element)  => element.toString()).toString();

    return '$date $items';
  }

}