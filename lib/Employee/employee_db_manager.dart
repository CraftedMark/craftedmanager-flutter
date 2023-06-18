import 'package:crafted_manager/Models/employee_model.dart';
import 'package:postgres/postgres.dart';

import '../PostresqlConnection/postqresql_connection_manager.dart';

class EmployeeDatabaseManager {
  final PostgreSQLConnection _connection =
      PostgreSQLConnectionManager.connection;

  Future<int> createEmployee(Employee employee) async {
    // Check if there already exists an employee with the same first name, last name or email
    var existingEmployees = await _connection.query(
      'SELECT * FROM employee WHERE firstName = @a AND lastName = @b OR email = @c',
      substitutionValues: {
        'a': employee.firstName,
        'b': employee.lastName,
        'c': employee.email,
      },
    );

    if (existingEmployees.isNotEmpty) {
      throw Exception('Employee with the same name or email already exists');
    }

    // SQL statement to insert a new Employee if no duplicate is found
    var result = await _connection.query(
      'INSERT INTO employee (firstname, lastname, payrate, phone, position, email, dateofhire) VALUES (@a, @b, @c, @d, @e, @f, @g)',
      substitutionValues: {
        'a': employee.firstName,
        'b': employee.lastName,
        'c': employee.payRate,
        'd': employee.phone,
        'e': employee.position,
        'f': employee.email,
        'g': employee.dateOfHire?.toIso8601String(),
      },
    );
    return result.affectedRowCount;
  }

  Future<List<Employee>> getEmployees() async {
    // SQL statement to fetch all employees
    var result = await _connection.query('SELECT * FROM employee');
    return result.map((row) {
      return Employee.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<int> updateEmployee(Employee employee) async {
    // SQL statement to update an existing Employee
    var result = await _connection.query(
      'UPDATE employee SET firstname = @a, lastname = @b, payrate = @c, phone = @d, position = @e, email = @f, dateofhire = @g WHERE id = @h',
      substitutionValues: {
        'a': employee.firstName,
        'b': employee.lastName,
        'c': employee.payRate,
        'd': employee.phone,
        'e': employee.position,
        'f': employee.email,
        'g': employee.dateOfHire?.toIso8601String(),
        'h': employee.employeeID,
      },
    );
    return result.affectedRowCount;
  }

  Future<List<Employee>> searchEmployees(String searchTerm) async {
    // SQL statement to search employees based on the search term
    var result = await _connection.query(
      'SELECT * FROM employee WHERE firstname LIKE @a OR lastname LIKE @a',
      substitutionValues: {
        'a': '%$searchTerm%',
      },
    );
    return result.map((row) {
      return Employee.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<int> deleteEmployee(int id) async {
    // SQL statement to delete an Employee by id
    var result = await _connection.query('DELETE FROM employee WHERE id = @a',
        substitutionValues: {'a': id});
    return result.affectedRowCount;
  }
}
