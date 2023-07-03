import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:crafted_manager/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/ordered_item_model.dart';
import '../../Models/product_model.dart';
import '../../Providers/product_provider.dart';
import '../widgets/big_button.dart';

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
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return _productTile(
                    name: filteredProducts[index].name,
                    price: filteredProducts[index].retailPrice,
                    description: filteredProducts[index].description,
                    onTap: () {
                      TextEditingController quantityController =
                          TextEditingController(text: '1');
                          TextEditingController itemSourceController =
                          TextEditingController(text: '');
                          TextEditingController packagingController =
                          TextEditingController(text: '');
                          TextEditingController doseController =
                          TextEditingController(text: '0.1');
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                       bool isNeedPacking = true;
                        return AlertDialog(
                          insetPadding: const EdgeInsets.fromLTRB(8,0,8,24),
                          contentPadding: EdgeInsets.zero,
                          actionsPadding: const EdgeInsets.all(24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: UIConstants.GREY_LIGHT,
                          title: Text('Add to Order', style: Theme.of(context).textTheme.titleMedium,),
                          content: StatefulBuilder (
                              builder: (context, changeState) {
                                final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT);
                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
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
                                                controller: quantityController,
                                                keyboardType: TextInputType.number,
                                                labelText: 'Quantity',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Flexible(
                                              child: TextInputField(
                                                enabled: true,
                                                controller: doseController,
                                                keyboardType: TextInputType.number,
                                                labelText: 'Dose',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextInputField(
                                          enabled: true,
                                          controller: itemSourceController,
                                          labelText: 'Item Source',
                                        ),
                                        const SizedBox(height: 16),
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

                                        const SizedBox(height: 16),
                                        TextInputField(
                                          enabled: isNeedPacking,
                                          labelText: 'Packaging',
                                          controller: packagingController,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                          actions: [
                            Row(
                              children: [
                                Flexible(
                                  child: BigButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    text: 'Cancel',
                                    color: UIConstants.GREY,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: BigButton(
                                    onPressed: () {
                                      selectedQuantity =
                                          int.parse(quantityController.text);
                                      final orderedItem = OrderedItem(
                                        orderId: 'order_id',
                                        // Replace with the actual order ID
                                        product: filteredProducts[index],
                                        // this is the required product object
                                        productName: filteredProducts[index].name,
                                        productId:
                                        filteredProducts[index].id ?? 0,
                                        name: filteredProducts[index].name,
                                        quantity: selectedQuantity,
                                        price:
                                        filteredProducts[index].retailPrice,
                                        discount: 0.0,
                                        productDescription:
                                        filteredProducts[index].description,
                                        productRetailPrice:
                                        filteredProducts[index].retailPrice,
                                        status: 'status',
                                        // replace this with your actual status
                                        itemSource: itemSourceController.text,
                                        packaging: packagingController.text,
                                        flavor: '',
                                        // replace this with your actual flavor
                                        dose: double.parse(doseController.text),
                                      );
                                      // Provider.of<OrderProvider>(context,
                                      //         listen: false)
                                      //     .addOrderedItem(orderedItem);
                                      Navigator.pop(context);
                                      Navigator.pop(
                                        context,
                                        {
                                          'product': filteredProducts[index],
                                          'quantity': selectedQuantity,
                                        },
                                      );
                                    },
                                    text: 'Add to Order',
                                  ),
                                ),
                              ],
                            ),
                            
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
