import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:flutter/cupertino.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _retailPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _itemSourceController = TextEditingController();
  TextEditingController _packagingController = TextEditingController();
  TextEditingController _flavorController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();

  void _saveProduct() async {
    if (_descriptionController.text.isNotEmpty &&
        _retailPriceController.text.isNotEmpty &&
        // _quantityController.text.isNotEmpty &&
        _itemSourceController.text.isNotEmpty &&
        _packagingController.text.isNotEmpty &&
        _flavorController.text.isNotEmpty &&
        _dosageController.text.isNotEmpty) {
      Product newProduct = Product(
        id: 0,
        name: '',//TODO:FIX
        description: _descriptionController.text,
        retailPrice: double.parse(_retailPriceController.text),
        // quantity: int.parse(_quantityController.text),
        itemSource: _itemSourceController.text,
        packaging: _packagingController.text,
        flavor: _flavorController.text,
        dose: double.parse(_dosageController.text),
        assemblyItems: [],
      );
      await ProductPostgres.saveProduct(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.all(8),
        middle: const Text('Add Product'),
        trailing: GestureDetector(
          onTap: _saveProduct,
          child: const Text(
            "Save",
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: 'Enter product description',
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Add TextField widgets for all the other attributes here
            // Similar to the Textfields for description and retail price,
            // but you'll replace the placeholders and controllers with the respective attribute

            const Text(
              'Retail Price',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _retailPriceController,
              placeholder: 'Enter retail price',
              keyboardType: TextInputType.number,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
