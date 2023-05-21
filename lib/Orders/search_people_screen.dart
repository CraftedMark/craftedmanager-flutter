import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/create_order_screen.dart';
import 'package:flutter/cupertino.dart';

class SearchPeopleScreen extends StatefulWidget {
  @override
  State<SearchPeopleScreen> createState() => _SearchPeopleScreenState();
}

class _SearchPeopleScreenState extends State<SearchPeopleScreen> {
  List<People> _peopleList = [];

  List<People> _searchResults = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchPeople(String query) async {
    // Define the details you want to search customers by
    String firstName = query;
    String lastName = query;
    String phone = query;

    // Call the fetchCustomersByDetails function
    List<People> customers = await PeoplePostgres.fetchCustomersByDetails(
        firstName, lastName, phone);
    if (customers.isNotEmpty) {
      setState(() {
        _peopleList = customers;
      });
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    } else {
      _fetchPeople(query).then((_) {
        setState(() {
          _searchResults = _peopleList;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search People'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: CupertinoTextField(
                onChanged: _search,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                placeholder: 'Search',
                clearButtonMode: OverlayVisibilityMode.editing,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  People person = _searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              CreateOrderScreen(client: person),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: CupertinoColors.systemGrey4),
                        ),
                      ),
                      child: Text('${person.firstName} ${person.lastName}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}