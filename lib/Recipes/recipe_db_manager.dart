import 'dart:convert';

import 'package:crafted_manager/Models/recipe_model.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

import '../Models/ingredients_model.dart';
import '../PostresqlConnection/postqresql_connection_manager.dart';

final _logger = Logger('Database');

Future<List<Recipe>> getAllRecipes() async {
  final connection = PostgreSQLConnectionManager.connection;
  final recipeListData = await getAll('recipes', connection);
  return recipeListData.map<Recipe>((json) => Recipe.fromJson(json)).toList();
}

Future<List<Map<String, dynamic>>> getAll(
    String tableName, PostgreSQLConnection connection) async {
  var result = await connection.query('SELECT * FROM $tableName');
  List<Map<String, dynamic>> resultList = [];
  for (final row in result) {
    resultList.add({
      'id': row[0],
      'name': row[1],
      'ingredients': jsonDecode(row[2]),
      'amounts': jsonDecode(row[3]),
      'costs': jsonDecode(row[4]),
      'pieces': row[5],
      'steps': jsonDecode(row[6]),
      'step_images': jsonDecode(row[7])
    });
  }
  return resultList;
}

Future<void> addRecipe(Recipe recipe) async {
  final connection = PostgreSQLConnectionManager.connection;
  await connection.execute(
    'INSERT INTO recipes (id, name, ingredients, amounts, costs, pieces, steps, step_images) VALUES (@id, @name, @ingredients, @amounts, @costs, @pieces, @steps, @step_images)',
    substitutionValues: recipe.toJson(),
  );
}

Future<List<Ingredient>> searchIngredients(String searchTerm) async {
  final connection = PostgreSQLConnectionManager.connection;
  final response = await connection.query(
    'SELECT * FROM ingredients WHERE name LIKE @name',
    substitutionValues: {'name': '%$searchTerm%'},
  );

  return response.map((row) => Ingredient.fromMap(row.toColumnMap())).toList();
}

Future<void> updateRecipe(int id, Recipe updatedRecipe) async {
  final connection = PostgreSQLConnectionManager.connection;
  await connection.execute(
    'UPDATE recipes SET id = @id, name = @name, ingredients = @ingredients, amounts = @amounts, costs = @costs, pieces = @pieces, steps = @steps, step_images = @step_images WHERE id = @id',
    substitutionValues: updatedRecipe.toJson(),
  );
}

Future<void> deleteRecipe(int id) async {
  final connection = PostgreSQLConnectionManager.connection;
  await connection.execute('DELETE FROM recipes WHERE id = @id',
      substitutionValues: {'id': id});
}
