import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list_details.dart';
import 'package:crafted_manager/Providers/order_provider.dart';
import 'package:crafted_manager/Providers/product_provider.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/main.dart';
import 'package:crafted_manager/widgets/alert.dart';
import 'package:crafted_manager/widgets/big_button.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:crafted_manager/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../Models/order_model.dart';
import '../config.dart';
import '../services/one_signal_api.dart';
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



  void groupOrderedItems(){
    if(filteredItems.isEmpty) {
      return;
    }
    final dateWithOrderedItems = getDateWithOrderedItemsSorted();

    //create list of ProductId:[OrderId,..]
    var listOfOrdersGroupedByOrderedItemId = dateWithOrderedItems.map((e) => createOrderedItemWithOrdersId(List.from(e.orderedItems))).toList();

    List<DateProductIdOrdersId> result = [];
    for(int i= 0; i<dateWithOrderedItems.length; i++){
      final date = dateWithOrderedItems[i].date;
      final productIdWithOrdersIds = listOfOrdersGroupedByOrderedItemId[i];
      result.add(DateProductIdOrdersId(date: date, itemsWithOrderIds: productIdWithOrdersIds));
    }

    sortedByDateAndGroupedByProductIdsOrders = result;
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

  List<OrderedItemWithOrdersIds> createOrderedItemWithOrdersId(List<OrderedItem> items) {
    items.sort((a, b) => a.productId.compareTo(b.productId));

    var productIdWithOrdersIds = <int, Set<String>>{};
    for (final i in items) {
      final key = i.productId;
      if (productIdWithOrdersIds.containsKey(key)) {
        productIdWithOrdersIds.update(key, (value) => {...value, i.orderId});
      } else {
        productIdWithOrdersIds.addAll({
          key: {i.orderId}
        });
      }
    }

    var groupedItems = getGroupedByProductIdAndFlavor(items);


    return List.generate(groupedItems.length, (index) {
      final item = groupedItems[index];
      final itemShort = OrderedItemShort(productId: item.productId,name: item.name, flavor: item.flavor, quantity: item.quantity);
      var ordersIds = productIdWithOrdersIds[item.productId]!;
      return OrderedItemWithOrdersIds(orderedItemShort: itemShort, ordersIds: ordersIds);
    });


    ///Create a list with elements: { orderedItemId : orderId, orderId.. }

    //uniq ordered items ids
    // var map = <int, Set<String>>{};
    // for (final i in items) {
    //   final key = i.productId;
    //   if (map.containsKey(key)) {
    //     map.update(key, (value) => {...value, i.orderId});
    //   } else {
    //     map.addAll({
    //       key: {i.orderId}
    //     });
    //   }
    // }


    // return map.entries.map(
    //         (e) => OrderedItemIdWithOrdersIds(
    //         orderedItemId: e.key,
    //         ordersIds: e.value
    //     )
    // ).toList();
  }

  List<OrderedItem> getGroupedByProductIdAndFlavor(List<OrderedItem> items){
    List<OrderedItem> groupedItems = [];

    for(int i = 0; i<items.length; i++){
      var currentItem = items[i];
      var sameProducts = items.where((p) => p.productId == currentItem.productId && p.flavor == currentItem.flavor).skip(1);
      if(sameProducts.isNotEmpty){
        final additionQuantity = sameProducts.fold(0, (prev, item) => prev += item.quantity);
        groupedItems.add(currentItem.copyWith(quantity: currentItem.quantity+additionQuantity));
        items.removeWhere((p) =>  p.productId == currentItem.productId && p.flavor == currentItem.flavor);
      }
      else{
        groupedItems.add(currentItem);
      }
    }

    return groupedItems;

  }

  void search(OrderProvider provider, String query) {
    provider.filterOrderedItems(query);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).filterOrderedItems('');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (_, provider, __) {
        openOrders = provider.openOrders;
        filteredItems = provider.filteredOrderedItems;
        groupOrderedItems();
        return Scaffold(
          appBar: AppBar(
            leading: _AppBarMenuButton(menuKey: widget._sliderDrawerKey),
            title: Text(
              'Production List',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: [
              TextButton(
                child: Text('test'),
                onPressed: (){
                  OneSignalAPI.sendNotificationWithData();
                },
              )
            ],
            bottom: searchField(
              context,
              (query)=>search(provider, query),
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
                  productIdWithOrdersIds.orderedItemShort,
                  productIdWithOrdersIds.ordersIds.toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _itemWidget(OrderedItemShort item, List<String> ordersId, ){

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: UIConstants.GREY_LIGHT,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductionListDetails(
                productName: item.name,
                productId: item.productId,
                ordersIds: ordersId,
                flavor: item.flavor,
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
                      item.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: UIConstants.WHITE_LIGHT),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Product ID: ${item.productId}'),
                  const SizedBox(height: 4),
                  Text('Flavor: ${item.flavor}'),
                  const SizedBox(height: 4),
                  Text('Quantity: ${item.quantity}'),


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

class OrderedItemWithOrdersIds{
  final OrderedItemShort orderedItemShort;
  final Set<String> ordersIds;

  OrderedItemWithOrdersIds({
    required this.orderedItemShort,
    required this.ordersIds,
  });
  @override
  String toString(){
    return '${orderedItemShort.productId}: ${ordersIds.toString()}';
  }
}

class OrderedItemShort{
  final int productId;
  final String flavor;
  int quantity;
  final String name;

  OrderedItemShort({
    required this.productId,
    required this.flavor,
    required this.quantity,
    required this.name,
  });
}

class DateProductIdOrdersId{
  final DateTime date;
  List<OrderedItemWithOrdersIds> itemsWithOrderIds;

  DateProductIdOrdersId({required this.date, required this.itemsWithOrderIds});

  @override
  String toString() {
    final items = itemsWithOrderIds.map((element)  => element.toString()).toString();

    return '$date $items';
  }

}
