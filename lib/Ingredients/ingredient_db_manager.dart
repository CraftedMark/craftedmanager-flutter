import 'package:crafted_manager/Models/ingredients_model.dart';
import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

class IngredientManager with ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

  // Database Functions
  Future<PostgreSQLConnection> connectToPostgres() async {
    final connection = PostgreSQLConnection(
      'web.craftedsolutions.co', // Database host
      5432, // Port number
      'craftedmanager_db', // Database name
      username: 'craftedmanager_dbuser', // Database username
      password: '!!Laganga1983', // Database password
    );

    await connection.open();
    print('Connected to PostgreSQL');
    return connection;
  }

  Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
    final connection = await connectToPostgres();
    final result = await connection.query('SELECT * FROM $tableName');
    await connection.close();
    print('Closed connection to PostgreSQL');

    if (kDebugMode) {
      print('Fetched $tableName data: $result');
    }

    return result != null
        ? result.map((row) => row.toColumnMap()).toList()
        : [];
  }

  Future<List<Map<String, dynamic>>> searchData(String tableName,
      String searchQuery, Map<String, dynamic> substitutionValues) async {
    final connection = await connectToPostgres();
    final result = await connection.query(
        'SELECT * FROM $tableName WHERE $searchQuery',
        substitutionValues: substitutionValues);
    await connection.close();
    print('Closed connection to PostgreSQL');

    if (kDebugMode) {
      print(
          'Searched $tableName data with query: $searchQuery and substitution values: $substitutionValues. Result: $result');
    }

    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    final connection = await connectToPostgres();
    final columns = data.keys.join(', ');
    final values = data.keys.map((key) => '@$key').join(', ');

    await connection.execute(
      'INSERT INTO $tableName ($columns) VALUES ($values)',
      substitutionValues: data,
    );
    await connection.close();
    print('Closed connection to PostgreSQL');

    if (kDebugMode) {
      print('Inserted data into $tableName: $data');
    }
  }

  Future<void> printDataTypes(String tableName) async {
    final connection = await connectToPostgres();
    final result = await connection.query(
        "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = @tableName",
        substitutionValues: {'tableName': tableName});
    await connection.close();

    print("Data types for table $tableName:");
    for (var row in result) {
      print("Column: ${row[0]}, Data type: ${row[1]}");
    }
  }

  Future<int> updateData(
      String table, int id, Map<String, dynamic> data) async {
    final connection = await connectToPostgres();

    final columns = data.keys.where((column) => column != 'id').map((column) {
      final value = data[column];
      if (value == '') {
        return '$column = NULL';
      }
      return '$column = @${column}';
    }).join(',');

    final query = "UPDATE $table SET $columns WHERE id = @id";

    // Convert empty strings to null values
    final processedData = data.map((key, value) {
      if (value == '') {
        return MapEntry(key, null);
      }
      return MapEntry(key, value);
    });

    final substitutionValues = {...processedData, 'id': id.toString()};

    print('Executing query: $query with values: $substitutionValues');

    final result = await connection.execute(
      query,
      substitutionValues: substitutionValues,
    );
    await connection.close();
    print('Closed connection to PostgreSQL');
    return result;
  }

  Future<void> deleteData(String tableName, int id) async {
    final connection = await connectToPostgres();
    await connection.execute('DELETE FROM $tableName WHERE id = @id',
        substitutionValues: {'id': id});
    await connection.close();
    print('Closed connection to PostgreSQL');

    if (kDebugMode) {
      print('Deleted $tableName data with id $id');
    }
  }

  // Ingredient Manager Functions
  Future<void> _refreshIngredients() async {
    final dataList = await fetchData('ingredients');
    _ingredients = dataList.map((map) => Ingredient.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> getAllIngredients() async {
    await _refreshIngredients();
    print("Fetched all ingredients from database: $_ingredients");
  }

  Future<void> searchIngredients(
      String searchQuery, Map<String, dynamic> substitutionValues) async {
    final searchDataList =
        await searchData('ingredients', searchQuery, substitutionValues);
    _ingredients =
        searchDataList.map((map) => Ingredient.fromMap(map)).toList();
    print(
        "Searched ingredients with query: $searchQuery and substitution values: $substitutionValues. Results: $_ingredients");
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await insertData('ingredients', ingredient.toMap());
    await _refreshIngredients();
    print("Added ingredient to database: ${ingredient.toMap()}");
  }

  Future<void> updateIngredient(int id, Ingredient updatedIngredient) async {
    await updateData('ingredients', id, updatedIngredient.toMap());
    await _refreshIngredients();
    print(
        "Updated ingredient with id $id. Updated data: ${updatedIngredient.toMap()}");
  }

  Future<void> deleteIngredient(int id) async {
    await deleteData('ingredients', id);
    await _refreshIngredients();
    print("Deleted ingredient with id $id");
  }
}
