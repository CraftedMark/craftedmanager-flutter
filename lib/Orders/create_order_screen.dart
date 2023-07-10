import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Orders/product_search_screen.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:crafted_manager/Providers/people_provider.dart';
import 'package:crafted_manager/Providers/product_provider.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/config.dart';
import 'package:crafted_manager/widgets/big_button.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/edit_button.dart';
import 'package:crafted_manager/widgets/save_button.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:crafted_manager/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/order_provider.dart';
import '../widgets/edit_product_alert.dart';
import '../widgets/tile.dart';

class CreateOrderScreen extends StatefulWidget {
  final People client;

  const CreateOrderScreen({super.key, required this.client});

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  List<OrderedItem> orderedItems = [];
  double shippingCost = 10;

  Future<void> onSaveButtonPressed() async{
    await saveOrder();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void onEditButtonPressed(int orderedItemIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final item = orderedItems[orderedItemIndex];
        var quantityCtrl = TextEditingController(text: '${item.quantity}');
        var priceCtrl = TextEditingController(text: '${item.price}');
        var dosageCtrl = TextEditingController(text: '${item.dose}');
        var flavorCtrl = TextEditingController(text: item.flavor);
        var packagingCtrl = TextEditingController(text: item.packaging);

        return EditProductParamsAlert(
          title:'Edit Ordered Item',
          rightButton: BigButton(
            text: 'Edit',
            onPressed: () {
              item.quantity = int.parse(quantityCtrl.text);
              item.price = double.parse(priceCtrl.text);
              item.flavor = flavorCtrl.text;
              item.dose = double.parse(dosageCtrl.text);
              item.packaging = packagingCtrl.text;
              setState(() {});
              Navigator.pop(context);
            },
          ),
          children: [
            Row(
              children: [
                Flexible(
                  child: TextInputField(
                    labelText: 'Quantity',
                    controller: quantityCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextInputField(
                    controller: dosageCtrl,
                    keyboardType: TextInputType.number,
                    labelText: 'Dosage',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextInputField(
              labelText: 'Price',
              controller: priceCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextInputField(
              labelText: 'Flavor',
              controller: flavorCtrl,
            ),
            const SizedBox(height: 8),
            TextInputField(
              labelText: 'Packaging',
              controller: packagingCtrl,
            ),
          ],
        );
      },
    );
  }



  Future<void> saveOrder() async {
    double subTotal = orderedItems.fold(
      0.0,
      (prev, current) => prev + (current.price * current.quantity),
    );
    double totalAmount = subTotal + shippingCost;

    final orderId = uuid.v4();

    for (var item in orderedItems) {
      item.orderId = orderId;
    }
    print("new orderid = $orderId");

    // Fetch address fields from the database
    Map<String, dynamic>? addressFields =
        await Provider.of<PeopleProvider>(context, listen: false)
            .getUserAddressById(widget.client.id);

    if (addressFields != null) {
      final newOrder = Order(
        customerId: widget.client.id.toString(),
        id: orderId,
        orderDate: DateTime.now(),
        shippingAddress:
            '${addressFields['address1']}, ${addressFields['city']},${addressFields['state']},${addressFields['zip']}',
        billingAddress:
            '${addressFields['address1']},${addressFields['city']},${addressFields['state']},${addressFields['zip']}',
        productName: orderedItems.map((e) => e.productName).toList().join(','),
        totalAmount: totalAmount,
        orderStatus: 'Pending',
        notes: '',
        archived: false,
        orderedItems: orderedItems,
      );
      Provider.of<OrderProvider>(context, listen: false)
          .createOrder(newOrder, widget.client);
    } else {
      // Handle the case when addressFields are null
      print("Error: Address fields are null.");
    }
  }

  Future<void> onAddButtonPressed() async {
    final result = await getProductFromUser();

    if (result == null) {return;}

    await addOrderedItemToOrder(result);
  }

  Future<Map<String, dynamic>?> getProductFromUser() async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchScreen(),
      ),
    );
  }

  Future<void> addOrderedItemToOrder(Map<String, dynamic> orderedItemMap) async {
    // double? customPrice = await CustomerBasedPricingDbManager.instance
    //     .getCustomProductPrice(product.id!, widget.client.id);

    final product = orderedItemMap['product'] as Product;
    final String itemSource = orderedItemMap['itemSource'];
    var newOrderItemStatus = 'Processing - Pending Payment';

    orderedItems.add(OrderedItem(
        orderId: "0",
        productName: product.name,
        productId: product.id!,
        name: product.name,
        price: product
            .retailPrice, //customPrice ?? product.retailPrice, TODO:FIX
        discount: 0.0,
        productDescription: product.description,
        productRetailPrice: product.retailPrice,
        status: newOrderItemStatus,

        quantity: orderedItemMap['quantity'],
        itemSource:
        itemSource.isNotEmpty ? itemSource : product.itemSource,
        flavor: orderedItemMap['flavor'],
        dose: orderedItemMap['dosage'],
        packaging: orderedItemMap['packaging'],

        product: product)); // Pass an actual product instance instead of null
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Order'),
        actions: [if(orderedItems.isNotEmpty)SaveButton(onPressed: onSaveButtonPressed)],//Disable 'Save' button while orderedItems is empty
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: _listOfOrderedItem()),
              BigButton(text: 'Add Item', onPressed: onAddButtonPressed),
              const SizedBox(height: 16),
              _orderCostWidget()
            ],
          ),
        ),
      ),
    );
  }


  Widget _listOfOrderedItem() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: orderedItems.length,
      itemBuilder: (context, index) {
        return Tile(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderedItems[index].productName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        'Qty: ${orderedItems[index].quantity}, Flavor: ${orderedItems[index].flavor}, Dosage: ${orderedItems[index].dose}, Pack: ${orderedItems[index].packaging}'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('\$ ${orderedItems[index].price}'),
                  EditButton(onPressed: ()=>onEditButtonPressed(index)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderCostWidget() {
    double subTotal = orderedItems.fold(
      0.0,
      (prev, element) => prev + (element.productRetailPrice * element.quantity),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal:'),
            Text('\$${subTotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Shipping:'),
            Text('\$${shippingCost.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:'),
            Text('\$${(subTotal + shippingCost).toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }
}
