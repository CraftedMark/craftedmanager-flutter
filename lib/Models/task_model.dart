import 'package:crafted_manager/Models/employee_model.dart';
import 'package:crafted_manager/Models/order_model.dart';

class Task {
  final Order order;
  final List<Employee> employees; // changed from Employee to List<Employee>
  final String name;
  final DateTime startTime;
  final DateTime stopTime;
  final String notes;

  Task(this.order, this.employees, this.name, this.startTime, this.stopTime,
      this.notes);

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      Order.fromMap(map), // assuming Order has a fromMap constructor
      List<Employee>.from(map['employees']?.map((x) =>
          Employee.fromMap(x))), // convert list of maps into list of Employees
      map['name'],
      DateTime.parse(map['start_time']),
      DateTime.parse(map['stop_time']),
      map['notes'],
    );
  }
}
