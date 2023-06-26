import 'package:crafted_manager/Models/people_model.dart';
import 'package:uuid/uuid.dart';

import '../PostresqlConnection/postqresql_connection_manager.dart';

class PeoplePostgres {
  static Future<People> fetchCustomer(String id) async {
    final connection = PostgreSQLConnectionManager.connection;

    List<Map<String, Map<String, dynamic>>> results = await connection
        .mappedResultsQuery('SELECT * FROM people WHERE id = @id',
            substitutionValues: {'id': id});

    if (results.isNotEmpty) {
      return People.fromMap(results.first['people']!);
    } else {
      throw Exception('No customer data found with ID: $id');
    }
  }

  static Future<List<People>> fetchCustomers() async {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query('SELECT * FROM people');

    return result.map((row) => People.fromMap(row.toColumnMap())).toList();
  }

  static Future<List<People>> refreshCustomerList() async {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query('SELECT * FROM people');

    return result.map((row) => People.fromMap(row.toColumnMap())).toList();
  }

  static Future<People?> updateCustomer(People customer) async {
    if (customer.id == null || customer.id.isEmpty) {
      throw Exception('Invalid ID: Customer ID is null or empty');
    }

    final connection = PostgreSQLConnectionManager.connection;
    final map = customer.toMap();
    final values = <String>[];
    map.forEach((key, value) {
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

    final result = await connection.query(
        'SELECT * FROM people WHERE id = @customerId',
        substitutionValues: {'customerId': customer.id});

    return result.isNotEmpty
        ? People.fromMap(result.first.toColumnMap())
        : null;
  }

  static Future<void> deleteCustomer(String customerId) async {
    if (customerId == null || customerId.isEmpty) {
      throw Exception('Invalid ID: Customer ID is null or empty');
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

  static Future<String> createCustomer(People customer) async {
    final connection = PostgreSQLConnectionManager.connection;
    final newId = Uuid().v4(); // Generate new UUID

    final map = customer.toMap()
      ..['id'] = newId; // Update the id field with the new UUID

    final columns = map.keys.join(', ');
    final values = map.values
        .map((value) => value == null ? 'NULL' : "'$value'")
        .join(', ');

    await connection.execute(
      "INSERT INTO people ($columns) VALUES ($values)",
    );

    return newId; // Return the new contact UUID
  }
}
