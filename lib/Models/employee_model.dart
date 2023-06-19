class Employee {
  final int? employeeID;
  final String firstName;
  final String lastName;
  final double payRate;
  final DateTime? dateOfHire;
  final String position;
  final String email;
  final String phone;
  final String imageUrl; // Add this field for image URL
  String imagePath;

  Employee({
    this.employeeID,
    required this.firstName,
    required this.lastName,
    required this.payRate,
    required this.dateOfHire,
    required this.position,
    required this.email,
    required this.phone,
    required this.imageUrl, // Add this field for image URL
    required this.imagePath, // Add this line
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeID: map['id'] as int?,
      firstName: map['firstname'] as String? ?? '',
      lastName: map['lastname'] as String? ?? '',
      payRate: (map['payrate'] as String?) != null
          ? double.tryParse(map['payrate'] as String) ?? 0.0
          : 0.0,
      phone: map['phone'] as String? ?? '',
      position: map['position'] as String? ?? '',
      email: map['email'] as String? ?? '',
      dateOfHire: map['dateofhire'] as DateTime?,
      imageUrl: map['imageurl'] as String? ?? '',
      imagePath: map["imagePath"] as String? ?? '', // Add this line
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
        "imageurl": imageUrl,
        "imagePath": imagePath, // Add this line// Add this field for image URL
      };
}
