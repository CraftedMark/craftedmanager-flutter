import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/services/OneSignal/notification_type.dart';
import 'package:flutter/foundation.dart';

import '../WooCommerce/woosignal-service.dart';
import '../config.dart';
import '../services/PostgreApi.dart';
import '../services/OneSignal/one_signal_api.dart';

class PeopleProvider with ChangeNotifier {
  List<People> _peoples = [];
  List<People> get peoples => _peoples;

  List<People> _filteredPeoples = [];
  List<People> get filteredPeoples => _filteredPeoples;

  // People? _activePerson;

  // People? get activePerson => _activePerson;

  // void setActivePerson(People person) {
  //   _activePerson = person;
  //   notifyListeners();
  // }

  Future<void> fetchPeoples() async {
    if (AppConfig.ENABLE_WOOSIGNAL) {
      _peoples = await WooSignalService.getCustomers();
    } else {
      _peoples = await PeoplePostgres.refreshCustomerList();
    }
    notifyListeners();
  }

  void filterPeoples(String query) {
    _filteredPeoples = _peoples
        .where((contact) =>
            contact.firstName.toLowerCase().contains(query.toLowerCase()) ||
            contact.lastName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  // Future<void> fetchPersonByCustomerId(String customerId) async {
  //   if (AppConfig.ENABLE_WOOSIGNAL) {
  //     // newUser = await WooSignalService.getCustomerById(customerId) ?? newUser   ;
  //   } else {
  //     _activePerson = await PeoplePostgres.fetchCustomer(customerId);
  //   }
  //   notifyListeners();
  // }

  Future<void> createPerson(People person) async {
    String id = await PeoplePostgres.createCustomer(person);
    person = person.copyWith(id: id);
    _peoples.add(person);
    notifyListeners();

    final fullName = '${person.firstName} ${person.lastName}';
    _sendPushNotification('Added new customer: $fullName');
  }

  Future<void> updatePerson(People person) async {
    People? updatedPerson = await PeoplePostgres.updateCustomer(person);
    if (updatedPerson != null) {
      int index = _peoples.indexWhere((p) => p.id == updatedPerson.id);
      if (index != -1) {
        _peoples[index] = updatedPerson;
      }
    }

    final fullName = '${person.firstName} ${person.lastName}';
    _sendPushNotification('Info about $fullName has been updated');
  }

  Future<void> deletePerson(People person) async {
    await PeoplePostgres.deleteCustomer(person.id);
    _peoples.removeWhere((p) => p.id == person.id);
    notifyListeners();

    final fullName = '${person.firstName} ${person.lastName}';
    _sendPushNotification('Customer $fullName has been deleted');

  }

  Future<Map<String, dynamic>?> getUserAddressById(String id) async {
    return PostgreCustomersAPI.getAddressForUserById(id);
  }
}

Future<void> _sendPushNotification(String payload) async {
  await OneSignalAPI.sendNotification(message: payload, type: CustomersEvent());
}

