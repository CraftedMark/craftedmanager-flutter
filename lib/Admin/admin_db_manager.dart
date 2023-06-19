import 'package:crafted_manager/postgres.dart';

class AdminDbManager {
  // This function creates a new user in the 'users' table.
  static Future<void> createUser(
      int personId, String username, String password, String userRole) async {
    await insertData('users', {
      'person_id': personId,
      'username': username,
      'password': password,
      'user_role': userRole,
    });
  }

  // Read all users from the 'users' table.
  static Future<List<Map<String, dynamic>>> getUsers() async {
    return fetchData('users');
  }

  // Update a user in the 'users' table by id with updatedData.
  static Future<void> updateUser(
      int id, Map<String, dynamic> updatedData) async {
    await updateData('users', id, updatedData);
  }

  // Delete a user from the 'users' table by id.
  static Future<void> deleteUser(int id) async {
    await deleteData('users', id);
  }
}
