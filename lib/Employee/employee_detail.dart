import 'package:crafted_manager/Models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeeDetail extends StatelessWidget {
  final Employee employee;

  EmployeeDetail({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${employee.firstName} ${employee.lastName}',
            style: TextStyle(color: Colors.purple[900])),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('${employee.firstName} ${employee.lastName}',
                style: TextStyle(fontSize: 24.0, color: Colors.white)),
            SizedBox(height: 20),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('Email', style: TextStyle(color: Colors.white)),
                subtitle: Text('${employee.email}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('Phone', style: TextStyle(color: Colors.white)),
                subtitle: Text('${employee.phone}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('Position', style: TextStyle(color: Colors.white)),
                subtitle: Text('${employee.position}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('Pay Rate', style: TextStyle(color: Colors.white)),
                subtitle: Text('\$${employee.payRate}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title:
                    Text('Date of Hire', style: TextStyle(color: Colors.white)),
                subtitle: Text('${employee.dateOfHire?.toString()}',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
