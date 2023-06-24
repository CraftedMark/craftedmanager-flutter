import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:crafted_manager/services/one_signal_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Orders/orders_db_manager.dart';
import '../CBP/cbp_db_manager.dart';
import '../Providers/order_provider.dart';

class CreateOrderScreen extends StatefulWidget {
  final People client;

  CreateOrderScreen({required this.client});

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  List<OrderedItem> orderedItems = [];
  double shippingCost = 10;

  Future<double?> getCustomProductPrice(
      int productId, String customerId) async {
    double? customPrice;
    String? pricingListId = (await CustomerBasedPricingDbManager.instance
        .getPricingListByCustomerId(customerId)) as String?;

    if (pricingListId != null) {
      Map<String, dynamic>? pricingData = await CustomerBasedPricingDbManager
          .instance
          .getCustomerProductPricing(productId, pricingListId as int);

      if (pricingData != null) {
        customPrice = pricingData['price'];
      }
    }

    return customPrice;
  }

  Future<void> addOrderedItem(Product product, int quantity, String itemSource,
      String flavor, double dose, String packaging) async {
    double? customPrice =
        await getCustomProductPrice(product.id!, widget.client.id);

    var newOrderItemStatus = 'Processing - Pending Payment';

    setState(() {
      orderedItems.add(OrderedItem(
          id: (orderedItems.length + 1).toString(),
          // Convert the entire expression to a String
          orderId: "0",
          productName: product.name,
          productId: product.id!,
          name: product.name,
          quantity: quantity,
          price: customPrice ?? product.retailPrice,
          discount: 0.0,
          productDescription: product.description,
          productRetailPrice: product.retailPrice,
          status: newOrderItemStatus,
          itemSource:
              itemSource.isNotEmpty ? itemSource : product.itemSource ?? '',
          packaging: packaging,
          flavor: flavor,
          dose: dose));
    });
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

    final newOrder = Order(
      customerId: widget.client.id.toString(),
      id: orderId,
      orderDate: DateTime.now(),
      shippingAddress:
          '${widget.client.address1 ?? ""}, ${widget.client.city ?? ""},${widget.client.state ?? ""},${widget.client.zip ?? ""}',
      billingAddress:
          '${widget.client.address1 ?? ""},${widget.client.city ?? ""},${widget.client.state ?? ""},${widget.client.zip ?? ""}',
      productName: orderedItems.map((e) => e.productName).toList().join(','),
      totalAmount: totalAmount,
      orderStatus: 'Pending',
      notes: '',
      archived: false,
      orderedItems: orderedItems,
    );

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await OrderPostgres().createOrder(newOrder, orderedItems);
    sendNewOrderNotification();
  }

  Future<void> sendNewOrderNotification() async {
    var customerFullName =
        "${widget.client.firstName} ${widget.client.lastName}";
    var payload = "New order from: $customerFullName";

    await OneSignalAPI.sendNotification(payload);
  }

  @override
  Widget build(BuildContext context) {
    double subTotal = orderedItems.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.productRetailPrice * element.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.lightBlue,
          ),
        ),
        title: const Text('Create Order'),
        backgroundColor: Colors.black,
        actions: [
          GestureDetector(
            onTap: () async {
              await saveOrder();
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Save Order",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () => addItemToOrder(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: const Text('Add Item'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orderedItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(orderedItems[index].productName),
                    trailing: Text('\$${orderedItems[index].price}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Qty: ${orderedItems[index].quantity}, Flavor: ${orderedItems[index].flavor}, Dosage: ${orderedItems[index].dose}, Packaging: ${orderedItems[index].packaging}'),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                var updatedQuantity =
                                    orderedItems[index].quantity;
                                var quantityController = TextEditingController(
                                    text: orderedItems[index]
                                        .quantity
                                        .toString());

                                var priceController = TextEditingController(
                                    text: orderedItems[index].price.toString());

                                var packagingController = TextEditingController(
                                    text: orderedItems[index].packaging);

                                var flavorController = TextEditingController(
                                    text: orderedItems[index].flavor);

                                var dosageController = TextEditingController(
                                    text: orderedItems[index].dose.toString() ??
                                        '');

                                return AlertDialog(
                                  title: const Text(
                                      'Edit Quantity, Price, Flavor, Dosage and Packaging'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: quantityController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Quantity',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: flavorController,
                                        decoration: const InputDecoration(
                                          labelText: 'Flavor',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: dosageController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Dosage',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: packagingController,
                                        decoration: const InputDecoration(
                                          labelText: 'Packaging',
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
                                        setState(() {
                                          orderedItems[index].quantity =
                                              int.parse(
                                                  quantityController.text);
                                          orderedItems[index].price =
                                              double.parse(
                                                  priceController.text);
                                          orderedItems[index].packaging =
                                              packagingController.text;
                                          orderedItems[index].flavor =
                                              flavorController.text;
                                          orderedItems[index].dose =
                                              double.parse(
                                                  dosageController.text);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addItemToOrder() async {
    final products = await ProductPostgres.getAllProductsExceptIngredients();

    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController = TextEditingController();
        List<Product> filteredProducts = products;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SimpleDialog(
              title: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search",
                      hintText: "Search products",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredProducts = products
                            .where((product) => product.name
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                ],
              ),
              children: filteredProducts.map((product) {
                return ListTile(
                  title: Text(product.name),
                  onTap: () {
                    Navigator.pop(context, product);
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );

    if (selectedProduct != null) {
      var quantityController = TextEditingController(text: '1');
      var itemSourceController =
          TextEditingController(text: selectedProduct.itemSource ?? '');
      var flavorController =
          TextEditingController(text: selectedProduct.flavor ?? '');
      var dosageController =
          TextEditingController(text: (selectedProduct.dose?.toString() ?? ''));
      var packagingController = TextEditingController(
          text: (selectedProduct.packaging?.toString() ?? ''));

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
                'Enter Quantity, Item Source, Flavor, Dosage and Packaging'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: itemSourceController,
                  decoration: const InputDecoration(
                    labelText: 'Item Source',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: flavorController, // Added flavor input
                  decoration: const InputDecoration(
                    labelText: 'Flavor',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: dosageController, // Added dosage input
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: packagingController,
                  decoration: const InputDecoration(
                    labelText: 'Packaging',
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
                  Navigator.pop(
                    context,
                    {
                      'quantity': int.parse(quantityController.text),
                      'itemSource': itemSourceController.text,
                      'packaging': packagingController.text,
                      'dosage': dosageController.text, // Added this
                      'flavor': flavorController.text, // Added this
                    },
                  );
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );

      if (result != null) {
        int quantity = result['quantity'];
        String itemSource = result['itemSource'];
        String packaging = result['packaging'] ?? '';
        double dose = double.tryParse(result['dosage'] ?? '') ?? 0.0;
        String flavor = result['flavor'] ?? '';

        await addOrderedItem(
            selectedProduct, // First argument
            quantity, // Second argument
            itemSource, // Third argument
            flavor, // Fourth argument
            dose, // Fifth argument
            packaging // Sixth argument
            );
      }
    }
  }
}
