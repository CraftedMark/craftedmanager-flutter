// contact_detail_widget.dart
import 'package:contacts_service/contacts_service.dart';
import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:flutter/material.dart';

import '../WooCommerce/woosignal-service.dart';
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
  late People newCustomer;

  @override
  void initState() {
    newCustomer = widget.contact;
    if (newCustomer.id <= 0) {
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
        newCustomer = newCustomer.copyWith(
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
          title: Text('${newCustomer.firstName} ${newCustomer.lastName}'),
          actions: [
            TextButton(
              onPressed: onSaveEditButtonClick,
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
                  _buildTextField('First Name*', newCustomer.firstName,
                      (n) => newCustomer = newCustomer.copyWith(firstName: n),
                    textInputType: TextInputType.name, maxLenght: 30
                  ),
                  _buildTextField('Last Name*', newCustomer.lastName,
                      (n) => newCustomer = newCustomer.copyWith(lastName: n),
                      textInputType: TextInputType.name, maxLenght: 30
                  ),
                  _buildTextField('Phone*', newCustomer.phone,
                      (n) => newCustomer = newCustomer.copyWith(phone: n),
                      textInputType: TextInputType.phone, maxLenght: 10
                  ),
                  _buildTextField('Email*', newCustomer.email,
                      (n) => newCustomer = newCustomer.copyWith(email: n),
                      textInputType: TextInputType.emailAddress,
                  ),
                  _buildTextField('Address 1*', newCustomer.address1,
                      (n) => newCustomer = newCustomer.copyWith(address1: n),
                      textInputType: TextInputType.streetAddress),
                  _buildTextField('Address 2', newCustomer.address2,
                      (n) => newCustomer = newCustomer.copyWith(address2: n)),
                  _buildTextField('City*', newCustomer.city,
                      (n) => newCustomer = newCustomer.copyWith(city: n)),
                  _buildTextField('State*', newCustomer.state,
                      (n) => newCustomer = newCustomer.copyWith(state: n),
                  textInputType: TextInputType.text, maxLenght: 2),
                  _buildTextField('ZIP*', newCustomer.zip,
                      (n) => newCustomer = newCustomer.copyWith(zip: n),
                      textInputType: TextInputType.number, maxLenght: 5),
                  _buildTextField('Brand', newCustomer.brand,
                      (n) => newCustomer = newCustomer.copyWith(brand: n)),
                  _buildTextField('Account Number', newCustomer.accountNumber,
                      (n) => newCustomer = newCustomer.copyWith(accountNumber: n)),
                  _buildTextField('Type', newCustomer.type,
                      (n) => newCustomer = newCustomer.copyWith(type: n)),
                  _buildSwitchRow(
                      'Customer-Based Pricing',
                      newCustomer.customerBasedPricing ?? false,
                      (n) => newCustomer = newCustomer.copyWith(customerBasedPricing: n)),
                  _buildTextField('Notes', newCustomer.notes,
                      (n) => newCustomer = newCustomer.copyWith(notes: n)),
                  // Add a Load System Contacts button
                  ElevatedButton(
                    onPressed: () async {
                      final Contact? systemContact =
                          await showSystemContactList(context);
                      if (systemContact != null) {
                        setState(() {
                          newCustomer = newCustomer.copyWith(
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

  Future<void> onSaveEditButtonClick() async {
    setState(() => _editing = !_editing);

    if (newCustomer.id <= 0) {
      print('try to create a customer name: ${newCustomer.firstName}');

      var newId = await WooSignalService.createCustomer(newCustomer);
      if(newId == -1 ){
        await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Incorrent info'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
      }
      newCustomer = newCustomer.copyWith(id: newId);
    } else {
      print('try to update a customer id: ${newCustomer.id}');
      await WooSignalService.updateCustomer(newCustomer);
    }
    widget.refresh();
  }


  Widget _buildTextField(
    String label,
    String? value,
    void Function(String) setter, {
    TextInputType textInputType = TextInputType.text,
    int? maxLenght,
      }
  ) {
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
          maxLength: maxLenght,
          keyboardType: textInputType,
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
