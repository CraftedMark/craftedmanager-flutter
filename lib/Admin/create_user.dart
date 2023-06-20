import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:flutter/material.dart';

class UserCreate extends StatefulWidget {
  const UserCreate({super.key});

  @override
  _UserCreateState createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  List<People> peopleList = [];
  List<People> filteredPeopleList = [];
  TextEditingController searchController = TextEditingController();
  People? selectedPerson;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPeopleList();
  }

  void fetchPeopleList() async {
    peopleList = await PeoplePostgres.refreshCustomerList();
    setState(() {
      filteredPeopleList = peopleList;
    });
  }

  void filterPeopleList(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        filteredPeopleList = peopleList;
      } else {
        filteredPeopleList = peopleList
            .where((person) =>
                person.firstName
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()) ||
                person.lastName
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()))
            .toList();
      }
    });
  }

  void createUserAccount() async {
    if (selectedPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a person first.')),
      );
      return;
    }
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Both username and password fields are required.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User account created successfully.')),
    );

    usernameController.clear();
    passwordController.clear();
    setState(() {
      selectedPerson = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Create User Account'),
        ),
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterPeopleList,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by first name or last name',
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ListView.builder(
                        itemCount: filteredPeopleList.length,
                        itemBuilder: (context, index) {
                          People person = filteredPeopleList[index];
                          return ListTile(
                            title:
                                Text('${person.firstName} ${person.lastName}'),
                            onTap: () {
                              setState(() {
                                selectedPerson = person;
                              });
                            },
                            selected: selectedPerson == person,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPerson != null) ...[
                        Text(
                          'Selected person: ${selectedPerson!.firstName} ${selectedPerson!.lastName}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter a username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter a password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: createUserAccount,
                          child: const Text('Create User Account'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
