import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:flutter/material.dart';

import '../Models/people_model.dart';
import 'contact_detail_widget.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  ContactsListState createState() => ContactsListState();
}

class ContactsListState extends State<ContactsList> {
  List<People>? _contacts;
  List<People>? _filteredContacts;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    final contacts = await PeoplePostgres.refreshCustomerList();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  Future<void> deleteCustomer(People customer) async {
    await PeoplePostgres.deleteCustomer(customer.id);
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
                    _filteredContacts = _contacts!
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
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search Contacts...'),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Create a new contact with default values
              People newContact = People(
                  id: '', firstName: '', lastName: '', phone: '', email: '');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailWidget(
                    contact: newContact,
                    refresh: refreshContacts,
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: _filteredContacts == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredContacts!.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts![index];
                return Dismissible(
                  key: Key(contact.id),
                  background: Container(color: Colors.red),
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
                      subtitle: Text(contact.phone),
                    ),
                  ),
                );
              }),
    );
  }
}
