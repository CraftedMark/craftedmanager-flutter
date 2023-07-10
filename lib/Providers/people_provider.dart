import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../services/PostgreApi.dart';
import '../services/one_signal_api.dart';

class PeopleProvider with ChangeNotifier {
  List<People> _people = [];
  People? _activePerson;

  List<People> get people => _people;

  People? get activePerson => _activePerson;

  void setActivePerson(People person) {
    _activePerson = person;
    notifyListeners();
  }

  Future<void> fetchPeople() async {
    _people = await PeoplePostgres.refreshCustomerList();
    notifyListeners();
  }

  Future<void> fetchPersonByCustomerId(String customerId) async {
    if (AppConfig.ENABLE_WOOSIGNAL) {
      // newUser = await WooSignalService.getCustomerById(customerId) ?? newUser   ;
    } else {
      _activePerson = await PeoplePostgres.fetchCustomer(customerId);
    }
    notifyListeners();
  }

  Future<void> addPerson(People person) async {
    String id = await PeoplePostgres.createCustomer(person);
    person = person.copyWith(id: id);
    _people.add(person);
    notifyListeners();
    final nameSurname = '${person.firstName} ${person.lastName}';
    OneSignalAPI.sendNotification('Added new customer: $nameSurname');
  }

  Future<void> updatePerson(People person) async {
    People? updatedPerson = await PeoplePostgres.updateCustomer(person);
    if (updatedPerson != null) {
      int index = _people.indexWhere((p) => p.id == updatedPerson.id);
      if (index != -1) {
        _people[index] = updatedPerson;
      }
    }
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    await PeoplePostgres.deleteCustomer(id);
    _people.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<Map<String, dynamic>?>getUserAddressById(String id) async {
    return PostgreCustomersAPI.getAddressForUserById(id);
  }
}
