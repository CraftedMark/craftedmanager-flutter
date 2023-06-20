import 'package:crafted_manager/Models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeeDetail extends StatelessWidget {
  final Employee employee;

  const EmployeeDetail({super.key, required this.employee});

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
                style: const TextStyle(fontSize: 24.0, color: Colors.white)),
            const SizedBox(height: 20),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: const Text('Email', style: TextStyle(color: Colors.white)),
                subtitle: Text(employee.email,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: const Text('Phone', style: TextStyle(color: Colors.white)),
                subtitle: Text(employee.phone,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: const Text('Position', style: TextStyle(color: Colors.white)),
                subtitle: Text(employee.position,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: const Text('Pay Rate', style: TextStyle(color: Colors.white)),
                subtitle: Text('\$${employee.payRate}',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title:
                const Text('Date of Hire', style: TextStyle(color: Colors.white)),
                subtitle: Text('${employee.dateOfHire?.toString()}',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
