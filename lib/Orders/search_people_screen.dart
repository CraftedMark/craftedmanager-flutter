import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/Orders/create_order_screen.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/search_field_for_appbar.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class SearchPeopleScreen extends StatefulWidget {
  const SearchPeopleScreen({super.key});

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

    if(AppConfig.ENABLE_WOOSIGNAL){
      _peopleList = await WooSignalService.getCustomers();
    }else{
      _peopleList = await PeoplePostgres.refreshCustomerList();
    }

    _searchResults = _peopleList;
    setState(() {});
  }

  void findPeople(query){
    var result = _peopleList.where(
            (p) => p.firstName.toLowerCase().contains(query) ||
                   p.lastName.toLowerCase().contains(query) ||
                   p.phone.toLowerCase().contains(query)
    ).toList();
    _searchResults = result;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: UIConstants.GREY_MEDIUM,
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
          bottom: searchField(context, findPeople),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          '${person.firstName} ${person.lastName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_,__){
                    return const DividerCustom();
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
