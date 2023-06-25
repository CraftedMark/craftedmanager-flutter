import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/ordered_item_model.dart';
import '../../Models/product_model.dart';
import '../../Providers/order_provider.dart';
import '../../Providers/product_provider.dart';

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Product> filteredProducts = [];
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Product'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _filterProducts(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search product',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredProducts[index].name),
                    subtitle: Text(filteredProducts[index].description),
                    trailing: Text('\$${filteredProducts[index].retailPrice}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController quantityController =
                              TextEditingController(text: '1');
                          TextEditingController itemSourceController =
                              TextEditingController();
                          TextEditingController packagingController =
                              TextEditingController();
                          TextEditingController doseController =
                              TextEditingController();

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
                                    decoration: InputDecoration(
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
                                    id: DateTime.now().toString(),
                                    orderId: 'order_id',
                                    // Replace with the actual order ID
                                    productName: filteredProducts[index].name,
                                    productId: filteredProducts[index].id ?? 0,
                                    name: filteredProducts[index].name,
                                    quantity: selectedQuantity,
                                    price: filteredProducts[index].retailPrice,
                                    discount: 0,
                                    productDescription:
                                        filteredProducts[index].description,
                                    productRetailPrice:
                                        filteredProducts[index].retailPrice,
                                    status: 'status',
                                    itemSource: itemSourceController.text,
                                    packaging: packagingController.text,
                                    dose: double.parse(doseController.text),
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .addOrderedItem('order_id',
                                          orderedItem); // Replace with the actual order ID
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
    );
  }
}
