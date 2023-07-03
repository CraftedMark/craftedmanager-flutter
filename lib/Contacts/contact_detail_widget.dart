import 'package:contacts_service/contacts_service.dart';
import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/config.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:flutter/material.dart';

import '../WooCommerce/woosignal-service.dart';
import '../widgets/big_button.dart';
import '../widgets/text_input_field.dart';
import '../widgets/tile.dart';
import 'syscontact_list.dart';

class ContactDetailWidget extends StatefulWidget {
  final People contact;
  final Function() refresh;

  const ContactDetailWidget(
      {Key? key, required this.contact, required this.refresh})
      : super(key: key);

  @override
  _ContactDetailWidgetState createState() => _ContactDetailWidgetState();
}

class _ContactDetailWidgetState extends State<ContactDetailWidget> {
  bool isEditMode = false;
  late People newCustomer;

  @override
  void initState() {
    newCustomer = widget.contact;
    if (newCustomer.id.isEmpty) {
      isEditMode = true;
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('${newCustomer.firstName} ${newCustomer.lastName}'),
        actions: [
          TextButton(
            onPressed: onSaveEditButtonClick,
            child: Text(isEditMode ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                section(
                  'Profile',
                  [
                    _buildTextField(
                      'First Name*',
                      newCustomer.firstName,
                      (n) => newCustomer = newCustomer.copyWith(firstName: n),
                      textInputType: TextInputType.name,
                      maxLength: 30,
                    ),
                    _buildTextField(
                      'Last Name*',
                      newCustomer.lastName,
                      (n) => newCustomer = newCustomer.copyWith(lastName: n),
                      textInputType: TextInputType.name,
                      maxLength: 30,
                    ),
                    _buildTextField('Phone*', newCustomer.phone,
                        (n) => newCustomer = newCustomer.copyWith(phone: n),
                        textInputType: TextInputType.phone, maxLength: 10),
                    _buildTextField(
                      'Email*',
                      newCustomer.email,
                      (n) => newCustomer = newCustomer.copyWith(email: n),
                      textInputType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                section(
                  'Address',
                  [
                    _buildTextField(
                      'Address 1*',
                      newCustomer.address1,
                      (n) => newCustomer = newCustomer.copyWith(address1: n),
                      textInputType: TextInputType.streetAddress,
                    ),
                    _buildTextField(
                      'Address 2',
                      newCustomer.address2,
                      (n) => newCustomer = newCustomer.copyWith(address2: n),
                    ),
                    _buildTextField(
                      'City*',
                      newCustomer.city,
                      (n) => newCustomer = newCustomer.copyWith(city: n),
                    ),
                    _buildTextField(
                      'State*',
                      newCustomer.state,
                      (n) => newCustomer = newCustomer.copyWith(state: n),
                      textInputType: TextInputType.text,
                      maxLength: 2,
                    ),
                    _buildTextField(
                      'ZIP*',
                      newCustomer.zip,
                      (n) => newCustomer = newCustomer.copyWith(zip: n),
                      textInputType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                section(
                  'Account',
                  [
                    _buildTextField(
                      'Brand',
                      newCustomer.brand,
                      (n) => newCustomer = newCustomer.copyWith(brand: n),
                    ),
                    _buildTextField(
                      'Account Number',
                      newCustomer.accountNumber,
                      (n) =>
                          newCustomer = newCustomer.copyWith(accountNumber: n),
                    ),
                    _buildTextField(
                      'Type',
                      newCustomer.type,
                      (n) => newCustomer = newCustomer.copyWith(type: n),
                    ),
                    _buildTextField(
                      'Notes',
                      newCustomer.notes,
                      (n) => newCustomer = newCustomer.copyWith(notes: n),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchRow(
                      'Customer-Based Pricing',
                      newCustomer.customerBasedPricing ?? false,
                      (n) {
                        newCustomer =
                            newCustomer.copyWith(customerBasedPricing: n);
                        setState(() {});
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                BigButton(
                  text: 'Load System Contacts',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget section(String name, List<Widget> children) {
    if (!isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Tile(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          ...children
        ],
      );
    }
  }

  Future<void> onSaveEditButtonClick() async {
    setState(() => isEditMode = !isEditMode);

    if (newCustomer.id.isEmpty) {
      print('try to create a customer name: ${newCustomer.firstName}');

      String newId = '';
      if (AppConfig.ENABLE_WOOSIGNAL) {
        // newId = await WooSignalService.createCustomer(newCustomer);
      } else {
        newId = await PeoplePostgres.createCustomer(newCustomer);
      }

      if (newId == '-1') {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Incorrect info'),
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

      if (AppConfig.ENABLE_WOOSIGNAL) {
        await WooSignalService.updateCustomer(newCustomer);
      } else {
        await PeoplePostgres.updateCustomer(newCustomer);
      }
    }
    widget.refresh();
  }

  Widget _buildTextField(
    String label,
    String? value,
    void Function(String) setter, {
    TextInputType textInputType = TextInputType.text,
    int? maxLength,
  }) {
    if (!isEditMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? 'N/A',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: UIConstants.WHITE_LIGHT),
          ),
          const DividerCustom(),
          const SizedBox(height: 14),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextInputField(
              initialValue: value,
              labelText: label,
              onChange: setter,
            ),
          )
        ],
      );
    }
  }

  Widget _buildSwitchRow(String label, bool value, void Function(bool) setter) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        isEditMode
            ? Switch(
                value: value,
                onChanged: setter,
              )
            : Text(value ? 'Yes' : 'No'),
      ],
    );
  }
}
