import 'package:crafted_manager/assets/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/ordered_item_model.dart';
import '../../Models/product_model.dart';
import '../../Providers/order_provider.dart';
import '../../Providers/product_provider.dart';
import '../Products/product_db_manager.dart';


class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Product> filteredProducts = [];
  int selectedQuantity = 1;

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = Provider.of<ProductProvider>(context, listen: false)
          .allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    filteredProducts = Provider.of<ProductProvider>(context).allProducts;
    return  Scaffold(
        appBar: AppBar(
            title: const Text('Search Product'),
            bottom: PreferredSize(
              preferredSize: const Size(double.infinity, 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    // prefix: Icon(Icons.search),
                    labelText: 'Search product',
                    enabledBorder: UIConstants.FIELD_BORDER
                  ),
                ),
              ),
            ),
        ),
        body: SafeArea(
          child: ColoredBox(
            color: Colors.transparent,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredProducts[index].name),
                        subtitle: Text(filteredProducts[index].description),
                        trailing:
                            Text('\$${filteredProducts[index].retailPrice}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController quantityController =
                                  TextEditingController(text: '1');
                              TextEditingController itemSourceController =
                                  TextEditingController(text: '');
                              TextEditingController packagingController =
                                  TextEditingController(text: '');
                              TextEditingController doseController =
                                  TextEditingController(text: '0.1');

                              return AlertDialog(
                                title: const Text('Add to Order'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(filteredProducts[index].name),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: quantityController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Quantity',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: itemSourceController,
                                        decoration: InputDecoration(
                                          labelText: 'Item Source',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: packagingController,
                                        decoration: InputDecoration(
                                          labelText: 'Packaging',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: doseController,
                                        decoration: InputDecoration(
                                          labelText: 'Dose',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
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
                                    child: const Text("Add to Order"),
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
        ),
    );
  }
}
