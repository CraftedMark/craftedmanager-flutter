import 'package:crafted_manager/Models/ingredients_model.dart';
import 'package:flutter/material.dart';

import 'ingredient_db_manager.dart';

class IngredientDetail extends StatefulWidget {
  final Ingredient? ingredient;

  IngredientDetail({this.ingredient});

  @override
  _IngredientDetailState createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  IngredientManager ingredientManager = IngredientManager();
  bool _isEditing = false;
  late Ingredient _editableIngredient;

  TextEditingController _brandController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _bulkPricingController = TextEditingController();
  TextEditingController _perGramCostController = TextEditingController();
  TextEditingController _pkgWeightController = TextEditingController();
  TextEditingController _qtyInStockController = TextEditingController();
  TextEditingController _reorderLevelController = TextEditingController();
  TextEditingController _reorderQtyController = TextEditingController();
  TextEditingController _suppliersController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bulkMeasurementController = TextEditingController();
  TextEditingController _manufacturerController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_editableIngredient.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _isEditing
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_brandController, 'Brand'),
                  _buildTextField(_categoryController, 'Category'),
                  _buildTextField(_bulkPricingController, 'Bulk Pricing'),
                  _buildTextField(_perGramCostController, 'Per Gram Cost'),
                  _buildTextField(_pkgWeightController, 'Package Weight'),
                  _buildTextField(_qtyInStockController, 'Quantity in Stock'),
                  _buildTextField(_reorderLevelController, 'Reorder Level'),
                  _buildTextField(_reorderQtyController, 'Reorder Quantity'),
                  _buildTextField(_suppliersController, 'Suppliers'),
                  _buildTextField(
                      _productDescriptionController, 'Product Description'),
                  _buildTextField(_weightController, 'Weight'),
                  _buildTextField(
                      _bulkMeasurementController, 'Bulk Measurement'),
                  _buildTextField(_manufacturerController, 'Manufacturer'),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Brand: ${_editableIngredient.brand}'),
                  Text('Category: ${_editableIngredient.category}'),
                  Text('Bulk Pricing: ${_editableIngredient.bulkPricing}'),
                  Text('Per Gram Cost: ${_editableIngredient.perGramCost}'),
                  Text('Package Weight: ${_editableIngredient.pkgWeight}'),
                  Text('Quantity in Stock: ${_editableIngredient.qtyInStock}'),
                  Text('Reorder Level: ${_editableIngredient.reorderLevel}'),
                  Text('Reorder Quantity: ${_editableIngredient.reorderQty}'),
                  Text('Suppliers: ${_editableIngredient.suppliers}'),
                  Text(
                      'Product Description: ${_editableIngredient.productDescription}'),
                  Text('Weight: ${_editableIngredient.weight}'),
                  Text(
                      'Bulk Measurement: ${_editableIngredient.bulkMeasurement}'),
                  Text('Manufacturer: ${_editableIngredient.manufacturer}'),
                ],
              ),
      ),
    );
  }
}
