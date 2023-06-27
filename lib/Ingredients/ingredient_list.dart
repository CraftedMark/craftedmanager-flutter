import 'package:crafted_manager/Models/ingredients_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ingredient_db_manager.dart';
import 'ingredient_detail.dart';

class IngredientList extends StatefulWidget {
  const IngredientList({super.key});

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
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ingredients'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) => searchIngredients(value),
                  decoration: const InputDecoration(
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
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[900],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(ingredient.name),
                      subtitle: Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ingredient.brand),
                            // Add any additional information you want to display here
                          ],
                        ),
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
                    ),
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
                  builder: (context) => const IngredientDetail(),
                ),
              );
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
