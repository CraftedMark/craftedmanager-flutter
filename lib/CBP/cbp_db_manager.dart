import 'dart:async';

import 'package:postgres/postgres.dart';

class CustomerBasedPricingDbManager {
  static final CustomerBasedPricingDbManager instance =
      CustomerBasedPricingDbManager._privateConstructor();

  CustomerBasedPricingDbManager._privateConstructor();

  static Future<PostgreSQLConnection> openConnection() async {
    final connection = PostgreSQLConnection(
      'web.craftedsolutions.co',
      5432,
      'craftedmanager_db',
      username: 'craftedmanager_dbuser',
      password: '!!Laganga1983',
    );
    await connection.open();
    return connection;
  }

  static Future<void> closeConnection(PostgreSQLConnection connection) async {
    await connection.close();
  }

  Future<void> updateCustomerBasedPricing(String customerId, bool value) async {
    final connection = await openConnection();
    final query =
        'UPDATE people SET customerbasedpricing = @value WHERE id = @customerId';
    await connection.execute(
      query,
      substitutionValues: {
        'customerId': customerId,
        'value': value,
      },
    );
    await closeConnection(connection);
  }

  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final connection = await openConnection();
    final result = await connection.query('SELECT * FROM $tableName');
    await closeConnection(connection);
    return result.map((row) => row.toTableColumnMap()).toList();
  }

  Future<void> add(String tableName, Map<String, dynamic> data) async {
    final connection = await openConnection();
    final columns = data.keys.join(', ');
    final values = data.keys.map((key) => '@$key').join(', ');
    await connection.execute(
      'INSERT INTO $tableName ($columns) VALUES ($values)',
      substitutionValues: data,
    );
    await closeConnection(connection);
  }

  Future<void> update(
      String tableName, String id, Map<String, dynamic> updatedData) async {
    final connection = await openConnection();
    final updates = updatedData.keys.map((key) => '$key = @$key').join(', ');
    await connection.execute(
      'UPDATE $tableName SET $updates WHERE id = @id',
      substitutionValues: {'id': id, ...updatedData},
    );
    await closeConnection(connection);
  }

  Future<void> delete(String tableName, String id) async {
    final connection = await openConnection();
    await connection.execute(
      'DELETE FROM $tableName WHERE id = @id',
      substitutionValues: {'id': id},
    );
    await closeConnection(connection);
  }

  Future<List<Map<String, dynamic>>> search(String tableName,
      String searchQuery, Map<String, dynamic> substitutionValues) async {
    final connection = await openConnection();
    final result = await connection.query(
      'SELECT * FROM $tableName WHERE $searchQuery',
      substitutionValues: substitutionValues,
    );
    await closeConnection(connection);
    return result.map((row) => row.toTableColumnMap()).toList();
  }

  Future<double?> getCustomProductPrice(
      int productId, String customerId) async {
    double? customPrice;
    int? pricingListId = await CustomerBasedPricingDbManager.instance
        .getPricingListByCustomerId(customerId);

    if (pricingListId != null) {
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
    required String customerId,
    required double price,
  }) async {
    String? pricingListId = await getPricingListIdByCustomerId(customerId);

    if (pricingListId == null) {
      pricingListId = (await addPricingList(
        customerId: customerId,
        name: 'Default Pricing List',
        description: 'No Custom Pricing',
      )) as String?;

      if (pricingListId != null && pricingListId != -1) {
        await updateCustomerPricingListId(customerId, pricingListId as int?);
      } else {
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

  Future<String?> getPricingListIdByCustomerId(String customerId) async {
    final connection = await openConnection();
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
    await closeConnection(connection);
    return result.isNotEmpty ? result.first[0] : null;
  }

  Future<int?> getPricingListByCustomerId(String customerId) async {
    final connection = await CustomerBasedPricingDbManager.openConnection();
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
    await CustomerBasedPricingDbManager.closeConnection(connection);
    return result.isNotEmpty ? result.first[0] : null;
  }

  // Future<List<Map<String, dynamic>>> fetchCustomerBasedPricing(
  // int customerId) async {
  // final connection = await openConnection();
  // final PostgreSQLResult result = await connection.query(
  // '''
  // SELECT
  // p.id as product_id,
  // p.name as product_name,
  // p.retailPrice as original_price,
  // cpp.price as custom_price
  // FROM
  // products p
  // LEFT JOIN customer_product_pricing cpp ON p.id = cpp.product_id
  // LEFT JOIN customer_pricing_lists cpl ON cpl.id = cpp.customer_pricing_list_id
  // LEFT JOIN people cust ON cust.assigned_pricing_list_id = cpl.id
  // WHERE
  // cust.id = @customerId
  // ''',
  // substitutionValues: {'customerId': customerId},
  // );
  // final List<Map<String, dynamic>> results = result
  // .map((row) => {
  // 'product_id': row[0],
  // 'product_name': row[1],
  // 'original_price': row[2],
  // 'custom_price': row[3],
  // })
  // .toList();
  // await closeConnection(connection);
  // return results;
  // }

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

  Future<Map<String, dynamic>?> fetchCustomerBasedPricing(
      String customerId, int productId) async {
    try {
      final connection = await openConnection();
      final query =
          'SELECT * FROM customer_product_pricing WHERE customer_id = @customerId AND product_id = @productId';
      final result = await connection.mappedResultsQuery(
        query,
        substitutionValues: {
          'customerId': customerId,
          'productId': productId,
        },
      );
      await closeConnection(connection);

      final customPriceRow = await CustomerBasedPricingDbManager.instance
          .fetchCustomerBasedPricing(customerId, productId);

      num? customPrice;
      if (customPriceRow != null &&
          customPriceRow['customer_product_pricing']['price'] != null) {
        customPrice = num.tryParse(
            customPriceRow['customer_product_pricing']['price'].toString());
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<int?> addPricingList({
    required String customerId,
    required String name,
    required String description,
  }) async {
    final data = {
      'customer_id': customerId,
      'name': name,
      'description': description,
    };
    final result = await addReturning('customer_pricing_lists', data, 'id');
    int? pricingListId = result['customer_pricing_lists']['id'] as int?;

    if (pricingListId == null) {
      return null;
    } else {
      await updateCustomerPricingListId(customerId, pricingListId);
    }
    return pricingListId;
  }

  Future<Map<String, dynamic>> addReturning(String tableName,
      Map<String, dynamic> data, String returningColumns) async {
    final connection = await openConnection();
    final columns = data.keys.join(', ');
    final values = data.keys.map((key) => '@$key').join(', ');
    final query =
        'INSERT INTO $tableName ($columns) VALUES ($values) RETURNING $returningColumns';
    final result = await connection.query(query, substitutionValues: data);
    await closeConnection(connection);

    return result.first.toTableColumnMap();
  }

  Future<void> addCustomerProductPricing(Map<String, dynamic> data) async {
    return add('customer_product_pricing', data);
  }

  Future<void> updateCustomerPricingListId(
      String customerId, int? pricingListId) async {
    if (pricingListId == null) {
      return;
    }
    final connection = await openConnection();
    final query =
        'UPDATE people SET assigned_pricing_list_id = @pricingListId WHERE id = @customerId';
    await connection.execute(
      query,
      substitutionValues: {
        'customerId': customerId,
        'pricingListId': pricingListId,
      },
    );
    await closeConnection(connection);
  }
}
