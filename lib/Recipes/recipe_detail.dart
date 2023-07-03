import 'package:flutter/material.dart';

import '../Models/recipe_model.dart';

class RecipeDetail extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetail({Key? key, required this.recipe}) : super(key: key);

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
