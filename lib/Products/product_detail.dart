import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isNewProduct;
  final Function onProductSaved;

  ProductDetailPage(
      {required this.product,
      this.isNewProduct = false,
      required this.onProductSaved});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _subcat2Controller = TextEditingController();
  final _flavorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costOfGoodController = TextEditingController();
  final _manufacturingPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _retailPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _itemSourceController = TextEditingController();
  final _manufacturerNameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _perGramCostController = TextEditingController();
  final _bulkPricingController = TextEditingController();
  final _weightInGramsController = TextEditingController();
  final _packageWeightMeasureController = TextEditingController();
  final _packageWeightController = TextEditingController();
  final _typeController = TextEditingController();
  final _isAssemblyItemController = TextEditingController();
  String? _isAssemblyItemValue;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _categoryController.text = widget.product.category;
    _subCategoryController.text = widget.product.subCategory;
    _subcat2Controller.text = widget.product.subcat2;
    _flavorController.text = widget.product.flavor;
    _descriptionController.text = widget.product.description;
    _costOfGoodController.text = widget.product.costOfGood.toString();
    _manufacturingPriceController.text =
        widget.product.manufacturingPrice.toString();
    _wholesalePriceController.text = widget.product.wholesalePrice.toString();
    _retailPriceController.text = widget.product.retailPrice.toString();
    _stockQuantityController.text = widget.product.stockQuantity.toString();
    _itemSourceController.text = widget.product.itemSource;
    _manufacturerNameController.text = widget.product.manufacturerName;
    _supplierController.text = widget.product.supplier;
    _imageUrlController.text = widget.product.imageUrl;
    _perGramCostController.text = widget.product.perGramCost.toString();
    _bulkPricingController.text = widget.product.bulkPricing.toString();
    _weightInGramsController.text = widget.product.weightInGrams.toString();
    _packageWeightMeasureController.text = widget.product.packageWeightMeasure;
    _packageWeightController.text = widget.product.packageWeight.toString();
    _typeController.text = widget.product.type;
    _isAssemblyItemValue = widget.product.isAssemblyItem ? "true" : "false";
  }

  InputDecoration _getInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.isNewProduct ? 'New Product' : 'Edit Product'),
            backgroundColor: Colors.black,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Name:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _typeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Type:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _categoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Category:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _subCategoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Subcategory:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _subcat2Controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Subcategory 2:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _flavorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Flavor:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Description:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _costOfGoodController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Cost of Good:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _manufacturingPriceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Manufacturing Price:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _wholesalePriceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Wholesale Price:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _retailPriceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Retail Price:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _stockQuantityController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Stock Quantity:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _itemSourceController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Item Source:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _manufacturerNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Manufacturer Name:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _supplierController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Supplier:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _imageUrlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _getInputDecoration('Image URL:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _perGramCostController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Per Gram Cost:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _bulkPricingController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Bulk Pricing:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _weightInGramsController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Weight in Grams:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _packageWeightMeasureController,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _getInputDecoration('Package Weight Measure:'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _packageWeightController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _getInputDecoration('Package Weight:'),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: _getInputDecoration('Is Assembly:'),
                        value: _isAssemblyItemController.text.isEmpty
                            ? null
                            : _isAssemblyItemController.text,
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: "true",
                            child: const Text('Yes'),
                          ),
                          DropdownMenuItem<String>(
                            value: "false",
                            child: const Text('No'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _isAssemblyItemValue = newValue;
                            _isAssemblyItemController.text = newValue!;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await saveProduct();
                              widget.onProductSaved();
                              Navigator.pop(context);
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'An error occurred while saving the product.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> saveProduct() async {
    Product updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      category: _categoryController.text,
      subCategory: _subCategoryController.text,
      subcat2: _subcat2Controller.text,
      flavor: _flavorController.text,
      description: _descriptionController.text,
      costOfGood: double.parse(_costOfGoodController.text),
      manufacturingPrice: double.parse(_manufacturingPriceController.text),
      wholesalePrice: double.parse(_wholesalePriceController.text),
      retailPrice: double.parse(_retailPriceController.text),
      stockQuantity: int.parse(_stockQuantityController.text),
      backordered: false,
      supplier: _supplierController.text,
      manufacturerId: widget.product.manufacturerId,
      manufacturerName: _manufacturerNameController.text,
      itemSource: _itemSourceController.text,
      quantitySold: widget.product.quantitySold,
      quantityInStock: widget.product.quantityInStock,
      assemblyItems: [],
      imageUrl: _imageUrlController.text,
      perGramCost: int.parse(_perGramCostController.text),
      bulkPricing: int.parse(_bulkPricingController.text),
      weightInGrams: int.parse(_weightInGramsController.text),
      packageWeightMeasure: _packageWeightMeasureController.text,
      packageWeight: int.parse(_packageWeightController.text),
      type: _typeController.text,
      isAssemblyItem: _isAssemblyItemValue == "true",
    );

    if (widget.isNewProduct) {
      await ProductPostgres.addProduct(updatedProduct);
    } else {
      await ProductPostgres.updateProduct(updatedProduct);
    }
  }
}
