// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

// Establishes a connection to the PostgreSQL database
Future<PostgreSQLConnection> connectToPostgres() async {
  final connection = PostgreSQLConnection(
    'localhost', // Database host
    5432, // Port number
    'craftedmanager_db', // Database name
    username: 'craftedmanager_dbuser', // Database username
    password: '!!Laganga1983', // Database password
  );

  await connection.open();
  print('Connected to PostgreSQL');
  return connection;
}

// Fetches all data from the specified table
Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
  final connection = await connectToPostgres();
  final result = await connection.query('SELECT * FROM $tableName');
  await connection.close();
  print('Closed connection to PostgreSQL');

  if (kDebugMode) {
    print('Fetched $tableName data: $result');
  }

  return result != null ? result.map((row) => row.toColumnMap()).toList() : [];
}

// Searches for data in the specified table using the provided search query and substitution values
Future<List<Map<String, dynamic>>> searchData(String tableName, String searchQuery, Map<String, dynamic> substitutionValues) async {
  final connection = await connectToPostgres();
  final result = await connection.query('SELECT * FROM $tableName WHERE $searchQuery', substitutionValues: substitutionValues);
  await connection.close();
  // ignore: avoid_print
  print('Closed connection to PostgreSQL');

  if (kDebugMode) {
    print('Searched $tableName data with query: $searchQuery and substitution values: $substitutionValues. Result: $result');
  }

  return result.map((row) => row.toColumnMap()).toList();
}

// Inserts data into the specified table
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

// Updates data in the specified table with the provided updated data
Future<void> updateData(String tableName, int id, Map<String, dynamic> updatedData) async {
  final connection = await connectToPostgres();
  final updates = updatedData.keys.map((key) => '$key = @$key').join(', ');

  await connection.execute(
    'UPDATE $tableName SET $updates WHERE id = @id',
    substitutionValues: {...updatedData, 'id': id},
  );
  await connection.close();
  print('Closed connection to PostgreSQL');

  if (kDebugMode) {
    print('Updated $tableName data with id $id. Updated data: $updatedData');
  }
}

// Deletes data from the specified table with the provided id
Future<void> deleteData(String tableName, int id) async {
  final connection = await connectToPostgres();
  await connection.execute('DELETE FROM $tableName WHERE id = @id', substitutionValues: {'id': id});
  await connection.close();
  print('Closed connection to PostgreSQL');

  if (kDebugMode) {
    print('Deleted $tableName data with id $id');
  }
}

// // Searches for data in the specified table using the provided search query and substitution values
// Future<List<Map<String, dynamic>>> searchData(String tableName, String searchQuery, Map<String, dynamic> substitutionValues) async {
//   final connection = await connectToPostgres();
//   final result = await connection.query('SELECT * FROM $tableName WHERE $searchQuery', substitutionValues: substitutionValues);
//   await connection.close();
//
//   if (kDebugMode) {
//     print('Searched $tableName data with query: $searchQuery and substitution values: $substitutionValues. Result: $result');
//   }
//
//   return result.map((row) => row.toColumnMap()).toList();
// }


// void main() async {
//   // Example usage
//   final searchQuery = 'name = @name';
//   final substitutionValues = {'name': 'John Doe'};
//   final searchDataResult = await searchData('people', searchQuery, substitutionValues);
//
//   if (kDebugMode) {
//     print('Searched people data: $searchDataResult');
//   }
// }