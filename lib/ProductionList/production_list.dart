import 'package:crafted_manager/Models/ordered_item_model.dart';
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
                  : filteredItems.isNotEmpty
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
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        OrderedItem item = filteredItems[index];
        return _ProductionListItem(item: item);
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
  const _ProductionListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tile(
      height: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}


