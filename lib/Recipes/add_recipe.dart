import 'package:flutter/material.dart';

import 'recipe_manager.dart';

class AddRecipe extends StatefulWidget {
  final Function(Recipe) onAddRecipe;

  AddRecipe({required this.onAddRecipe});

  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  String name = "";
  List<Ingredient> ingredients = [];
  int totalPieces = 0;

  TextEditingController _ingredientNameController = TextEditingController();
  TextEditingController _ingredientCostController = TextEditingController();
  TextEditingController _ingredientWeightController = TextEditingController();

  void _addIngredient() {
    setState(() {
      ingredients.add(Ingredient(
        name: _ingredientNameController.text,
        cost: double.parse(_ingredientCostController.text),
        quantity: double.parse(_ingredientWeightController.text),
      ));
    });

    _ingredientNameController.clear();
    _ingredientCostController.clear();
    _ingredientWeightController.clear();
  }

  double _calculatePieceCost() {
    double totalCost = 0;
    ingredients.forEach((ingredient) => totalCost += ingredient.cost);
    return totalCost / totalPieces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Recipe Name',
                ),
              ),
              const SizedBox(height: 10),
              const Text('Ingredients'),
              ...ingredients.map((ingredient) => ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text('Weight: ${ingredient.quantity}'),
                    trailing: Text('Cost: ${ingredient.cost}'),
                  )),
              TextField(
                controller: _ingredientNameController,
                decoration: const InputDecoration(
                  hintText: 'Ingredient Name',
                ),
              ),
              TextField(
                controller: _ingredientCostController,
                decoration: const InputDecoration(
                  hintText: 'Ingredient Cost',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _ingredientWeightController,
                decoration: const InputDecoration(
                  hintText: 'Ingredient Weight',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              ElevatedButton(
                onPressed: _addIngredient,
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 10),
              const Text('Total Pieces'),
              TextField(
                onChanged: (value) {
                  setState(() {
                    totalPieces = int.parse(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Total Pieces',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Text('Piece Cost: ${_calculatePieceCost()}'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onAddRecipe(Recipe(name: name, ingredients: ingredients));
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
