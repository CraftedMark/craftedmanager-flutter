import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:crafted_manager/Products/product_detail.dart';
import 'package:flutter/material.dart';

import '../WooCommerce/woosignal-service.dart';

// Add this function right below import statements
String indexToType(int index) {
  switch (index) {
    case 0:
      return 'Product';
    case 1:
      return 'Service';
    case 2:
      return 'Ingredient';
    case 3:
      return 'Assembly';
    default:
      return 'Unknown';
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _products;
  int _currentSegmentIndex = 0;
  final TextStyle textStyle = const TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    _products = Future.value([]);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    // _products = WooSignalService.getProducts();//TODO: enable WooSignal
    // setState(() {});
    _products = ProductPostgres.getAllProducts(indexToType(_currentSegmentIndex));
    _products.then((value) {
      setState(() {
        _products = Future.value(value); // Update the products list.
      });
    });
  }

  void createNewProduct() {
    // Configure the new product based on the current segment index.
    Product newProduct = Product(
        id: 0,
        name: 'Unknown Product',
        retailPrice: 0,
        type: indexToType(_currentSegmentIndex),
        assemblyItems: []);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: newProduct,
          isNewProduct: true,
          onProductSaved: () {
            // Refresh product list after adding a new product
            _fetchProducts();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('Products List', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: createNewProduct,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: DropdownButton<int>(
                    value: _currentSegmentIndex,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(
                          () {
                            _currentSegmentIndex = newValue;
                            _fetchProducts();
                          },
                        );
                      }
                    },
                    underline: const SizedBox.shrink(),
                    dropdownColor: Colors.grey.shade800,
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('Products', style: textStyle),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Services', style: textStyle),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Ingredients', style: textStyle),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Assembly Items', style: textStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return ListTile(
                          tileColor: const Color(0xFF2C2C2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          subtitle: Text(
                            'Retail Price: \$${product.retailPrice}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  product: product,
                                  onProductSaved: () {
                                    // Refresh product list after updating a product
                                    _fetchProducts();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
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
