import 'package:crafted_manager/CBP/cbp_db_manager.dart';
import 'package:flutter/material.dart';

class CustomerPricingListScreen extends StatefulWidget {
  final String customerId;

  const CustomerPricingListScreen({super.key, required this.customerId});

  @override
  _CustomerPricingListScreenState createState() =>
      _CustomerPricingListScreenState();
}

class _CustomerPricingListScreenState extends State<CustomerPricingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  int? _pricingListId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      _pricingListId = (await CustomerBasedPricingDbManager.instance
          .getPricingListIdByCustomerId(widget.customerId)) as int?;
    });
  }

  void _searchProducts() async {
    List<Map<String, dynamic>> results =
        await CustomerBasedPricingDbManager.instance.search(
            'products',
            'product_name ILIKE @searchText',
            {'searchText': '%${_searchController.text}%'});

    setState(() {
      _searchResults = results.map((result) {
        Map<String, dynamic> product = result['products'];
        return {
          'id': product['product_id'],
          'product_name': product['product_name'],
          'retail_price': product['retail_price'],
        };
      }).toList();
    });
  }

  Future<void> _showPriceInputDialog(
      BuildContext context, int productId) async {
    final TextEditingController priceController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter New Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                double newPrice = double.tryParse(priceController.text) ?? 0;
                if (newPrice > 0) {
                  print(
                      'Saving new price: $newPrice for product: $productId and customer: ${widget.customerId}');
                  await CustomerBasedPricingDbManager.instance
                      .addOrUpdateCustomerProductPricing(
                    productId: productId,
                    customerId: widget.customerId,
                    price: newPrice,
                  );
                  setState(() {
                    _searchProducts();
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Pricing List'),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _searchProducts(),
                decoration: const InputDecoration(
                  labelText: 'Search Product',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> product = _searchResults[index];
                  String productName =
                      product['product_name'] ?? 'Unknown Product';
                  String? retailPriceStr = product['retail_price'];
                  double? originalPrice = retailPriceStr != null
                      ? double.tryParse(retailPriceStr)
                      : null;

                  return ListTile(
                    title: Text(productName),
                    subtitle: Text('Original Price: ${originalPrice ?? 'N/A'}'),
                    onTap: () {
                      int? productId = product['id'];
                      if (productId != null) {
                        _showPriceInputDialog(context, productId);
                      }
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
