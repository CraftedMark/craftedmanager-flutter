import 'package:crafted_manager/Recipes/add_recipe.dart';
import 'package:flutter/material.dart';

class RecipeManager extends StatefulWidget {
  const RecipeManager({Key? key}) : super(key: key);
  @override
  State<RecipeManager> createState() => _RecipeManagerState();
}

class _RecipeManagerState extends State<RecipeManager> {
  List<Recipe> recipes = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Manager'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipes[index].name),
            subtitle: Text('Cost per piece: ${recipes[index].costPerPiece}'),
            onTap: () {
              // TODO: Navigate to recipe detail screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipe(
                onAddRecipe: (newRecipe) {
                  setState(() {
                    recipes.add(newRecipe);
                  });
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Recipe {
  final String name;
  final List<Ingredient> ingredients;

  Recipe({required this.name, required this.ingredients});

  double get costPerPiece {
    double totalCost = 0;
    ingredients.forEach((ingredient) {
      totalCost += ingredient.cost;
    });
    return totalCost;
  }
}

class Ingredient {
  final String name;
  final double cost;
  final double quantity;

  Ingredient({required this.name, required this.cost, required this.quantity});
}
