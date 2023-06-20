import 'dart:async';

import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:postgres/postgres.dart';

class CustomerBasedPricingDbManager {
  static final CustomerBasedPricingDbManager instance =
      CustomerBasedPricingDbManager._privateConstructor();

  CustomerBasedPricingDbManager._privateConstructor();

  // CRUD Methods

  Future<void> updateCustomerBasedPricing(int customerId, bool value) async {
    final connection = PostgreSQLConnectionManager.connection;
    const query =
        'UPDATE people SET customerbasedpricing = @value WHERE id = @customerId';
    await connection.execute(
      query,
      substitutionValues: {
        'customerId': customerId,
        'value': value,
      },
    );
  }

  // Get all records from the specified table
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query('SELECT * FROM $tableName');
    return result.map((row) => row.toTableColumnMap()).toList();
  }

  // Add a record to the specified table
  Future<void> add(String tableName, Map<String, dynamic> data) async {
    final connection = PostgreSQLConnectionManager.connection;
    final columns = data.keys.join(', ');
    final values = data.keys.map((key) => '@${key}').join(', ');
    await connection.execute(
      'INSERT INTO $tableName ($columns) VALUES ($values)',
      substitutionValues: data,
    );
  }

  // Update a record in the specified table with the provided updated data
  Future<void> update(
      String tableName, int id, Map<String, dynamic> updatedData) async {
    final connection = PostgreSQLConnectionManager.connection;
    final updates = updatedData.keys.map((key) => '$key = @${key}').join(', ');
    await connection.execute(
      'UPDATE $tableName SET $updates WHERE id = @id',
      substitutionValues: {'id': id, ...updatedData},
    );
  }

  // Delete a record from the specified table with the provided id
  Future<void> delete(String tableName, int id) async {
    final connection = PostgreSQLConnectionManager.connection;
    await connection.execute(
      'DELETE FROM $tableName WHERE id = @id',
      substitutionValues: {'id': id},
    );
  }

  // Search records in the specified table using search query and substitution values
  Future<List<Map<String, dynamic>>> search(String tableName,
      String searchQuery, Map<String, dynamic> substitutionValues) async {
    final connection = PostgreSQLConnectionManager.connection;
    final result = await connection.query(
      'SELECT * FROM $tableName WHERE $searchQuery',
      substitutionValues: substitutionValues,
    );
    return result.map((row) => row.toTableColumnMap()).toList();
  }

  Future<double?> getCustomProductPrice(int productId, int customerId) async {
    double? customPrice;
    // Fetch the customer's assigned pricing list id
    int? pricingListId = await CustomerBasedPricingDbManager.instance
        .getPricingListByCustomerId(customerId);

    if (pricingListId != null) {
      // Fetch the custom pricing for the product based on the pricing list id
      Map<String, dynamic>? pricingData = await CustomerBasedPricingDbManager
          .instance
          .getCustomerProductPricing(productId, pricingListId);

      if (pricingData != null) {
        customPrice = pricingData['price'];
      }
    }

    return customPrice;
  }

  Future<void> addOrUpdateCustomerProductPricing({
    required int productId,
    required int customerId,
    required double price,
  }) async {
    print(
        'Adding or updating customer product pricing for product: $productId, customer: $customerId, price: $price');
    int? pricingListId = await getPricingListIdByCustomerId(customerId);

    if (pricingListId == null) {
      pricingListId = await addPricingList(
        customerId: customerId,
        name: 'Default Pricing List', // You can provide a default name here
        description:
            'No Custom Pricing', // You can provide a default description here
      );
      if (pricingListId != null && pricingListId != -1) {
        await updateCustomerPricingListId(customerId, pricingListId);
      } else {
        print('Failed to create a new pricing list for customer: $customerId');
        return;
      }
    }

    var result = await search(
      'customer_product_pricing',
      'product_id = @productId AND customer_pricing_list_id = @pricingListId',
      {
        'productId': productId,
        'pricingListId': pricingListId,
      },
    );

    if (result.isNotEmpty) {
      await update(
        'customer_product_pricing',
        result[0]['id'],
        {'price': price},
      );
    } else {
      await addCustomerProductPricing(
        {
          'product_id': productId,
          'customer_pricing_list_id': pricingListId,
          'price': price,
        },
      );
    }
  }

  // Get pricing list id by customer id
  Future<int?> getPricingListIdByCustomerId(int customerId) async {
    final connection = PostgreSQLConnectionManager.connection;
    final PostgreSQLResult result = await connection.query(
      '''
    SELECT
      id
    FROM
      customer_pricing_lists
    WHERE
      customer_id = @customerId
    ''',
      substitutionValues: {'customerId': customerId},
    );
    return result.isNotEmpty ? result.first[0] : null;
  }

  // Get pricing list by customer id
  Future<int?> getPricingListByCustomerId(int customerId) async {
    final connection = PostgreSQLConnectionManager.connection;
    final PostgreSQLResult result = await connection.query(
      '''
    SELECT
      assigned_pricing_list_id
    FROM
      people
    WHERE
      id = @customerId
    ''',
      substitutionValues: {'customerId': customerId},
    );
    return result.isNotEmpty ? result.first[0] : null;
  }

  // Future<List<Map<String, dynamic>>> fetchCustomerBasedPricing(
  //     int customerId) async {
  //   final connection = await openConnection();
  //   final PostgreSQLResult result = await connection.query(
  //     '''
  // SELECT
  //   p.id as product_id,
  //   p.name as product_name,
  //   p.retailPrice as original_price,
  //   cpp.price as custom_price
  // FROM
  //   products p
  // LEFT JOIN customer_product_pricing cpp ON p.id = cpp.product_id
  // LEFT JOIN customer_pricing_lists cpl ON cpl.id = cpp.customer_pricing_list_id
  // LEFT JOIN people cust ON cust.assigned_pricing_list_id = cpl.id
  // WHERE
  //   cust.id = @customerId
  // ''',
  //     substitutionValues: {'customerId': customerId},
  //   );
  //   final List<Map<String, dynamic>> results = result
  //       .map((row) => {
  //             'product_id': row[0],
  //             'product_name': row[1],
  //             'original_price': row[2],
  //             'custom_price': row[3],
  //           })
  //       .toList();
  //   await closeConnection(connection);
  //   return results;
  // }

  // Get customer product pricing by product id and pricing list id
  Future<Map<String, dynamic>?> getCustomerProductPricing(
      int productId, int pricingListId) async {
    final pricingData = await search(
        'customer_product_pricing',
        'product_id = @productId AND customer_pricing_list_id = @pricingListId',
        {
          'productId': productId,
          'pricingListId': pricingListId,
        });
    return pricingData.isNotEmpty ? pricingData[0] : null;
  }

  // fetchCustomerBasedPricing
  Future<Map<String, dynamic>?> fetchCustomerBasedPricing(
      int customerId, int productId) async {
    try {
      final connection = PostgreSQLConnectionManager.connection;
      const query =
          'SELECT * FROM customer_product_pricing WHERE customer_id = @customerId AND product_id = @productId';
      final result = await connection.mappedResultsQuery(
        query,
        substitutionValues: {
          'customerId': customerId,
          'productId': productId,
        },
      );
      // Check if a custom price is found and return the entire row
      final customPriceRow = await CustomerBasedPricingDbManager.instance
          .fetchCustomerBasedPricing(customerId, productId);
      print("Custom price row: $customPriceRow");

      num? customPrice;
      if (customPriceRow != null &&
          customPriceRow['customer_product_pricing']['price'] != null) {
        customPrice = num.tryParse(
            customPriceRow['customer_product_pricing']['price'].toString());
      }
      print("Custom price: $customPrice");
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<int?> addPricingList({
    required int customerId,
    required String name,
    required String description,
  }) async {
    Map<String, dynamic> data = {
      'customer_id': customerId,
      'name': name,
      'description': description,
    };
    print("Adding pricing list with data: $data");
    var result = await addReturning('customer_pricing_lists', data, 'id');
    int? pricingListId = result['customer_pricing_lists']['id'] as int?;

    if (pricingListId == null) {
      print("Error: Failed to add pricing list. Result: $result");
    } else {
      print("Successfully added pricing list with id: $pricingListId");
      // Update the customer's assigned_pricing_list_id with the new pricing list id
      await updateCustomerPricingListId(customerId, pricingListId);
    }

    return pricingListId;
  }

  Future<Map<String, dynamic>> addReturning(String tableName,
      Map<String, dynamic> data, String returningColumns) async {
    try {
      final connection = PostgreSQLConnectionManager.connection;
      final columns = data.keys.join(', ');
      final values = data.keys.map((key) => '@$key').join(', ');
      final query =
          'INSERT INTO $tableName ($columns) VALUES ($values) RETURNING $returningColumns';
      final result = await connection.query(query, substitutionValues: data);
      return result.first.toTableColumnMap();
    } catch (e) {
      print("Error in addReturning function: $e");
      return {};
    }
  }

  // Add a customer-product pricing
  Future<void> addCustomerProductPricing(Map<String, dynamic> data) async {
    return add('customer_product_pricing', data);
  }

  Future<void> updateCustomerPricingListId(
      int customerId, int? pricingListId) async {
    if (pricingListId == null) {
      print("Error: pricingListId is null. Skipping update.");
      return;
    }
    final connection = PostgreSQLConnectionManager.connection;
    const query =
        'UPDATE people SET assigned_pricing_list_id = @pricingListId WHERE id = @customerId';
    await connection.execute(
      query,
      substitutionValues: {
        'customerId': customerId,
        'pricingListId': pricingListId,
      },
    );
  }
}
