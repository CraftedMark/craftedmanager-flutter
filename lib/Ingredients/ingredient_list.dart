import 'package:crafted_manager/Models/ingredients_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ingredient_db_manager.dart';
import 'ingredient_detail.dart';

class IngredientList extends StatefulWidget {
  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  IngredientManager ingredientManager = IngredientManager();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ingredientManager.getAllIngredients();
  }

  void searchIngredients(String query) {
    if (query.isNotEmpty) {
      ingredientManager.searchIngredients(
        "name ILIKE @name OR category ILIKE @category OR brand ILIKE @brand",
        {'name': '%$query%', 'category': '%$query%', 'brand': '%$query%'},
      );
    } else {
      ingredientManager.getAllIngredients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ingredientManager,
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Ingredients'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchIngredients(value),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          body: Consumer<IngredientManager>(
            builder: (context, manager, child) => Container(
              color: Colors.black,
              child: ListView.builder(
                itemCount: manager.ingredients.length,
                itemBuilder: (context, index) {
                  Ingredient ingredient = manager.ingredients[index];
                  return ListTile(
                    tileColor: Colors.grey[900],
                    title: Text(ingredient.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ingredient.brand),
                        // Add any additional information you want to display here
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IngredientDetail(ingredient: ingredient),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IngredientDetail(),
                ),
              );
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
