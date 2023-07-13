import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/plus_button.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../Models/people_model.dart';
import '../Providers/people_provider.dart';
import '../WooCommerce/woosignal-service.dart';
import '../assets/ui.dart';
import '../config.dart';
import '../widgets/search_field_for_appbar.dart';
import 'contact_detail_widget.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({Key? key}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<People> _contacts = [];
  List<People> _filteredContacts = [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PeopleProvider>(context, listen: false).filterPeoples('');
    });
  }

  Future<void> refreshContacts() async {

    var contacts = <People>[];
    if (AppConfig.ENABLE_WOOSIGNAL) {
      contacts = await WooSignalService.getCustomers();
    } else {
      contacts = await PeoplePostgres.refreshCustomerList();
    }
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  void filterContacts(PeopleProvider provider, String query){
    provider.filterPeoples(query);
  }

  Future<void> deleteCustomer(PeopleProvider provider, People customer) async {
    await provider.deletePerson(customer.id);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<PeopleProvider>(
      builder: (context, provider, _) {
        _contacts = provider.peoples;
        _filteredContacts = provider.filteredPeoples;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: UIConstants.GREY_MEDIUM,
            title: const Text('Contact'),
            bottom: searchField(
                context,
                (query)=>filterContacts(provider, query)
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PlusButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailWidget(
                          contact: People.empty(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          body: _filteredContacts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                  itemCount: _filteredContacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final textStyle = Theme.of(context).textTheme.bodySmall;
                    final contact = _filteredContacts[index];

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
                        ),
                      ),
                      onDismissed: (direction) async {
                        await deleteCustomer(provider,contact);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactDetailWidget(
                                  contact: contact,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${contact.firstName} ${contact.lastName}',
                                  style: TextStyle(color: UIConstants.WHITE_LIGHT),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Phone:', style: textStyle),
                                    Text(parsePhoneNumber(contact.phone),
                                        style: textStyle),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Email:', style: textStyle),
                                    Text(contact.email, style: textStyle),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Brand:', style: textStyle),
                                    Text(contact.brand ?? '-', style: textStyle),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return const Column(
                      children: [
                        SizedBox(height: 4),
                        DividerCustom(),
                        SizedBox(height: 4),
                      ],
                    );
                  },
                ),
        );
      }
    );
  }
}
