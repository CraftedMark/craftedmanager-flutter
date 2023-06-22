import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:crafted_manager/Orders/product_search_screen.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';
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

  @override
  void initState() {
    super.initState();
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
          orderId: widget.order.id,
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
      });
    }
  }

  void updateOrderedItem(int index, String name, double price, int quantity,
      String itemSource, String packaging, double dose, String flavor) {
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

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order updated successfully.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating order.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          _orderedItems = widget.order.orderedItems;
          return ListView(
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
                    List<Product> products = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductSearchScreen(
                                products: widget.products),
                      ),
                    );

                    if ( products.isNotEmpty) {
                      final result =
                      await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (BuildContext context) =>
                            AddOrderedItemDialog(products: products),
                      );

                      if (result != null) {
                        addOrderedItem(
                            result['product'], result['quantity']);
                      }
                    }
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
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue:
                            _orderedItems[index].productName,
                            decoration: InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              updateOrderedItem(
                                index,
                                value,
                                _orderedItems[index].price,
                                _orderedItems[index].quantity,
                                _orderedItems[index].itemSource,
                                _orderedItems[index].packaging,
                                _orderedItems[index].dose,
                                _orderedItems[index].flavor,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: _orderedItems[index].itemSource,
                            decoration: InputDecoration(
                              labelText: 'Item Source',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              updateOrderedItem(
                                index,
                                _orderedItems[index].productName,
                                _orderedItems[index].price,
                                _orderedItems[index].quantity,
                                value,
                                _orderedItems[index].packaging,
                                _orderedItems[index].dose,
                                _orderedItems[index].flavor,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: _orderedItems[index].flavor,
                            decoration: InputDecoration(
                              labelText: 'Flavor',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              print('changed flavor');
                              updateOrderedItem(
                                index,
                                _orderedItems[index].productName,
                                _orderedItems[index].price,
                                _orderedItems[index].quantity,
                                _orderedItems[index].itemSource,
                                _orderedItems[index].packaging,
                                _orderedItems[index].dose,
                                value,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue:
                            _orderedItems[index].dose.toString(),
                            decoration: InputDecoration(
                              labelText: 'Dose',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              updateOrderedItem(
                                index,
                                _orderedItems[index].productName,
                                _orderedItems[index].price,
                                _orderedItems[index].quantity,
                                _orderedItems[index].itemSource,
                                _orderedItems[index].packaging,
                                double.tryParse(value) ??
                                    _orderedItems[index].dose,
                                _orderedItems[index].flavor,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: _orderedItems[index].packaging,
                            decoration: InputDecoration(
                              labelText: 'Packaging',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              updateOrderedItem(
                                index,
                                _orderedItems[index].productName,
                                _orderedItems[index].price,
                                _orderedItems[index].quantity,
                                _orderedItems[index].itemSource,
                                value,
                                _orderedItems[index].dose,
                                _orderedItems[index].flavor,
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => editOrderedItem(index),
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
          );
        }
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
