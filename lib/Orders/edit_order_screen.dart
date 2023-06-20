import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Orders/order_provider.dart';
import 'package:crafted_manager/Orders/orders_db_manager.dart';
import 'package:crafted_manager/Orders/product_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'ordered_item_postgres.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  final People customer;
  final List<Product> products;

  const EditOrderScreen({
    required this.order,
    required this.customer,
    required this.products,
  });

  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
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
    return OrderedItemPostgres.fetchOrderedItems(widget.order.id);
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
        var uuid = Uuid();
        _orderedItems.add(OrderedItem(
          id: uuid.v1(),
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
        ));
        _subTotal = calculateSubtotal();
      });
    }
  }

  void updateOrderedItem(int index, String name, double price, int quantity) {
    setState(() {
      _orderedItems[index] = _orderedItems[index].copyWith(
        productName: name,
        price: price,
        quantity: quantity,
      );
      _subTotal = calculateSubtotal();
    });
  }

  Future<void> updateOrder(OrderProvider orderProvider) async {
    Order updatedOrder = widget.order.copyWith(
      totalAmount: _subTotal,
      orderStatus: _status,
      orderedItems: _orderedItems,
    );

    bool result = await OrderPostgres.updateOrder(updatedOrder, _orderedItems);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return FutureBuilder(
            future: getOrderedItemsByOrderId(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                _orderedItems = snapshot.data!;
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
                              builder: (context) => ProductSearchScreen(
                                  products: widget.products),
                            ),
                          );

                          if (products != null && products.isNotEmpty) {
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
                            title: TextFormField(
                              initialValue: _orderedItems[index].productName,
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
                                );
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  initialValue: _orderedItems[index]
                                      .price
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Price',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    updateOrderedItem(
                                      index,
                                      _orderedItems[index].productName,
                                      double.tryParse(value) ??
                                          _orderedItems[index].price,
                                      _orderedItems[index].quantity,
                                    );
                                  },
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  initialValue:
                                      _orderedItems[index].quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Quantity',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    updateOrderedItem(
                                      index,
                                      _orderedItems[index].productName,
                                      _orderedItems[index].price,
                                      int.tryParse(value) ??
                                          _orderedItems[index].quantity,
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
                    SizedBox(height: 10.0),
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
                        onPressed: () {
                          updateOrder(orderProvider);
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                    ),
                  ],
                );
              }
              return Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary));
            },
          );
        },
      ),
    );
  }
}

class AddOrderedItemDialog extends StatefulWidget {
  final List<Product> products;

  AddOrderedItemDialog({required this.products});

  @override
  _AddOrderedItemDialogState createState() => _AddOrderedItemDialogState();
}

class _AddOrderedItemDialogState extends State<AddOrderedItemDialog> {
  Product? _selectedProduct;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
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
            decoration: InputDecoration(
              labelText: 'Product',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: '1',
            onChanged: (value) {
              setState(() {
                _quantity = int.tryParse(value) ?? 1;
              });
            },
            decoration: InputDecoration(
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
          child: Text('Cancel'),
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
          child: Text('Add'),
        ),
      ],
    );
  }
}
