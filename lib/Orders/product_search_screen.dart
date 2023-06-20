import 'package:crafted_manager/Models/product_model.dart';
import 'package:flutter/material.dart';

class ProductSearchScreen extends StatefulWidget {
  final List<Product> products;

  const ProductSearchScreen({super.key, required this.products});

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Product> filteredProducts;
  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    filteredProducts = widget.products;
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = widget.products
          .where((product) =>
              product.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: Scaffold(
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
                  onChanged: _filterProducts,
                  decoration: const InputDecoration(
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
                      trailing:
                          Text('\$${filteredProducts[index].retailPrice}'),
                      onTap: () {
                        TextEditingController quantityController =
                            TextEditingController(text: '1');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add to Order'),
                              content: Column(
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
                                ],
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
