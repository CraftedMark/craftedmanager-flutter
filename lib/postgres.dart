// ignore_for_file: avoid_print

import 'package:crafted_manager/Admin/user_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:flutter/foundation.dart';

// Establishes a connection to the PostgreSQL database


Future<User?> getUserByUsernameAndPassword(
    String username, String password) async {
  final result = await searchData(
      'users',
      'username = @username AND password = @password',
      {'username': username, 'password': password});

  if (result.isNotEmpty) {
    return User.fromJson(result.first);
  }
  return null;
}

// Fetches all data from the specified table
Future<List<Map<String, dynamic>>> fetchData(String tableName) async {
  final connection = PostgreSQLConnectionManager.connection;
  final result = await connection.query('SELECT * FROM $tableName');

  if (kDebugMode) {
    print('Fetched $tableName data: $result');
  }
  return result.isNotEmpty ? result.map((row) => row.toColumnMap()).toList() : [];
}

// Searches for data in the specified table using the provided search query and substitution values
Future<List<Map<String, dynamic>>> searchData(String tableName,
    String searchQuery, Map<String, dynamic> substitutionValues) async {
  final connection = PostgreSQLConnectionManager.connection;
  final result = await connection.query(
      'SELECT * FROM $tableName WHERE $searchQuery',
      substitutionValues: substitutionValues);


  if (kDebugMode) {
    print(
        'Searched $tableName data with query: $searchQuery and substitution values: $substitutionValues. Result: $result');
  }

  return result.map((row) => row.toColumnMap()).toList();
}

// Inserts data into the specified table
Future<void> insertData(String tableName, Map<String, dynamic> data) async {
  final connection = PostgreSQLConnectionManager.connection;
  final columns = data.keys.join(', ');
  final values = data.keys.map((key) => '@$key').join(', ');

  await connection.execute(
    'INSERT INTO $tableName ($columns) VALUES ($values)',
    substitutionValues: data,
  );


  if (kDebugMode) {
    print('Inserted data into $tableName: $data');
  }
}

// Updates data in the specified table with the provided updated data
Future<void> updateData(
    String tableName, int id, Map<String, dynamic> updatedData) async {
  final connection = PostgreSQLConnectionManager.connection;
  final updates = updatedData.keys.map((key) => '$key = @$key').join(', ');

  await connection.execute(
    'UPDATE $tableName SET $updates WHERE id = @id',
    substitutionValues: {...updatedData, 'id': id},
  );


  if (kDebugMode) {
    print('Updated $tableName data with id $id. Updated data: $updatedData');
  }
}

// Deletes data from the specified table with the provided id
Future<void> deleteData(String tableName, int id) async {
  final connection = PostgreSQLConnectionManager.connection;
  await connection.execute('DELETE FROM $tableName WHERE id = @id',
      substitutionValues: {'id': id});

  if (kDebugMode) {
    print('Deleted $tableName data with id $id');
  }
}

// Fetches all data from the specified table
Future<List<Map<String, dynamic>>> getAll(String tableName) async {
  return fetchData(tableName);
}

// Searches for data in the specified table using the provided search query and substitution values
Future<List<Map<String, dynamic>>> search(String tableName, String searchQuery,
    Map<String, dynamic> substitutionValues) async {
  return searchData(tableName, searchQuery, substitutionValues);
}

// Inserts data into the specified table
Future<void> add(String tableName, Map<String, dynamic> data) async {
  await insertData(tableName, data);
}

// Updates data in the specified table with the provided updated data
Future<void> update(
    String tableName, int id, Map<String, dynamic> updatedData) async {
  await updateData(tableName, id, updatedData);
}

// Deletes data from the specified table with the provided id
Future<void> delete(String tableName, int id) async {
  await deleteData(tableName, id);
}
