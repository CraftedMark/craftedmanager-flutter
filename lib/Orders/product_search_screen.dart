import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:crafted_manager/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/ordered_item_model.dart';
import '../../Models/product_model.dart';
import '../../Providers/product_provider.dart';
import '../widgets/big_button.dart';
import '../widgets/edit_product_alert.dart';

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      filteredProducts = Provider.of<ProductProvider>(context, listen: false).allProducts;
      setState(() {});
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    allProducts = Provider.of<ProductProvider>(context).allProducts;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: UIConstants.GREY_MEDIUM,
        title: const Text('Search Product'),
        bottom: searchField(context, _filterProducts)
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  var currentProduct = filteredProducts[index];
                  return _productTile(
                    name: currentProduct.name,
                    price: currentProduct.retailPrice,
                    description: currentProduct.description,
                    onTap: () {
                      final quantityCtrl = TextEditingController(text: '1');
                      final doseCtrl = TextEditingController(text: '0.1');
                      final flavorCtrl = TextEditingController(text: currentProduct.flavor);
                      final itemSourceCtrl = TextEditingController(text: currentProduct.itemSource);
                      final packagingCtrl = TextEditingController(text: currentProduct.packaging);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                       bool isNeedPacking = true;
                       return EditProductParamsAlert(
                         title: 'Add to Order',
                         rightButton: BigButton(
                           onPressed: () {
                             Navigator.pop(context);
                             Navigator.pop(
                               context,
                               {
                                 'product': filteredProducts[index],
                                 'quantity': int.parse(quantityCtrl.text),
                                 'dosage': double.parse(doseCtrl.text),
                                 'flavor': flavorCtrl.text,
                                 'itemSource': itemSourceCtrl.text,
                                 'packaging': packagingCtrl.text,
                               },
                             );
                           },
                           text: 'Add',
                         ),
                         children: [
                           StatefulBuilder (
                               builder: (context, changeState) {
                                 final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT);
                                 return SingleChildScrollView(
                                   physics: const BouncingScrollPhysics(),
                                   child: SizedBox(
                                     width: 1000,
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Text(
                                           filteredProducts[index].name,
                                           style: textStyle,
                                         ),
                                         const SizedBox(height: 12),
                                         Text(
                                           filteredProducts[index].description,
                                           style: textStyle,
                                         ),
                                         const SizedBox(height: 24),
                                         Row(
                                           children: [
                                             Flexible(
                                               child: TextInputField(
                                                 enabled: true,
                                                 controller: quantityCtrl,
                                                 keyboardType: TextInputType.number,
                                                 labelText: 'Quantity',
                                               ),
                                             ),
                                             const SizedBox(width: 8),
                                             Flexible(
                                               child: TextInputField(
                                                 enabled: true,
                                                 controller: doseCtrl,
                                                 keyboardType: TextInputType.number,
                                                 labelText: 'Dose',
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 8),
                                         TextInputField(
                                           controller: flavorCtrl,
                                           labelText: 'Flavor',
                                         ),
                                         const SizedBox(height: 8),
                                         TextInputField(
                                           controller: itemSourceCtrl,
                                           labelText: 'Item Source',
                                         ),
                                         Row(
                                           children: [
                                             Checkbox(
                                               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                               value: isNeedPacking,
                                               onChanged: (value){
                                                 isNeedPacking = !isNeedPacking;
                                                 changeState(() {});
                                               },
                                             ),
                                             Text('Packing',style: textStyle),
                                           ],
                                         ),
                                         TextInputField(
                                           enabled: isNeedPacking,
                                           labelText: 'Packaging',
                                           controller: packagingCtrl,
                                         ),
                                       ],
                                     ),
                                   ),
                                 );
                               }
                           )
                         ],
                       );
                      },
                    );
                  },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productTile(
      {required String name,
      required double price,
      required String description,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: UIConstants.DIVIDER_COLOR),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    name,
                    style: const TextStyle(color: UIConstants.WHITE_LIGHT),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Text(
                    '\$ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: UIConstants.WHITE_LIGHT),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
