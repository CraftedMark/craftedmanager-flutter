import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:crafted_manager/Products/product_db_manager.dart';
import 'package:flutter/foundation.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];

  List<Product> get allProducts => _products;

  void addProduct(Product product) async {
    await ProductPostgres.addProduct(product);
    _products.add(product);
    notifyListeners();
  }

  void removeProduct(Product product) async {
    if (product.id != null) {
      await ProductPostgres.deleteProduct(
          product.id!); // Add the null assertion operator (!) here
      _products.remove(product);
      notifyListeners();
    } else {
      // Handle the case when product.id is null
    }
  }

  void updateProduct(Product product) async {
    int index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      await ProductPostgres.updateProduct(product);
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _products = await ProductPostgres.getAllProductsExceptIngredients();
    notifyListeners();
  }

  void fetchProductsByType(String type) async {
    _products = await ProductPostgres.getAllProducts(type);
    notifyListeners();
  }

  Future<int?> getProductId(String productName) async {
    final ctx = PostgreSQLConnectionManager.connection;
    List<Map<String, Map<String, dynamic>>> results =
    await ctx.mappedResultsQuery('''
    SELECT id FROM products WHERE name = @name
  ''', substitutionValues: {'name': productName});

    if (results.isNotEmpty) {
      return results.first['products']?['id'];
    } else {
      return null;
    }
  }

  Product productById(int id) {
    return _products.firstWhere((p) => p.id == id, orElse: () => Product.empty);
  }
}
