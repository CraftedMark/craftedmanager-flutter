class Ingredient {
  int id;
  String brand;
  String name;
  String category;
  double bulkPricing;
  double perGramCost;
  double pkgWeight;
  String qtyInStock;
  String reorderLevel;
  String reorderQty;
  String suppliers;
  String productDescription;
  String weight;
  String bulkMeasurement;
  String manufacturer;

  Ingredient({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.bulkPricing,
    required this.perGramCost,
    required this.pkgWeight,
    required this.qtyInStock,
    required this.reorderLevel,
    required this.reorderQty,
    required this.suppliers,
    required this.productDescription,
    required this.weight,
    required this.bulkMeasurement,
    required this.manufacturer,
  });

  static Ingredient empty() {
    return Ingredient(
      id: -1,
      brand: '',
      name: '',
      category: '',
      bulkPricing: 0,
      perGramCost: 0,
      pkgWeight: 0,
      qtyInStock: '',
      reorderLevel: '',
      reorderQty: '',
      suppliers: '',
      productDescription: '',
      weight: '',
      bulkMeasurement: '',
      manufacturer: '',
    );
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: int.tryParse(map['id'].toString()) ?? -1,
      brand: map['brand']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      bulkPricing: map['bulk_pricing'] == null
          ? 0
          : double.parse(map['bulk_pricing'].toString()),
      perGramCost: map['per_gram_cost'] == null
          ? 0
          : double.parse(map['per_gram_cost'].toString()),
      pkgWeight: map['pkg_weight'] == null
          ? 0
          : double.parse(map['pkg_weight'].toString()),
      qtyInStock: map['qty_in_stock']?.toString() ?? '',
      reorderLevel: map['reorder_level']?.toString() ?? '',
      reorderQty: map['reorder_qty']?.toString() ?? '',
      suppliers: map['suppliers']?.toString() ?? '',
      productDescription: map['product_description']?.toString() ?? '',
      weight: map['weight']?.toString() ?? '',
      bulkMeasurement: map['bulk_measurement']?.toString() ?? '',
      manufacturer: map['manufacturer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'category': category,
      'bulk_pricing': bulkPricing,
      'per_gram_cost': perGramCost,
      'pkg_wieght': pkgWeight,
      'qty_in_stock': qtyInStock,
      'reorder_level': reorderLevel,
      'reorder_qty': reorderQty,
      'suppliers': suppliers,
      'product_discription': productDescription,
      'wieght': weight,
      'bulk_measurement': bulkMeasurement,
      'manufactor': manufacturer,
    };
  }
}
