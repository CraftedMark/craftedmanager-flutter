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
    PostgreSQLConnectionManager.init();
    await PostgreSQLConnectionManager.open();

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
}
