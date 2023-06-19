import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/create_order_screen.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:flutter/material.dart';

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
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _peopleList = await WooSignalService.getCustomers();
    _searchResults = _peopleList;
    setState(() {});
  }

  void findPeple(query){
    var result = _peopleList.where((p) => p.firstName.contains(query)||  p.lastName.contains(query)|| p.phone.contains(query)).toList();
    _searchResults = result;
    setState(() {});
  }

  // Future<void> _fetchPeople(String query) async {
  //   // Define the details you want to search customers by
  //   String firstName = query;
  //   String lastName = query;
  //   String phone = query;
  //
  //   // Call the fetchCustomersByDetails function
  //   List<People> customers = await PeoplePostgres.fetchCustomersByDetails(
  //       firstName, lastName, phone);
  //   if (customers.isNotEmpty) {
  //     setState(() {
  //       _peopleList = customers;
  //     });
  //   }
  // }

  // void _search(String query) {
  //   if (query.isEmpty) {
  //     setState(() {
  //       _searchResults = [];
  //     });
  //   } else {
  //     _fetchPeople(query).then((_) {
  //       setState(() {
  //         _searchResults = _peopleList;
  //       });
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Search People'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.lightBlueAccent,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: findPeple,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    hintText: 'Search',
                  ),
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
                          MaterialPageRoute(
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
                            bottom: BorderSide(color: Colors.grey),
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
      ),
    );
  }
}
