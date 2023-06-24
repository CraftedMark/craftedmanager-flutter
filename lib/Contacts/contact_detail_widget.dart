// contact_detail_widget.dart
import 'package:contacts_service/contacts_service.dart';
import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:flutter/material.dart';

import 'syscontact_list.dart';

class ContactDetailWidget extends StatefulWidget {
  final People contact;
  final Function() refresh;

  const ContactDetailWidget(
      {Key? key, required this.contact, required this.refresh})
      : super(key: key);

  @override
  State<ContactDetailWidget> createState() => _ContactDetailWidgetState();
}

class _ContactDetailWidgetState extends State<ContactDetailWidget> {
  bool _editing = false;
  late People value;

  @override
  void initState() {
    value = widget.contact;
    if (value.id.isEmpty) {
      _editing = true;
    }
    super.initState();
  }

  // Function to navigate and display contacts from the system
  Future<void> _navigateAndDisplayContacts(BuildContext context) async {
    final Contact? contact = await showSystemContactList(context);
    if (contact != null) {
      setState(() {
        // Import the contact information into your app's Contact object
        value = value.copyWith(
          firstName: contact.givenName!,
          lastName: contact.familyName!,
          phone: contact.phones!.isNotEmpty ? contact.phones![0].value : '',
          email: contact.emails!.isNotEmpty ? contact.emails![0].value : '',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
      home: Scaffold(
        appBar: AppBar(
          title: Text('${value.firstName} ${value.lastName}'),
          actions: [
            TextButton(
              onPressed: () async {
                if (!_editing) {
                  setState(() => _editing = true);
                } else {
                  People? updatedContact;

                  if (value.id.isEmpty) {
                    String newId = await PeoplePostgres.createCustomer(value);
                    updatedContact = await PeoplePostgres.fetchCustomer(newId);
                  } else {
                    updatedContact = await PeoplePostgres.updateCustomer(value);
                  }

                  if (updatedContact != null && updatedContact.id.isNotEmpty) {
                    setState(() {
                      _editing = false;
                      value = updatedContact!;
                    });
                    widget.refresh();
                  } else {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to save contact.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                    setState(() => _editing = false);
                  }
                }
              },
              child: Text(_editing ? 'Save' : 'Edit'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('First Name', value.firstName,
                      (n) => value = value.copyWith(firstName: n)),
                  _buildTextField('Last Name', value.lastName,
                      (n) => value = value.copyWith(lastName: n)),
                  _buildTextField('Phone', value.phone,
                      (n) => value = value.copyWith(phone: n)),
                  _buildTextField('Email', value.email,
                      (n) => value = value.copyWith(email: n)),
                  _buildTextField('Address 1', value.address1,
                      (n) => value = value.copyWith(address1: n)),
                  _buildTextField('Address 2', value.address2,
                      (n) => value = value.copyWith(address2: n)),
                  _buildTextField('City', value.city,
                      (n) => value = value.copyWith(city: n)),
                  _buildTextField('State', value.state,
                      (n) => value = value.copyWith(state: n)),
                  _buildTextField(
                      'ZIP', value.zip, (n) => value = value.copyWith(zip: n)),
                  _buildTextField('Brand', value.brand,
                      (n) => value = value.copyWith(brand: n)),
                  _buildTextField('Account Number', value.accountNumber,
                      (n) => value = value.copyWith(accountNumber: n)),
                  _buildTextField('Type', value.type,
                      (n) => value = value.copyWith(type: n)),
                  _buildSwitchRow(
                      'Customer-Based Pricing',
                      value.customerBasedPricing ?? false,
                      (n) => value = value.copyWith(customerBasedPricing: n)),
                  _buildTextField('Notes', value.notes,
                      (n) => value = value.copyWith(notes: n)),
                  // Add a Load System Contacts button
                  ElevatedButton(
                    onPressed: () async {
                      final Contact? systemContact =
                          await showSystemContactList(context);
                      if (systemContact != null) {
                        setState(() {
                          value = value.copyWith(
                            firstName: systemContact.givenName!,
                            lastName: systemContact.familyName!,
                            phone: systemContact.phones!.isNotEmpty
                                ? systemContact.phones![0].value
                                : '',
                            email: systemContact.emails!.isNotEmpty
                                ? systemContact.emails![0].value
                                : '',
                          );
                        });
                      }
                    },
                    child: Text('Load System Contacts'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String? value, void Function(String) setter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _editing
            ? TextField(
                onChanged: setter,
                controller: TextEditingController(text: value ?? ''),
              )
            : Text(value ?? 'N/A'),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, void Function(bool) setter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _editing
            ? Switch(
                value: value,
                onChanged: setter,
              )
            : Text(value ? 'Yes' : 'No'),
      ],
    );
  }
}
