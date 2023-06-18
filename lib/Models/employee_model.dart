class Employee {
  final String? employeeID;
  final String firstName;
  final String lastName;
  final double payRate;
  final DateTime? dateOfHire;
  final String position;
  final String email;
  final String phone;

  Employee({
    this.employeeID,
    required this.firstName,
    required this.lastName,
    required this.payRate,
    required this.dateOfHire,
    required this.position,
    required this.email,
    required this.phone,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeID: map['id']?.toString(),
      firstName: map['firstname'] as String? ?? '',
      lastName: map['lastname'] as String? ?? '',
      payRate: double.parse(map['payrate'].toString()),
      phone: map['phone'] as String? ?? '',
      position: map['position'] as String? ?? '',
      email: map['email'] as String? ?? '',
      dateOfHire: map['dateofhire'] as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        "EmployeeID": employeeID,
        "FirstName": firstName,
        "LastName": lastName,
        "PayRate": payRate,
        "DateOfHire": dateOfHire?.toIso8601String(),
        "Position": position,
        "Email": email,
        "Phone": phone,
      };
}
