import 'dart:io';

import 'package:crafted_manager/Models/recipe_model.dart';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

final _logger = Logger('Database');

// Establishes a connection to the PostgreSQL database
Future<PostgreSQLConnection> connectToPostgres() async {
  final connection = PostgreSQLConnection(
    Platform.environment['DB_HOST']!, // Database host
    int.parse(Platform.environment['DB_PORT']!), // Port number
    Platform.environment['DB_NAME']!, // Database name
    username: Platform.environment['DB_USER'], // Database username
    password: Platform.environment['DB_PASSWORD'], // Database password
  );

  await connection.open();
  _logger.info('Connected to PostgreSQL');
  return connection;
}

Future<List<Recipe>> getAllRecipes() async {
  final recipeListData = await getAll('recipes');
  return recipeListData.map<Recipe>((json) => Recipe.fromJson(json)).toList();
}

Future<List<Recipe>> searchRecipe(
    String searchQuery, Map<String, dynamic> substitutionValues) async {
  final recipeListData =
      await search('recipes', searchQuery, substitutionValues);
  return recipeListData.map<Recipe>((json) => Recipe.fromJson(json)).toList();
}

Future<void> addRecipe(Recipe recipe) async {
  await add('recipes', recipe.toJson());
}

Future<void> updateRecipe(int id, Recipe updatedRecipe) async {
  await update('recipes', id, updatedRecipe.toJson());
}

Future<void> deleteRecipe(int id) async {
  await delete('recipes', id);
}
