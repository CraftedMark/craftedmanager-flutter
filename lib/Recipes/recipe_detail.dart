import 'package:flutter/material.dart';

import '../models/recipe_model.dart';

class RecipeDetail extends StatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onAddRecipe;

  RecipeDetail({required this.recipe, required this.onAddRecipe});

  @override
  _RecipeDetailState createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  Recipe get recipe => widget.recipe;

  Function(Recipe) get onAddRecipe => widget.onAddRecipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: ListView.separated(
        itemCount: recipe.ingredients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipe.ingredients[index].name),
            subtitle: Text(
              'Quantity: ${recipe.ingredients[index].qtyInStock}',
            ),
            trailing: Text(
              'Cost: ${recipe.ingredients[index].perGramCost.toString()}',
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
