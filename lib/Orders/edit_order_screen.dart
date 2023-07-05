import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Orders/product_search_screen.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/config.dart';
import 'package:crafted_manager/widgets/grey_scrollable_panel.dart';
import 'package:crafted_manager/widgets/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/order_provider.dart';
import '../widgets/big_button.dart';


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
      _orderedItems[index] = _orderedItems[index].copyWith(
        quantity: _orderedItems[index].quantity - 1,
      );
      _subTotal = calculateSubtotal();
      setState(() {});
    } else {
      _orderedItems.removeAt(index);
      _subTotal = calculateSubtotal();
      setState(() {});
    }
  }

  void addOrderedItem(Product product, OrderedItem item) {
    final existingIndex = _orderedItems
        .indexWhere((orderedItem) => orderedItem.productId == product.id);

    if (existingIndex != -1) {
      _orderedItems[existingIndex] = _orderedItems[existingIndex].copyWith(
        quantity: _orderedItems[existingIndex].quantity + item.quantity,
      );
      _subTotal = calculateSubtotal();
    } else {
      _orderedItems.add(item);
      _subTotal = calculateSubtotal();
    }
    getOrderedItemsByOrderId();
    setState(() {});
    print('_orderedItems: $_orderedItems');
  }

  void updateOrderedItem({
    required int index,
    String? name,
    double? price,
    int? quantity,
    String? itemSource,
    String? packaging,
    double? dose,
    String? flavor,
  }) {
    final updatedItem = _orderedItems[index].copyWith(
      productName: name,
      price: price,
      quantity: quantity,
      itemSource: itemSource,
      packaging: packaging,
      dose: dose,
      flavor: flavor,
    );
    // _provider.updateOrder(widget.order);
    _orderedItems[index] = updatedItem;
    _subTotal = calculateSubtotal();
    setState(() {});
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
    _subTotal = calculateSubtotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body: GreyScrollablePanel(
        child: Column(
            children: [
              _OrderInformation(customer: widget.customer),
              const SizedBox(height: 16),
              BigButton(
                text: 'Add Item',
                onPressed: () async {
                  List<Product> products = [];
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductSearchScreen(),
                    ),
                  ).then((result) async {
                    if (result != null) {
                      final product = result['product'] as Product;
                      final quantity = result['quantity'];
                      final dose = result['dose'];
                      final flavor = result['flavor'];
                      final itemSource = result['itemSource'];
                      final packing = result['packing'];


                      final orderedItem = OrderedItem(
                        orderId: widget.order.id,
                        product: product,
                        productName: product.name,
                        productId: product.id!,
                        name: product.name,
                        price: product.retailPrice,
                        discount: 0,
                        productDescription: product.description,
                        productRetailPrice: product.retailPrice,
                        status: AppConfig.ORDERED_ITEM_STATUSES.first,
                        quantity: quantity,
                        dose: dose,
                        flavor: flavor,
                        itemSource: itemSource,
                        packaging: packing,
                      );
                      addOrderedItem(product, orderedItem);

                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orderedItems.length,
                itemBuilder: (context, index) {
                  return _productTile(_orderedItems[index], index);
                },
              ),
              const SizedBox(height: 16),
              _subtotalField(),
              const SizedBox(height: 16),
              BigButton(
                text: 'Save',
                onPressed: () async {
                  await updateOrder();
                  // _provider.addOrderedItemToOrderForUpdateUI(widget.order.id, orderedItem);

                  // Navigator.pop(context);
                },
              ),
            ],
          ),
      ),
    );
  }

  Widget _productTile(OrderedItem item, int itemIndex){
    const double itemPadding = 12;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: UIConstants.GREY_LIGHT,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: itemPadding),
            TextInputField(
              initialValue: item.productName,
              labelText: 'Product Name',
              keyboardType: TextInputType.text,
              onChange: (value) {
                updateOrderedItem(
                  index: itemIndex,
                  name: value,
                );
              },
            ),
            const SizedBox(height: itemPadding),
            TextInputField(
              initialValue: item.price.toStringAsFixed(2),
              labelText: 'Price',
              keyboardType: TextInputType.number,
              onChange: (value) {
                updateOrderedItem(
                  index: itemIndex,
                  price: double.parse(value),
                );
              },
            ),
            const SizedBox(height: itemPadding),
            Row(
              children: [
                Flexible(
                  child: TextInputField(
                    initialValue: item.quantity.toString(),
                    labelText: 'Quantity',
                    keyboardType: TextInputType.number,
                    onChange: (value) {
                      updateOrderedItem(
                        index: itemIndex,
                        quantity: int.parse(value),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextInputField(
                    initialValue: item.dose.toStringAsFixed(2),
                    labelText: 'Dose',
                    keyboardType: TextInputType.number,
                    onChange: (value) {
                      updateOrderedItem(
                        index: itemIndex,
                        dose: double.parse(value),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: itemPadding),
            TextInputField(
              initialValue: item.flavor,
              labelText: 'Flavor',
              onChange: (value) {
                updateOrderedItem(
                  index: itemIndex,
                  flavor: value,
                );
              },
            ),
            const SizedBox(height: itemPadding),
            TextInputField(
              initialValue: item.itemSource,
              labelText: 'Item Source',
              onChange: (value) {
                updateOrderedItem(
                  index: itemIndex,
                  itemSource: value,
                );
              },
            ),
            const SizedBox(height: itemPadding),
            TextInputField(
              initialValue: item.packaging,
              labelText: 'Packaging',
              onChange: (value) {
                updateOrderedItem(
                  index: itemIndex,
                  packaging: value,
                );
              },
            ),
            const SizedBox(height: itemPadding),
            _OrderedItemStatusPicker(
              initStatus: AppConfig.ORDERED_ITEM_STATUSES.contains(item.status)
                  ?item.status
                  :AppConfig.ORDERED_ITEM_STATUSES.first,
              onChange: (String? newValue) {//TODO: add implementation
                // _status = newValue!;
                // setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _subtotalField(){
    return TextInputField(
      enabled: false,
      labelText: 'Sub Total:',
      initialValue: '\$ ${_subTotal.toStringAsFixed(2)}',
    );
  }
}

class _OrderInformation extends StatelessWidget {
  const _OrderInformation({super.key,required this.customer});

  final People customer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 8),
           child: Text(
            'Order information',
            style: Theme.of(context).textTheme.bodyLarge,
        ),
         ),
        const SizedBox(height: 24),
        TextInputField(
          enabled: false,
          labelText: 'Customer:',
          initialValue: '${customer.firstName} ${customer.lastName}',
        ),
      ],
    );
  }
}

class _OrderedItemStatusPicker extends StatefulWidget {
  const _OrderedItemStatusPicker({Key? key, required this.initStatus, this.onChange}) : super(key: key);

  final String initStatus;
  final Function(String)? onChange;

  @override
  State<_OrderedItemStatusPicker> createState() => _OrderedItemStatusPickerState();
}

class _OrderedItemStatusPickerState extends State<_OrderedItemStatusPicker> {
  String status = '';

  @override
  void initState() {
    status = widget.initStatus;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
      dropdownColor: UIConstants.GREY_LIGHT,
      decoration: InputDecoration(
        enabledBorder: UIConstants.FIELD_BORDER,
        disabledBorder: UIConstants.FIELD_BORDER,
        focusedBorder: UIConstants.FIELD_BORDER,
        labelText: 'Order Status:',
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        filled: true,
        fillColor: UIConstants.GREY_LIGHT,
      ),
      value: status,
      items: List.generate(
        AppConfig.ORDERED_ITEM_STATUSES.length,
            (index) => DropdownMenuItem<String>(
          value: AppConfig.ORDERED_ITEM_STATUSES[index],
          child: Text(AppConfig.ORDERED_ITEM_STATUSES[index],
          ),
        ),
      ),
      onChanged: (String? newValue) {
        status = newValue!;
        widget.onChange?.call(newValue);
        setState(() {});
      },
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
