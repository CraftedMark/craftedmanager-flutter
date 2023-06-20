import 'package:crafted_manager/CBP/cbp_db_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerPricingScreen extends StatefulWidget {
  final int customerId;

  const CustomerPricingScreen({super.key, required this.customerId});

  @override
  _CustomerPricingScreenState createState() => _CustomerPricingScreenState();
}

class _CustomerPricingScreenState extends State<CustomerPricingScreen> {
  late List<Map<String, dynamic>> _productPrices = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomPricing();
  }

  void _fetchCustomPricing() async {
    var results = await CustomerBasedPricingDbManager
        .instance
        .fetchCustomerBasedPricing(widget.customerId);
    setState(() {
      _productPrices = [results?? {}];
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Customer Based Pricing'),
        ),
        body: ListView.builder(
          itemCount: _productPrices.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                '${_productPrices[index]['product_name']}',
                style: TextStyle(
                    color: darkModeOn
                        ? CupertinoColors.white
                        : CupertinoColors.black),
              ),
              subtitle: Text(
                'Original Price: \$${_productPrices[index]['original_price']}, Custom Price: \$${_productPrices[index]['custom_price'] ?? 'N/A'}',
                style: TextStyle(
                    color: darkModeOn
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey3),
              ),
            );
          },
        ),
      ),
    );
  }
}
