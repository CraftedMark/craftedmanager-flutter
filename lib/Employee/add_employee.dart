import 'package:crafted_manager/Employee/employee_db_manager.dart';
import 'package:crafted_manager/Models/employee_model.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final _employeeDbManager = EmployeeDatabaseManager();
  final _employeeFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _payRateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfHireController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Employee Added'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Employee has been successfully added.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _employeeFormKey,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value!.isEmpty == true) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _payRateController,
                    decoration: InputDecoration(labelText: 'Pay Rate'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter pay rate';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _positionController,
                    decoration: InputDecoration(labelText: 'Position'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter position';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateOfHireController,
                    decoration: InputDecoration(labelText: 'Date of Hire'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate)
                        setState(() {
                          _selectedDate = picked;
                          _dateOfHireController.text =
                              _selectedDate!.toIso8601String().split('T')[0];
                        });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter date of hire';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_employeeFormKey.currentState!.validate()) {
                        try {
                          Employee employee = Employee(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            payRate: double.parse(_payRateController.text),
                            phone: _phoneController.text,
                            position: _positionController.text,
                            email: _emailController.text,
                            dateOfHire: DateTime.parse(
                                _dateOfHireController.text + 'T00:00:00'),
                            employeeID: null,
                          );
                          await _employeeDbManager.createEmployee(employee);
                          _showSuccessDialog(); // added this line
                          setState(() {});
                        } catch (e) {
                          // Show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    child: Text('Add Employee'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Employee>>(
              future: _employeeDbManager.getEmployees(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            '${snapshot.data![index].firstName} ${snapshot.data![index].lastName}'),
                        subtitle: Text(
                            'Pay Rate: \$${snapshot.data![index].payRate}'),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
