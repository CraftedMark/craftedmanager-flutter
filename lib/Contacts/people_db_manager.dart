import 'dart:math';

import 'package:crafted_manager/Models/people_model.dart';

import '../PostresqlConnection/postqresql_connection_manager.dart';

class PeoplePostgres {
  // Fetch a customer by customerId
  static Future<People?> fetchCustomer(int customerId) async {
    // Change the argument type to int
    if (customerId <= 0) {
      throw Exception('Invalid ID: Customer ID must be a positive integer');
    }

    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query(
        'SELECT * FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customerId});

    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  // Refresh the customer list
  static Future<List<People>> refreshCustomerList() async {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query('SELECT * FROM people');

    return result.map((row) => People.fromMap(row.toColumnMap())).toList();
  }

  static Future<People?> updateCustomer(People customer) async {
    if (customer.id <= 0) {
      throw Exception('Invalid ID: Customer ID must be a positive integer');
    }

    final connection = PostgreSQLConnectionManager.connection;
    final map = customer.toMap();
    final values = <String>[];
    map.forEach((key, value) {
      // Skip updating createdby, updatedby, and null timestamp columns
      if (key != "createdby" &&
          key != "updatedby" &&
          !(value == null && (key == "created" || key == "updated"))) {
        values.add("$key = ${value != null ? "'$value'" : 'NULL'}");
      }
    });
    final allValues = values.join(",\n");
    await connection.execute(
        "UPDATE people SET $allValues WHERE id = @customerId",
        substitutionValues: {'customerId': customer.id});

    // Fetch the updated customer data
    final result = await connection.query(
        'SELECT * FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customer.id});

    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  static Future<void> deleteCustomer(int customerId) async {
    if (customerId <= 0) {
      throw Exception('Invalid ID: Customer ID must be a positive integer');
    }

    final connection = PostgreSQLConnectionManager.connection;
    await connection.execute('DELETE FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customerId});

  }

  static Future<List<People>> fetchCustomersByDetails(
      String firstName, String lastName, String phone) async {
    List<People> customers = [];
    try {
      final connection = PostgreSQLConnectionManager.connection;
      final result = await connection.query('''
      SELECT * FROM people WHERE
      LOWER(firstname) LIKE LOWER(@firstName) OR
      LOWER(lastname) LIKE LOWER(@lastName) OR
      phone LIKE @phone
    ''', substitutionValues: {
        'firstName': '%$firstName%',
        'lastName': '%$lastName%',
        'phone': '%$phone%',
      });

      for (var row in result) {
        customers.add(People.fromMap(row.toColumnMap()));
      }
    } catch (e) {
      print('Error fetching customers by details: ${e.toString()}');
    }
    return customers;
  }

  static Future<int> createCustomer(People customer) async {
    final connection = PostgreSQLConnectionManager.connection;
    final random = Random(); // Create a Random instance
    final newId = random.nextInt(1 << 32); // Generate a random 32-bit integer

    final map = customer.toMap()
      ..['id'] = newId; // Update the id field with the new integer ID

    final columns = map.keys.join(', ');
    final values = map.values
        .map((value) => value == null ? 'NULL' : "'$value'")
        .join(', ');

    await connection.execute(
      "INSERT INTO people ($columns) VALUES ($values)",
    );


    return newId; // Return the new contact ID
  }
}
