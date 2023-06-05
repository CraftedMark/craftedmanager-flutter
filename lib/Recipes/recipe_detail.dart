import 'package:flutter/material.dart';

import 'recipe_manager.dart';

class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  RecipeDetail({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: ListView.builder(
        itemCount: recipe.ingredients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recipe.ingredients[index].name),
            subtitle: Text('Quantity: ${recipe.ingredients[index].quantity}'),
            trailing: Text('Cost: ${recipe.ingredients[index].cost}'),
          );
        },
      ),
    );
  }
}
