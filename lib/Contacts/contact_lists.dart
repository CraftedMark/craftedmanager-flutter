import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:flutter/material.dart';

import '../Models/people_model.dart';
import '../WooCommerce/woosignal-service.dart';
import 'contact_detail_widget.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  ContactsListState createState() => ContactsListState();
}

class ContactsListState extends State<ContactsList> {
  List<People>? _contacts;
  List<People>? _filteredContacts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    final contacts = await PeoplePostgres.refreshCustomerList();

    // final contacts = await WooSignalService.getCustomers();//TODO: enable WooSignal
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  Future<void> deleteCustomer(People customer) async {
    _filteredContacts!.removeWhere((c) => c.id == customer.id);
    setState(() {});
    await PeoplePostgres.deleteCustomer(customer.id);
    // await WooSignalService.deleteCustomer(customer.id); //TODO: enable WooSignal
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
                onEditingComplete: ()=>print('tap completed'),//TODO: remove after check
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
      body: _filteredContacts == null
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
                        Icon(Icons.delete_forever),
                        Icon(Icons.delete_forever),
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
                          : const CircularProgressIndicator(),
                      subtitle: Text(contact.phone),
                    ),
                  ),
                );
              }),
    );
  }
}
