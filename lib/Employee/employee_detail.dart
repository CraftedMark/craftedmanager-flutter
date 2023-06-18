import 'package:crafted_manager/Models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeeDetail extends StatelessWidget {
  final Employee employee;

  EmployeeDetail({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee.firstName} ${employee.lastName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${employee.firstName}'),
            Text('Last Name: ${employee.lastName}'),
            Text('Email: ${employee.email}'),
            Text('Phone: ${employee.phone}'),
            Text('Position: ${employee.position}'),
            Text('Pay Rate: ${employee.payRate}'),
            Text('Date of Hire: ${employee.dateOfHire?.toString()}'),
          ],
        ),
      ),
    );
  }
}
