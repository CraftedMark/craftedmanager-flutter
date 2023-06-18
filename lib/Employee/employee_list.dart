import 'package:crafted_manager/Employee/employee_db_manager.dart';
import 'package:crafted_manager/Models/employee_model.dart';
import 'package:flutter/material.dart';

import 'add_employee.dart'; // Import the EmployeePage

class EmployeeManager extends StatefulWidget {
  @override
  _EmployeeManagerState createState() => _EmployeeManagerState();
}

class _EmployeeManagerState extends State<EmployeeManager> {
  final EmployeeDatabaseManager _dbManager = EmployeeDatabaseManager();

  Future<List<Employee>> _fetchEmployees() async {
    try {
      List<Employee> employees = await _dbManager.getEmployees();
      return employees;
    } catch (e) {
      print('Error while fetching employees: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Manager'),
      ),
      body: FutureBuilder<List<Employee>>(
        future: _fetchEmployees(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Employee employee = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(employee.firstName[0]),
                  ),
                  title: Text('${employee.firstName} ${employee.lastName}'),
                  subtitle: Text(employee.email),
                  onTap: () {
                    // TODO: Navigate to Employee Detail screen
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading employees'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeePage(),
            ),
          );
        },
      ),
    );
  }
}
