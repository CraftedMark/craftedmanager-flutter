import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../../Orders/orders_db_manager.dart';
import 'product_search_screen.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  final List<OrderedItem> orderedItems;
  final People customer;
  final List<Product> products;

  EditOrderScreen({
    required this.order,
    required this.orderedItems,
    required this.customer,
    required this.products,
  });

  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late List<OrderedItem> _orderedItems;
  double _subTotal = 0.0;
  String _status = '';
  EasyRefreshController _controller = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    _orderedItems = List.from(widget.orderedItems);
    _subTotal = calculateSubtotal();
    _status = widget.order.orderStatus;
    if (!['Pending', 'In-Progress', 'Completed'].contains(_status)) {
      _status = 'Pending';
    }
  }

  double calculateSubtotal() {
    return _orderedItems.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.price * element.quantity),
    );
  }

  void editOrderedItem(int index) {
    if (_orderedItems[index].quantity > 1) {
      setState(() {
        _orderedItems[index] = _orderedItems[index].copyWith(
          quantity: _orderedItems[index].quantity - 1,
        );
        _subTotal = calculateSubtotal();
      });
    } else {
      setState(() {
        _orderedItems.removeAt(index);
        _subTotal = calculateSubtotal();
      });
    }
  }

  void addOrderedItem(Product product, int quantity, String itemSource) {
    //TODO: replace by variable
    var newOrderItemStatus = 'Processing - Pending Payment';

    int existingIndex = _orderedItems
        .indexWhere((orderedItem) => orderedItem.productId == product.id);

    if (existingIndex != -1) {
      setState(() {
        _orderedItems[existingIndex] = _orderedItems[existingIndex].copyWith(
          quantity: _orderedItems[existingIndex].quantity + quantity,
        );
        _subTotal = calculateSubtotal();
      });
    } else {
      setState(() {
        _orderedItems.add(OrderedItem(
          id: _orderedItems.length + 1,
          orderId: widget.order.id,
          productName: product.name,
          productId: product.id!,
          name: product.name,
          quantity: quantity,
          price: product.retailPrice,
          discount: 0,
          productDescription: product.description,
          productRetailPrice: product.retailPrice,
          status: newOrderItemStatus,
          itemSource: itemSource, // Add the item_source field here
        ));
        _subTotal = calculateSubtotal();
      });
    }
  }

  Future<Order?> updateOrder() async {
    Order updatedOrder = widget.order.copyWith(
      totalAmount: _subTotal,
      orderStatus: _status,
    );

    final result = await OrderPostgres.updateOrder(updatedOrder, _orderedItems);

    if (result) {
      return updatedOrder;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Order'),
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
              onTap: () async {
                final updatedOrder = await updateOrder();

                if (updatedOrder != null) {
                  Navigator.pop(context, updatedOrder);
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Failed to update order."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order information',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Customer:',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                      initialValue: widget.customer.firstName +
                          ' ' +
                          widget.customer.lastName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () async {
                    List<Product> products =
                        await ProductPostgres.getAllProductsExceptIngredients();

                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (BuildContext context) =>
                          ProductSearchScreen(products: products),
                    );

                    if (result != null) {
                      addOrderedItem(result['product'], result['quantity'],
                          'Your item source here');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: const Text('Add Item'),
                ),
              ),
              SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderedItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _orderedItems[index].productName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue:
                                  _orderedItems[index].quantity.toString(),
                              onChanged: (value) {
                                int newQuantity = int.tryParse(value) ?? 0;
                                setState(() {
                                  _orderedItems[index] =
                                      _orderedItems[index].copyWith(
                                    quantity: newQuantity,
                                  );
                                  _subTotal = calculateSubtotal();
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue:
                                  _orderedItems[index].price.toString(),
                              onChanged: (value) {
                                double newPrice = double.tryParse(value) ?? 0.0;
                                setState(() {
                                  _orderedItems[index] =
                                      _orderedItems[index].copyWith(
                                    price: newPrice,
                                  );
                                  _subTotal = calculateSubtotal();
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Item Source',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _orderedItems[index].itemSource,
                              onChanged: (value) {
                                setState(() {
                                  _orderedItems[index] =
                                      _orderedItems[index].copyWith(
                                    itemSource: value,
                                  );
                                });
                              },
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () => editOrderedItem(index),
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Sub Total:',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                  initialValue: '\$$_subTotal',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Order Status:',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                  ),
                  value: _status,
                  onChanged: (String? newValue) {
                    setState(() {
                      _status = newValue!;
                    });
                  },
                  items: ['Pending', 'In-Progress', 'Completed']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
