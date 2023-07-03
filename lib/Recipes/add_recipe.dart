import 'package:crafted_manager/models/ingredients_model.dart';
import 'package:flutter/material.dart';

import '../../../Recipes/recipe_db_manager.dart';
import '../../../models/recipe_model.dart';

class AddRecipe extends StatefulWidget {
  final Function(Recipe) onAddRecipe;

  const AddRecipe({Key? key, required this.onAddRecipe}) : super(key: key);

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  String name = "";
  List<Ingredient> ingredients = [];
  int totalPieces = 0;

  TextEditingController _ingredientNameController = TextEditingController();
  TextEditingController _ingredientCostController = TextEditingController();
  TextEditingController _ingredientWeightController = TextEditingController();

  void _addIngredient() {
    final name = _ingredientNameController.text;
    final cost = double.tryParse(_ingredientCostController.text);
    final weight = double.tryParse(_ingredientWeightController.text);

    if (name != null && cost != null && weight != null) {
      setState(() {
        ingredients.add(Ingredient.empty().copyWith(
          name: name,
          perGramCost: cost,
          qty: weight,
        ));
      });

      _ingredientNameController.clear();
      _ingredientCostController.clear();
      _ingredientWeightController.clear();
    } else {
      print("Invalid number input for cost or weight");
      // you might want to show an error message to the user here
    }
  }

  void _searchAndPickIngredient(BuildContext context) async {
    String searchTerm = _ingredientNameController.text;
    List<Ingredient> foundIngredients = await searchIngredients(searchTerm);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: foundIngredients.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(foundIngredients[index].name),
                onTap: () {
                  setState(() {
                    ingredients.add(foundIngredients[index]);
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        });
  }

  double _calculatePieceCost() {
    double totalCost = 0;
    for (final ingredient in ingredients) {
      totalCost += ingredient.perGramCost;
    }
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
                    subtitle: Text('Weight: ${ingredient.qty}'),
                    trailing: Text('Cost: ${ingredient.perGramCost}'),
                  )),
              TextField(
                controller: _ingredientNameController,
                decoration: const InputDecoration(
                  hintText: 'Ingredient Name',
                ),
                onSubmitted: (value) => _searchAndPickIngredient(context),
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
                  try {
                    int pieces = int.parse(value);
                    setState(() {
                      totalPieces = pieces;
                    });
                  } catch (e) {
                    print("Invalid number input for total pieces");
                    // you might want to show an error message to the user here
                  }
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
          final recipe = Recipe(
            id: '0',
            name: name,
            ingredients: ingredients,
            amounts: ingredients.map((i) => i.qty).toList(),
            costs: ingredients.map((i) => i.perGramCost).toList(),
            pieces: totalPieces,
            steps: [],
            // you need to provide a list of steps
            stepImages: [], // you need to provide a list of step images
          );
          widget.onAddRecipe(recipe);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
