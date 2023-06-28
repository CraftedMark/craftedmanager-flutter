import 'package:crafted_manager/Models/employee_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:flutter/foundation.dart';

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];

  List<Employee> get employees => [..._employees];

  Future<List<Employee>> getEmployees() async {
    await fetchAndSetEmployees();
    return _employees;
  }

  Future<void> fetchAndSetEmployees() async {
    List<Map<String, Map<String, dynamic>>> results =
        await PostgreSQLConnectionManager.connection
            .mappedResultsQuery('SELECT * FROM employee');

    _employees = results.map((item) {
      return Employee(
        employeeID: (item['employeeID'] as int?) ?? 0,
        firstName: (item['firstName'] as String?) ?? '',
        lastName: (item['lastName'] as String?) ?? '',
        payRate: (item['payRate'] as double?) ?? 0.0,
        dateOfHire: item['dateOfHire'] as DateTime?,
        position: (item['position'] as String?) ?? '',
        email: (item['email'] as String?) ?? '',
        phone: (item['phone'] as String?) ?? '',
        imageUrl: (item['imageUrl'] as String?) ?? '',
        imagePath: (item['imagePath'] as String?) ?? '',
      );
    }).toList();

    notifyListeners();

    await PostgreSQLConnectionManager.close();
  }

  Future<List<Employee>> fetchEmployeesByOrderId(String orderId) async {
    List<Employee> employees = [];
    try {
      final connection = PostgreSQLConnectionManager.connection;
      final result = await connection.query(
        'SELECT * FROM employees WHERE order_id = @orderId',
        substitutionValues: {
          'orderId': orderId,
        },
      );

      for (var row in result) {
        employees.add(Employee.fromMap(row.toColumnMap()));
      }
    } catch (e) {
      print('Error fetching employees by order id: ${e.toString()}');
    }
    return employees;
  }
}
