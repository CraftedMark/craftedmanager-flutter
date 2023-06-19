import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';

class PeopleProvider {
  Future<List<People>> fetchPeopleByCustomerId(int customerId) async {
    People? fetchedPerson = await PeoplePostgres.fetchCustomer(
        customerId); // This function should return a Future<People>

    List<People> fetchedPeople = [];
    if (fetchedPerson != null) {
      fetchedPeople.add(fetchedPerson);
    }

    return fetchedPeople;
  }
}
