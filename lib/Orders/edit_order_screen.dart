import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Orders/ordered_item_postgres.dart';
import 'package:crafted_manager/Orders/product_search_screen.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import 'old_order_provider.dart';
import 'ordered_item_postgres.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  final People customer;
  final List<Product> products;

  const EditOrderScreen({super.key,
    required this.order,
    required this.customer,
    required this.products,
  });

  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late OrderProvider _provider;
  List<OrderedItem> _orderedItems = [];
  double _subTotal = 0.0;
  String _status = '';

  void _setInitialOrderedItems() {
    if (_orderedItems.isEmpty) {
      _orderedItems = List.from(widget.order.orderedItems);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _setInitialOrderedItems();
    _subTotal = calculateSubtotal();
    _status = widget.order.orderStatus;
    if (!['Pending', 'In-Progress', 'Completed'].contains(_status)) {
      _status = 'Pending';
    }
  }

  Future<List<OrderedItem>> getOrderedItemsByOrderId() async {
    return _provider.orders.where((o) => o.id == widget.order.id).first.orderedItems;
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

  void addOrderedItem(Product product, int quantity) {
    final existingIndex = _orderedItems
        .indexWhere((orderedItem) => orderedItem.productId == product.id);

    if (existingIndex != -1) {
      _orderedItems[existingIndex] = _orderedItems[existingIndex].copyWith(
        quantity: _orderedItems[existingIndex].quantity + quantity,
      );
      _subTotal = calculateSubtotal();
    } else {
      _orderedItems.add(OrderedItem(
        orderId: widget.order.id,
        product: product,
        productName: product.name,
        productId: product.id!,
        name: product.name,
        quantity: quantity,
        price: product.retailPrice,
        discount: 0,
        productDescription: product.description,
        productRetailPrice: product.retailPrice,
        status: 'Processing',
        itemSource: '',
        packaging: '',
        dose: 0.0,
        flavor: '',
      ));
      _subTotal = calculateSubtotal();
    }
    getOrderedItemsByOrderId();
    setState(() {});
    print('_orderedItems: $_orderedItems');
  }

  void updateOrderedItem({
    required int index,
    required String name,
    required double price,
    required int quantity,
    required String itemSource,
    required String packaging,
    required double dose,
    required String flavor,
  }) {
    setState(() {
      _orderedItems[index] = _orderedItems[index].copyWith(
        productName: name,
        price: price,
        quantity: quantity,
        itemSource: itemSource,
        packaging: packaging,
        dose: dose,
        flavor: flavor,
      );
      _subTotal = calculateSubtotal();
    });
  }

  Future<void> updateOrder() async {

    Order updatedOrder = widget.order.copyWith(
      totalAmount: _subTotal,
      orderStatus: _status,
      orderedItems: _orderedItems,
    );

    var result = await _provider.updateOrder(updatedOrder, newItems: _orderedItems);

    if (mounted) {
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order updated successfully.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order.'),
          ),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<OrderProvider>(context);
    print(widget.order.orderedItems.length);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: ListView(
          children: [
            SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order information',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Customer:',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                    initialValue: widget.customer.firstName +
                        ' ' +
                        widget.customer.lastName,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () async {
                  List<Product> products = [];
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductSearchScreen(),
                    ),
                  ).then((result) async {
                    if (result != null) {
                      addOrderedItem(result['product'], result['quantity']);
                    }
                    // print('return from product screen');
                    // print(selectedProducts);
                    // if (selectedProducts != null &&selectedProducts.isNotEmpty){
                    //   final result = await showDialog<Map<String, dynamic>>(
                    //     context: context,
                    //     builder: (BuildContext context) =>
                    //         AddOrderedItemDialog(products: [selectedProducts['product']]),
                    //   );
                    //
                    //   if (result != null) {
                    //     addOrderedItem(result['product'], result['quantity']);
                    //   }
                    // }
                  });
                },
                child: Text('Add Item'),
              ),
            ),
            SizedBox(height: 10.0),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _orderedItems.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: _orderedItems[index].productName,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: value,
                              price: _orderedItems[index].price,
                              quantity: _orderedItems[index].quantity,
                              itemSource: _orderedItems[index].itemSource,
                              packaging: _orderedItems[index].packaging,
                              dose: _orderedItems[index].dose,
                              flavor: _orderedItems[index].flavor,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _orderedItems[index].itemSource,
                          decoration: InputDecoration(
                            labelText: 'Item Source',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: _orderedItems[index].productName,
                              price: _orderedItems[index].price,
                              quantity: _orderedItems[index].quantity,
                              itemSource: value,
                              packaging: _orderedItems[index].packaging,
                              dose: _orderedItems[index].dose,
                              flavor: _orderedItems[index].flavor,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _orderedItems[index].flavor,
                          decoration: InputDecoration(
                            labelText: 'Flavor',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: _orderedItems[index].productName,
                              price: _orderedItems[index].price,
                              quantity: _orderedItems[index].quantity,
                              itemSource: _orderedItems[index].itemSource,
                              packaging: _orderedItems[index].packaging,
                              dose: _orderedItems[index].dose,
                              flavor: value,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _orderedItems[index].dose.toString(),
                          decoration: InputDecoration(
                            labelText: 'Dose',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: _orderedItems[index].productName,
                              price: _orderedItems[index].price,
                              quantity: _orderedItems[index].quantity,
                              itemSource: _orderedItems[index].itemSource,
                              packaging: _orderedItems[index].packaging,
                              dose: double.parse(value),
                              flavor: _orderedItems[index].flavor,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _orderedItems[index].packaging,
                          decoration: InputDecoration(
                            labelText: 'Packaging',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: _orderedItems[index].productName,
                              price: _orderedItems[index].price,
                              quantity: _orderedItems[index].quantity,
                              itemSource: _orderedItems[index].itemSource,
                              packaging: value,
                              dose: _orderedItems[index].dose,
                              flavor: _orderedItems[index].flavor,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: _orderedItems[index].price.toString(),
                          decoration: InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          onChanged: (value) {
                            updateOrderedItem(
                              index: index,
                              name: _orderedItems[index].productName,
                              price: double.parse(value),
                              quantity: _orderedItems[index].quantity,
                              itemSource: _orderedItems[index].itemSource,
                              packaging: _orderedItems[index].packaging,
                              dose: _orderedItems[index].dose,
                              flavor: _orderedItems[index].flavor,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () => editOrderedItem(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Sub Total:',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
                initialValue: '\$$_subTotal',
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Order Status:',
                  border: OutlineInputBorder(),
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () async {
                  await updateOrder();
                  // Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
    );
  }
}

class AddOrderedItemDialog extends StatefulWidget {
  final List<Product> products;

  const AddOrderedItemDialog({super.key, required this.products});

  @override
  _AddOrderedItemDialogState createState() => _AddOrderedItemDialogState();
}

class _AddOrderedItemDialogState extends State<AddOrderedItemDialog> {
  Product? _selectedProduct;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Product>(
            value: _selectedProduct,
            onChanged: (Product? newValue) {
              setState(() {
                _selectedProduct = newValue;
              });
            },
            items: widget.products
                .map<DropdownMenuItem<Product>>((Product product) {
              return DropdownMenuItem<Product>(
                value: product,
                child: Text(product.name),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Product',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: '1',
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value) ?? 1;
              });
            },
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProduct != null) {
              Navigator.pop(context, {
                'product': _selectedProduct,
                'quantity': _quantity,
              });
            } else {
              // Show error message
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
