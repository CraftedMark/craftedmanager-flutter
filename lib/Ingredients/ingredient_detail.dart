import 'package:crafted_manager/Ingredients/ingredient_db_manager.dart';
import 'package:crafted_manager/Models/ingredients_model.dart';
import 'package:flutter/material.dart';

class IngredientDetail extends StatefulWidget {
  final Ingredient? ingredient;

  const IngredientDetail({super.key, this.ingredient});

  @override
  _IngredientDetailState createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  IngredientManager ingredientManager = IngredientManager();
  bool _isEditing = false;
  late Ingredient _editableIngredient;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _bulkPricingController = TextEditingController();
  final TextEditingController _perGramCostController = TextEditingController();
  final TextEditingController _pkgWeightController = TextEditingController();
  final TextEditingController _qtyInStockController = TextEditingController();
  final TextEditingController _reorderLevelController = TextEditingController();
  final TextEditingController _reorderQtyController = TextEditingController();
  final TextEditingController _suppliersController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bulkMeasurementController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editableIngredient = widget.ingredient ?? Ingredient.empty();
    _initTextControllers();
    if (widget.ingredient == null) {
      _isEditing = true;
    }
  }

  void _initTextControllers() {
    _nameController.text = _editableIngredient.name;
    _brandController.text = _editableIngredient.brand;
    _categoryController.text = _editableIngredient.category;
    _bulkPricingController.text = _editableIngredient.bulkPricing.toString();
    _perGramCostController.text = _editableIngredient.perGramCost.toString();
    _pkgWeightController.text = _editableIngredient.pkgWeight.toString();
    _qtyInStockController.text = _editableIngredient.qtyInStock;
    _reorderLevelController.text = _editableIngredient.reorderLevel;
    _reorderQtyController.text = _editableIngredient.reorderQty;
    _suppliersController.text = _editableIngredient.suppliers;
    _productDescriptionController.text = _editableIngredient.productDescription;
    _weightController.text = _editableIngredient.weight;
    _bulkMeasurementController.text = _editableIngredient.bulkMeasurement;
    _manufacturerController.text = _editableIngredient.manufacturer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _bulkPricingController.dispose();
    _perGramCostController.dispose();
    _pkgWeightController.dispose();
    _qtyInStockController.dispose();
    _reorderLevelController.dispose();
    _reorderQtyController.dispose();
    _suppliersController.dispose();
    _productDescriptionController.dispose();
    _weightController.dispose();
    _bulkMeasurementController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    _editableIngredient
      ..name = _nameController.text
      ..brand = _brandController.text
      ..category = _categoryController.text
      ..bulkPricing = double.parse(_bulkPricingController.text)
      ..perGramCost = double.parse(_perGramCostController.text)
      ..pkgWeight = double.parse(_pkgWeightController.text)
      ..qtyInStock = _qtyInStockController.text
      ..reorderLevel = _reorderLevelController.text
      ..reorderQty = _reorderQtyController.text
      ..suppliers = _suppliersController.text
      ..productDescription = _productDescriptionController.text
      ..weight = _weightController.text
      ..bulkMeasurement = _bulkMeasurementController.text
      ..manufacturer = _manufacturerController.text;

    if (widget.ingredient != null) {
      await ingredientManager.updateIngredient(
          _editableIngredient.id, _editableIngredient);
    } else {
      await ingredientManager.addIngredient(_editableIngredient);
    }
    _toggleEditMode();
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.ingredient?.name ?? 'New Ingredient'),
          actions: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _isEditing ? _saveChanges : _toggleEditMode,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _isEditing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(_nameController, 'Name'),
                            _buildTextField(_brandController, 'Brand'),
                            _buildTextField(_categoryController, 'Category'),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                _bulkPricingController, 'Bulk Pricing'),
                            _buildTextField(
                                _perGramCostController, 'Per Gram Cost'),
                            _buildTextField(
                                _pkgWeightController, 'Package Weight'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                _qtyInStockController, 'Quantity in Stock'),
                            _buildTextField(
                                _reorderLevelController, 'Reorder Level'),
                            _buildTextField(
                                _reorderQtyController, 'Reorder Quantity'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(_suppliersController, 'Suppliers'),
                            _buildTextField(_productDescriptionController,
                                'Product Description'),
                            _buildTextField(_weightController, 'Weight'),
                            _buildTextField(
                                _bulkMeasurementController, 'Bulk Measurement'),
                            _buildTextField(
                                _manufacturerController, 'Manufacturer'),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${_editableIngredient.name}'),
                            Text('Brand: ${_editableIngredient.brand}'),
                            Text('Category: ${_editableIngredient.category}'),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Bulk Pricing: ${_editableIngredient.bulkPricing}'),
                            Text(
                                'Per Gram Cost: ${_editableIngredient.perGramCost}'),
                            Text(
                                'Package Weight: ${_editableIngredient.pkgWeight}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Quantity in Stock: ${_editableIngredient.qtyInStock}'),
                            Text(
                                'Reorder Level: ${_editableIngredient.reorderLevel}'),
                            Text(
                                'Reorder Quantity: ${_editableIngredient.reorderQty}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Suppliers: ${_editableIngredient.suppliers}'),
                            Text(
                                'Product Description: ${_editableIngredient.productDescription}'),
                            Text('Weight: ${_editableIngredient.weight}'),
                            Text(
                                'Bulk Measurement: ${_editableIngredient.bulkMeasurement}'),
                            Text(
                                'Manufacturer: ${_editableIngredient.manufacturer}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
