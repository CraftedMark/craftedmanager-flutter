import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({Key? key, required this.product}) : super(key: key);

  final Product product;

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late bool _backordered;
  late String _category;
  late double _costOfGood;
  late String _description;
  final _formKey = GlobalKey<FormState>();
  late String _itemSource;
  late int _manufacturerId;
  late String _manufacturerName;
  late double _manufacturingPrice;
  late String _name;
  late int _quantityInStock;
  late int _quantitySold;
  late String _retailPrice;
  late int _stockQuantity;
  late String _subCategory;
  late String _subcat2;
  late String _supplier;
  late double _wholesalePrice;

  // New fields
  late String _imageUrl;
  late int _perGramCost;
  late int _bulkPricing;
  late int _weightInGrams;
  late String _packageWeightMeasure;
  late int _packageWeight;
  late String _type;
  late double _dose;
  late String _packaging;
  late String _flavor;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _category = widget.product.category;
    _subCategory = widget.product.subCategory;
    _subcat2 = widget.product.subcat2;
    _flavor = widget.product.flavor;
    _description = widget.product.description;
    _costOfGood = widget.product.costOfGood;
    _manufacturingPrice = widget.product.manufacturingPrice;
    _wholesalePrice = widget.product.wholesalePrice;
    _retailPrice = widget.product.retailPrice.toString();
    _stockQuantity = widget.product.stockQuantity;
    _backordered = widget.product.backordered;
    _supplier = widget.product.supplier;
    _manufacturerId = widget.product.manufacturerId.toString() as int;
    _manufacturerName = widget.product.manufacturerName;
    _itemSource = widget.product.itemSource;
    _quantitySold = widget.product.quantitySold;
    _quantityInStock = widget.product.quantityInStock;
    _imageUrl = widget.product.imageUrl;
    _perGramCost = widget.product.perGramCost;
    _bulkPricing = widget.product.bulkPricing;
    _weightInGrams = widget.product.weightInGrams;
    _packageWeightMeasure = widget.product.packageWeightMeasure;
    _packageWeight = widget.product.packageWeight;
    _type = widget.product.type;
    _dose = widget.product.dose ?? 0.5;
    _packaging = widget.product.packaging ?? 'OEM';
    _flavor = widget.product.flavor;
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        category: _category,
        subCategory: _subCategory,
        subcat2: _subcat2,
        description: _description,
        costOfGood: _costOfGood,
        manufacturingPrice: _manufacturingPrice,
        wholesalePrice: _wholesalePrice,
        retailPrice: double.parse(_retailPrice),
        stockQuantity: _stockQuantity,
        backordered: _backordered,
        supplier: _supplier,
        manufacturerId: _manufacturerId,
        manufacturerName: _manufacturerName,
        itemSource: _itemSource,
        quantitySold: _quantitySold,
        quantityInStock: _quantityInStock,
        // Add the new fields
        imageUrl: _imageUrl,
        perGramCost: _perGramCost,
        bulkPricing: _bulkPricing,
        weightInGrams: _weightInGrams,
        packageWeightMeasure: _packageWeightMeasure,
        packageWeight: _packageWeight,
        type: _type,
        dose: _dose,
        packaging: _packaging,
        flavor: _flavor,
        assemblyItems: [],
      );

      try {
        await ProductPostgres.updateProduct(updatedProduct);
        Navigator.pop(context, true);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content:
                const Text('An error occurred while updating the product.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          actions: [
            IconButton(
              onPressed: _updateProduct,
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (value) => _name = value!,
                ), // Add TextFormField for the existing fields
                TextFormField(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  onSaved: (value) => _type = value!,
                ),
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onSaved: (value) => _category = value!,
                ),
                TextFormField(
                  initialValue: _subCategory,
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                  onSaved: (value) => _subCategory = value!,
                ),
                TextFormField(
                  initialValue: _subcat2,
                  decoration: const InputDecoration(labelText: 'Subcategory 2'),
                  onSaved: (value) => _subcat2 = value!,
                ),
                TextFormField(
                  initialValue: _flavor,
                  decoration: const InputDecoration(labelText: 'Flavor'),
                  onSaved: (value) => _flavor = value!,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                ),
                TextFormField(
                  initialValue: _costOfGood.toString(),
                  decoration: const InputDecoration(labelText: 'Cost of Good'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _costOfGood = double.parse(value!),
                ),
                TextFormField(
                  initialValue: _manufacturingPrice.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Manufacturing Price'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) =>
                      _manufacturingPrice = double.parse(value!),
                ),
                TextFormField(
                  initialValue: _wholesalePrice.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Wholesale Price'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _wholesalePrice = double.parse(value!),
                ),
                TextFormField(
                  initialValue: _retailPrice,
                  decoration: const InputDecoration(labelText: 'Retail Price'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _retailPrice = value!,
                ),
                TextFormField(
                  initialValue: _stockQuantity.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _stockQuantity = int.parse(value!),
                ),
                TextFormField(
                  initialValue: _backordered.toString(),
                  decoration: const InputDecoration(labelText: 'Backordered'),
                  onSaved: (value) =>
                      _backordered = value == 'true' ? true : false,
                ),
                TextFormField(
                  initialValue: _supplier,
                  decoration: const InputDecoration(labelText: 'Supplier'),
                  onSaved: (value) => _supplier = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a supplier';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _manufacturerId.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Manufacturer ID'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _manufacturerId = int.parse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a manufacturer ID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _manufacturerName,
                  decoration:
                      const InputDecoration(labelText: 'Manufacturer Name'),
                  onSaved: (value) => _manufacturerName = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a manufacturer name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _itemSource,
                  decoration: const InputDecoration(labelText: 'Item Source'),
                  onSaved: (value) => _itemSource = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item source';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _dose.toString(),
                  decoration: const InputDecoration(labelText: 'Dose'),
                  onSaved: (value) => _dose = double.parse(value??'0.5'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an dose';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _flavor,
                  decoration: const InputDecoration(labelText: 'Flavor'),
                  onSaved: (value) => _flavor = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item source';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _packaging,
                  decoration: const InputDecoration(labelText: 'Packaging'),
                  onSaved: (value) => _packaging = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item source';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _quantitySold.toString(),
                  decoration: const InputDecoration(labelText: 'Quantity Sold'),
                  keyboardType: const TextInputType.numberWithOptions(signed: false),
                  onSaved: (value) => _quantitySold = int.parse(value!),
                ),
                TextFormField(
                  initialValue: _quantityInStock.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Quantity In Stock'),
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  onSaved: (value) => _quantityInStock = int.parse(value!),
                ),
                // Add TextFormField for the new fields
                TextFormField(
                  initialValue: _imageUrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  onSaved: (value) => _imageUrl = value!,
                ),
                TextFormField(
                  initialValue: _perGramCost.toString(),
                  decoration: const InputDecoration(labelText: 'Per Gram Cost'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _perGramCost = int.parse(value!),
                ),
                TextFormField(
                  initialValue: _bulkPricing.toString(),
                  decoration: const InputDecoration(labelText: 'Bulk Pricing'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _bulkPricing = int.parse(value!),
                ),
                TextFormField(
                  initialValue: _weightInGrams.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Weight In Grams'),
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  onSaved: (value) => _weightInGrams = int.parse(value!),
                ),
                TextFormField(
                  initialValue: _packageWeightMeasure,
                  decoration: const InputDecoration(
                      labelText: 'Package Weight Measure'),
                  onSaved: (value) => _packageWeightMeasure = value!,
                ),
                TextFormField(
                  initialValue: _packageWeight.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Package Weight'),
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  onSaved: (value) => _packageWeight = int.parse(value!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
