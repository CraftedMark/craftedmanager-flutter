import 'package:crafted_manager/Recipes/add_recipe.dart';
import 'package:crafted_manager/Recipes/recipe_detail.dart';
import 'package:crafted_manager/models/recipe_model.dart';
import 'package:flutter/material.dart';

class RecipeManager extends StatefulWidget {
  final Function(Recipe) onAddRecipe;

  const RecipeManager({Key? key, required this.onAddRecipe}) : super(key: key);

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetail(
                      recipe: recipes[index],
                      onAddRecipe: (updatedRecipe) {
                        setState(() {
                          recipes[index] = updatedRecipe;
                        });
                      }),
                ),
              );
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
