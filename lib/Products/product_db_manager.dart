import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';

class ProductPostgres {
  ProductPostgres._();

  static Future<Product> addAssemblyProduct(Product assemblyProduct) async {
    print('Adding assembly product: ${assemblyProduct.name}');
    final connection = PostgreSQLConnectionManager.connection;
    Product createdAssemblyProduct = Product.empty;

    try {
      final result = await connection.query(
        'INSERT INTO products (product_name, category, description) VALUES (@product_name, @category, @description) RETURNING *',
        substitutionValues: {
          'product_name': assemblyProduct.name,
          'category': assemblyProduct.category,
          'description': assemblyProduct.description,
        },
      );

      createdAssemblyProduct = Product.fromMap(result.first.toColumnMap());
      print('Assembly product added successfully');
    } catch (e) {
      print('Error adding assembly product: $e');
    }
    return createdAssemblyProduct;
  }

  // Add is_assembly field to the addProduct function

  static Future<void> addProduct(Product product) async {
    print('Adding product: ${product.name}');
    final connection = PostgreSQLConnectionManager.connection;
    try {
      await connection.execute(
        'INSERT INTO products (product_name, category, sub_category, subcat2, flavor, description, cost_of_good, manufacturing_price, wholesale_price, retail_price, stock_quantity, backordered, supplier, manufacturer_id, manufacturer_name, item_source, quantity_sold, quantity_in_stock, image_url, per_gram_cost, bulk_pricing, weight_in_grams, package_weight_measure, package_weight, type, is_assembly) VALUES (@product_name, @category, @sub_category, @subcat2, @flavor, @description, @cost_of_good, @manufacturing_price, @wholesale_price, @retail_price, @stock_quantity, @backordered, @supplier, @manufacturer_id, @manufacturer_name, @item_source, @quantity_sold, @quantity_in_stock, @image_url, @per_gram_cost, @bulk_pricing, @weight_in_grams, @package_weight_measure, @package_weight, @type, @is_assembly)',
        substitutionValues: {
          'product_name': product.name,
          'category': product.category,
          'sub_category': product.subCategory,
          'subcat2': product.subcat2,
          'flavor': product.flavor,
          'description': product.description,
          'cost_of_good': product.costOfGood,
          'manufacturing_price': product.manufacturingPrice,
          'wholesale_price': product.wholesalePrice,
          'retail_price': product.retailPrice,
          'stock_quantity': product.stockQuantity,
          'backordered': product.backordered,
          'supplier': product.supplier,
          'manufacturer_id': product.manufacturerId,
          'manufacturer_name': product.manufacturerName,
          'item_source': product.itemSource,
          'quantity_sold': product.quantitySold,
          'quantity_in_stock': product.quantityInStock,
          'image_url': product.imageUrl,
          'per_gram_cost': product.perGramCost,
          'bulk_pricing': product.bulkPricing,
          'weight_in_grams': product.weightInGrams,
          'package_weight_measure': product.packageWeightMeasure,
          'package_weight': product.packageWeight,
          'type': product.type,
          'is_assembly': product.isAssemblyItem,
          'packaging': product.packaging,
          'flavor': product.flavor,
          'dose': product.dose,
        },
      );
      print('Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  // Generate a random UUID
  static String _generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('+', '-').replaceAll('/', '_');
  }

  static Future<List<Product>> getAllProductsExceptIngredients() async {
    final connection = PostgreSQLConnectionManager.connection;
    final results = await connection.query(
      "SELECT * FROM products WHERE type != 'Ingredient'",
    );
    return results.map((row) => Product.fromMap(row.toColumnMap())).toList();
  }

  static Future<List<Product>> getAllProducts(String type) async {
    final connection = PostgreSQLConnectionManager.connection;
    final results = await connection.query(
      'SELECT * FROM products WHERE type = @type',
      substitutionValues: {'type': type},
    );
    return results.map((row) => Product.fromMap(row.toColumnMap())).toList();
  }

  // Add is_assembly field to the updateProduct function

  static Future<void> updateProduct(Product product) async {
    final connection = PostgreSQLConnectionManager.connection;
    await connection.execute(
      'UPDATE products SET product_name = @product_name, category = @category, sub_category = @sub_category, subcat2 = @subcat2, flavor = @flavor, description = @description, cost_of_good = @cost_of_good, manufacturing_price = @manufacturing_price, wholesale_price = @wholesale_price, retail_price = @retail_price, stock_quantity = @stock_quantity, backordered = @backordered, manufacturer_name = @manufacturer_name, supplier_name = @supplier_name, item_source = @item_source, quantity_sold = @quantity_sold, quantity_in_stock = @quantity_in_stock, image_url = @image_url, per_gram_cost = @per_gram_cost, bulk_pricing = @bulk_pricing, weight_in_grams = @weight_in_grams, package_weight_measure = @package_weight_measure, package_weight = @package_weight,  type = @type, is_assembly = @is_assembly WHERE product_id = @product_id',
      substitutionValues: {
        'product_id': product.id,
        'product_name': product.name,
        'category': product.category,
        'sub_category': product.subCategory,
        'subcat2': product.subcat2,
        'flavor': product.flavor,
        'description': product.description,
        'cost_of_good': product.costOfGood,
        'manufacturing_price': product.manufacturingPrice,
        'wholesale_price': product.wholesalePrice,
        'retail_price': product.retailPrice,
        'stock_quantity': product.stockQuantity,
        'backordered': product.backordered,
        'manufacturer_name': product.manufacturerName,
        'supplier_name': product.supplier,
        'item_source': product.itemSource,
        'quantity_sold': product.quantitySold,
        'quantity_in_stock': product.quantityInStock,
        'image_url': product.imageUrl,
        'per_gram_cost': product.perGramCost,
        'bulk_pricing': product.bulkPricing,
        'weight_in_grams': product.weightInGrams,
        'package_weight_measure': product.packageWeightMeasure,
        'package_weight': product.packageWeight,
        'type': product.type,
        'is_assembly': product.isAssemblyItem,
        'packaging': product.packaging,
        'flavor': product.flavor,
        'dose': product.dose,
      },
    );
  }

  static Future<void> deleteProduct(int id) async {
    final connection = PostgreSQLConnectionManager.connection;
    await connection.execute(
      'DELETE FROM products WHERE id = @id',
      substitutionValues: {
        'id': id,
      },
    );
  }

  static Future<List<Product>> searchProducts(String keyword) async {
    final connection = PostgreSQLConnectionManager.connection;
    final results = await connection.query(
      'SELECT * FROM products WHERE name ILIKE @keyword OR description ILIKE @keyword',
      substitutionValues: {'keyword': '%$keyword%'},
    );
    return results.map((row) => Product.fromMap(row.toColumnMap())).toList();
  }

  static saveProduct(Product newProduct) {}
}
