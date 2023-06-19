import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/services/one_signal_api.dart';
import 'package:flutter/material.dart';

import '../../Orders/orders_db_manager.dart';
import '../CBP/cbp_db_manager.dart';

class CreateOrderScreen extends StatefulWidget {
  final People client;

  CreateOrderScreen({required this.client});

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  List<OrderedItem> orderedItems = [];
  double shippingCost = 10.0; // Default shipping cost

  Future<double?> getCustomProductPrice(int productId, int customerId) async {
    double? customPrice;
    // Fetch the customer's assigned pricing list id
    int? pricingListId = await CustomerBasedPricingDbManager.instance
        .getPricingListByCustomerId(customerId);

    print(
        'Fetched pricingListId: $pricingListId'); // Print the fetched pricingListId

    if (pricingListId != null) {
      // Fetch the custom pricing for the product based on the pricing list id
      Map<String, dynamic>? pricingData = await CustomerBasedPricingDbManager
          .instance
          .getCustomerProductPricing(productId, pricingListId);

      print(
          'Fetched pricingData: $pricingData'); // Print the fetched pricingData

      if (pricingData != null) {
        customPrice = pricingData['price'];
      }
    }

    print('Custom Price: $customPrice'); // Print the custom price
    return customPrice;
  }

  Future<void> addOrderedItem(
      Product product, int quantity, String item_source) async {
    // Fetch custom price for the product if it exists
    double? customPrice =
        await getCustomProductPrice(product.id!, widget.client.id);

    var newOrderItemStatus = 'Processing - Pending Payment';

    setState(() {
      orderedItems.add(OrderedItem(
        id: orderedItems.length + 1,
        orderId: 0,
        productName: product.name,
        productId: product.id!,
        name: product.name,
        quantity: quantity,
        price: customPrice ?? product.retailPrice,
        // check this line
        discount: 0,
        productDescription: product.description,
        productRetailPrice: product.retailPrice,
        status: newOrderItemStatus,
        itemSource: item_source,
      ));
    });
  }

  Future<void> saveOrder() async {
    double subTotal = orderedItems.fold(
      0.0,
      (prev, current) => prev + (current.price * current.quantity),
    );
    double totalAmount = subTotal + shippingCost;

    // Create a new Order instance with the necessary values from the People model
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch,
      customerId: widget.client.id.toString(),
      // Convert customerId to String
      orderDate: DateTime.now(),
      shippingAddress:
          '${widget.client.address1}, ${widget.client.city},${widget.client.state},${widget.client.zip}',
      billingAddress:
          '${widget.client.address1},${widget.client.city},${widget.client.state},${widget.client.zip}',
      productName: orderedItems.map((e) => e.productName).toList().join(','),
      // Convert the list of product names to a comma-separated string
      totalAmount: totalAmount,
      orderStatus: 'Pending',
      notes: '',
      archived: false,
    );

    Future<void> createOrder(
        Order order, List<OrderedItem> orderedItems) async {
      print("Creating new order...");
      print("Order data: ${newOrder.toMap()}");
      print(
          "Ordered items data: ${orderedItems.map((e) => e.toMap()).toList()}");

      // await OrderPostgres().createOrder(newOrder, orderedItems);
      await WooSignalService.createOrder(newOrder, orderedItems);
    }

    await createOrder(newOrder, orderedItems);
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
    void updateOrderedItemPrice(int index, double newPrice) {
      setState(() {
        orderedItems[index].price = newPrice;
      });
    }

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
            behavior: HitTestBehavior.opaque,
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
                    // Add the 'return' statement here
                    title: Text(orderedItems[index].productName),
                    trailing: Text('\$${orderedItems[index].price}'),
                    // Use 'price' instead of 'productRetailPrice'
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qty: ${orderedItems[index].quantity}'),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                int updatedQuantity =
                                    orderedItems[index].quantity;
                                TextEditingController quantityController =
                                    TextEditingController(
                                        text: orderedItems[index]
                                            .quantity
                                            .toString());
                                // Add TextEditingController for the price
                                TextEditingController priceController =
                                    TextEditingController(
                                        text: orderedItems[index]
                                            .price
                                            .toString());
                                return AlertDialog(
                                  title: const Text('Edit Quantity and Price'),
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
                                          // Update the price of the ordered item
                                          orderedItems[index].price =
                                              double.parse(
                                                  priceController.text);
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

  void addItemToOrder () async {
    // final products =  await awaitProductPostgres.getAllProductsExceptIngredients();
    final products =  await WooSignalService.getProducts();


    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController searchController =
        TextEditingController();
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(25.0)),
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
      final quantity = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Quantity'),
            content: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
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
                  Navigator.pop(
                    context,
                    int.parse(quantityController.text),
                  );
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );

      if (quantity != null) {
        await addOrderedItem(selectedProduct, quantity, 'created');
      }

    }
  }
}
