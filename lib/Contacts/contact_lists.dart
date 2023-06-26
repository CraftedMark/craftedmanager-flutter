import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../Models/people_model.dart';
import '../WooCommerce/woosignal-service.dart';
import '../config.dart';
import 'contact_detail_widget.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  ContactsListState createState() => ContactsListState();
}

class ContactsListState extends State<ContactsList> {
  List<People> _contacts = [];
  List<People> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();

  String parsePhoneNumber(String number) {
    try {
      final phoneNumber = PhoneNumber(isoCode: 'US', phoneNumber: number);
      return phoneNumber.parseNumber();
    } catch (e) {
      return number; // If the phone number cannot be parsed, return it as-is
    }
  }

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    var contacts = <People>[];
    if(AppConfig.ENABLE_WOOSIGNAL){
      contacts = await WooSignalService.getCustomers();
    }else{
      contacts = await PeoplePostgres.refreshCustomerList();
    }

    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  Future<void> deleteCustomer(People customer) async {
    _filteredContacts!.removeWhere((c) => c.id == customer.id);
    setState(() {});

    if(AppConfig.ENABLE_WOOSIGNAL){
      await WooSignalService.deleteCustomer(customer.id);
    }else{
      await PeoplePostgres.deleteCustomer(customer.id);
    }
    await refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _filteredContacts = _contacts
                        .where((contact) =>
                            contact.firstName
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            contact.lastName
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search Contacts...'),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailWidget(
                    contact: People.empty(),// Create a new contact with default values
                    refresh: refreshContacts,
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: _filteredContacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredContacts!.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts![index];
                return Dismissible(
                  key: Key(contact.id.toString()),
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.delete_forever, color: Colors.white),
                        Icon(Icons.delete_forever, color: Colors.white),
                      ],
                    ),),
                  onDismissed: (direction) {
                    deleteCustomer(contact);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailWidget(
                            contact: contact,
                            refresh: refreshContacts,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: _filteredContacts != null
                          ? Text('${contact.firstName} ${contact.lastName}')
                          : CircularProgressIndicator(),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone: ${parsePhoneNumber(contact.phone)}'),
                          // Apply parsing
                          Text('Email: ${contact.email}'),
                          // Included email
                          Text('Brand: ${contact.brand}'),
                          // Included brand
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
