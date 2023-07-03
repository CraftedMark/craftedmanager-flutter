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
  double qty;
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
    required this.qty,
    required this.bulkMeasurement,
    required this.manufacturer,
  });

  Ingredient copyWith({
    int? id,
    String? brand,
    String? name,
    String? category,
    double? bulkPricing,
    double? perGramCost,
    double? pkgWeight,
    String? qtyInStock,
    String? reorderLevel,
    String? reorderQty,
    String? suppliers,
    String? productDescription,
    String? weight,
    double? qty,
    String? bulkMeasurement,
    String? manufacturer,
  }) {
    return Ingredient(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      category: category ?? this.category,
      bulkPricing: bulkPricing ?? this.bulkPricing,
      perGramCost: perGramCost ?? this.perGramCost,
      pkgWeight: pkgWeight ?? this.pkgWeight,
      qtyInStock: qtyInStock ?? this.qtyInStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      reorderQty: reorderQty ?? this.reorderQty,
      suppliers: suppliers ?? this.suppliers,
      productDescription: productDescription ?? this.productDescription,
      weight: weight ?? this.weight,
      qty: qty ?? this.qty,
      bulkMeasurement: bulkMeasurement ?? this.bulkMeasurement,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

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
      qty: 0,
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
      qty: map['qty'] == null ? 0 : double.parse(map['qty'].toString()),
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
      'pkg_weight': pkgWeight,
      'qty_in_stock': qtyInStock,
      'reorder_level': reorderLevel,
      'reorder_qty': reorderQty,
      'suppliers': suppliers,
      'product_description': productDescription,
      'weight': weight,
      'qty': qty,
      'bulk_measurement': bulkMeasurement,
      'manufacture': manufacturer,
    };
  }
}
