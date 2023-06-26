import 'package:crafted_manager/Models/assembly_item_model.dart';
import 'package:woosignal/models/response/product.dart' as ws;

class Product {
  final int? id;
  final String name;
  final String category;
  final String subCategory;
  final String subcat2;
  final String flavor;
  final String description;
  final double costOfGood;
  final double manufacturingPrice;
  final double wholesalePrice;
  final double retailPrice;
  final int stockQuantity;
  final bool backordered;
  final String supplier;
  final int? manufacturerId;
  final String manufacturerName;
  final String itemSource;
  final int quantitySold;
  final int quantityInStock;
  final String type;
  final List<AssemblyItem> assemblyItems;
  final String imageUrl;
  final String packageWeightMeasure;
  final int packageWeight;
  final int weightInGrams;
  final double? bulkPricing;
  final double perGramCost;
  final bool isAssemblyItem;
  final double? dose;
  final String? packaging;

  Product({
    this.id,
    required this.name,
    this.category = '',
    this.subCategory = '',
    this.subcat2 = '',
    this.flavor = '',
    this.description = '',
    this.costOfGood = 0,
    this.manufacturingPrice = 0,
    this.wholesalePrice = 0,
    required this.retailPrice,
    this.stockQuantity = 0,
    this.backordered = false,
    this.supplier = '',
    this.manufacturerId,
    this.manufacturerName = '',
    this.itemSource = '',
    this.quantitySold = 0,
    this.quantityInStock = 0,
    this.type = '',
    required this.assemblyItems,
    this.imageUrl = '',
    this.packageWeightMeasure = '',
    this.packageWeight = 0,
    this.weightInGrams = 0,
    this.bulkPricing = 0,
    this.perGramCost = 0,
    this.isAssemblyItem = false,
    this.dose = 0.0,
    this.packaging = '',
  });

  static Product empty = Product(
    id: -1,
    name: 'Product not found',
    retailPrice: 0,
    assemblyItems: [],
    imageUrl: '',
  );

  bool get isEmpty => id == -1;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['product_id'] as int?,
      name: map['product_name'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['sub_category'] ?? '',
      subcat2: map['subcat2'] ?? '',
      flavor: map['flavor'] ?? '',
      description: map['description'] ?? '',
      costOfGood:
          map['cost_of_good'] != null ? double.parse(map['cost_of_good']) : 0.0,
      manufacturingPrice: map['manufacturing_price'] != null
          ? double.parse(map['manufacturing_price'])
          : 0.0,
      wholesalePrice: map['wholesale_price'] != null
          ? double.parse(map['wholesale_price'])
          : 0.0,
      retailPrice:
          map['retail_price'] != null ? double.parse(map['retail_price']) : 0.0,
      stockQuantity:
          map['stock_quantity'] != null ? map['stock_quantity'].round() : 0,
      backordered: map['backordered'] ?? false,
      supplier: map['supplier_name'] ?? '',
      manufacturerId:
          map['manufacturer_id'] != null ? map['manufacturer_id'] as int : null,
      manufacturerName: map['manufacturer_name'] ?? '',
      itemSource: map['item_source'] ?? '',
      quantitySold: map['quantity_sold'] ?? 0,
      quantityInStock: map['quantity_in_stock'] ?? 0,
      type: map['type'] ?? 'Product',
      imageUrl: map['image_url'] ?? '',
      packageWeightMeasure: map['package_weight_measure'] ?? '',
      packageWeight: map['package_weight'] ?? 0,
      weightInGrams: map['weight_in_grams'] ?? 0,
      bulkPricing: map['bulk_pricing'] != null
          ? (map['bulk_pricing'] as num).toDouble()
          : 0.0,
      perGramCost: map['per_gram_cost'] != null
          ? (map['per_gram_cost'] as num).toDouble()
          : 0.0,
      dose: map['dose'] != null ? (map['dose'] as num).toDouble() : null,
      packaging: map['packaging'] ?? '',
      isAssemblyItem: map['isAssemblyItem'] ?? false,
      assemblyItems: map['assembly_items'] != null
          ? List<AssemblyItem>.from(
              map['assembly_items'].map((x) => AssemblyItem.fromMap(x)))
          : [],
    );
  }

  factory Product.fromWSProduct(ws.Product product) {
    //TODO: rework
    return Product(
      id: product.id,
      name: product.name?? 'Unknown',
      retailPrice: double.tryParse(product.regularPrice ?? '0' ) ?? 0,
      wholesalePrice: double.tryParse(product.salePrice ?? '0') ?? 0,
      manufacturingPrice: double.parse(product.price ?? '0'),
      assemblyItems: [],
      backordered: false,
      bulkPricing: 0,
      category: product.categories.first.toString(),
      costOfGood: double.parse(product.price ?? "0"),
      weightInGrams: int.tryParse(product.weight.toString()) ?? 0,
      type: '' , //simple, grouped, external and variable
      supplier: 'Supplier',
      subCategory: '',
      subcat2: '',
      stockQuantity: product.stockQuantity ?? 0,
      quantitySold: 0,
      quantityInStock: 0,
      perGramCost: 0,
      packageWeightMeasure: '0',
      packageWeight: 0,
      manufacturerName: '',
      manufacturerId: 0,
      itemSource: '' ,
      isAssemblyItem: false,
      imageUrl: '',
      flavor: '',
      description: product.description??'',
    );
  }

  Map<String, dynamic> toWSMap() {
    return {
      'name': name,
      'description': description,
      'short_description': description,
      'regular_price': retailPrice.toString(),
      'sale_price': wholesalePrice.toString(),
      // 'type': '',
      // 'status': '',
      // 'featured': '',
      // 'catalog_visibility': '',
      // 'sku': '',
      // 'date_on_sale_from'	: '',
      // 'date_on_sale_from_gmt'	: '',
      // 'date_on_sale_to'	: '',
      // 'date_on_sale_to_gmt'	: '',
      // 'virtual': '',
      // 'downloadable'	: '',
      // 'downloads': '',
      // 'download_limit'	: '',
      // 'download_expiry'	: '',
      // 'external_url'	: '',
      // 'button_text': '',
      // 'tax_status'	: '',
      // 'tax_class': '',
      // 'manage_stock'	: '',
      // 'stock_quantity'	: '',
      // 'stock_status'	: '',
      // 'backorders'	: '',
      // 'sold_individually'	: '',
      // 'weight': '',
      // 'dimensions': '',
      // 'shipping_class': '',
      // 'reviews_allowed': '',
      // 'upsell_ids': '',
      // 'cross_sell_ids': '',
      // 'parent_id': '',
      // 'purchase_note': '',
      // 'categories': '',
      // 'tags': '',
      // 'images': '',
      // 'attributes' : '',
      // 'default_attributes': '',
      // 'grouped_products': '',
      // 'menu_order': '',
      // 'meta_data': '',
    };
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'retailPrice': retailPrice,
      'imageUrl': imageUrl,
      'packageWeightMeasure': packageWeightMeasure,
      'packageWeight': packageWeight,
      'weightInGrams': weightInGrams,
      'bulkPricing': bulkPricing,
      'perGramCost': perGramCost,
      'is_assembly': isAssemblyItem
          ? 1
          : 0, // Corrected key and convert boolean to integer
      'dose': dose,
      'packaging': packaging,
      'category': category,
      'subCategory': subCategory,
      'subcat2': subcat2,
      'flavor': flavor,
      'costOfGood': costOfGood,
      'manufacturingPrice': manufacturingPrice,
      'wholesalePrice': wholesalePrice,
      'stockQuantity': stockQuantity,
      'backordered': backordered,
      'supplier': supplier,
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerName,
      'itemSource': itemSource,
      'quantitySold': quantitySold,
      'quantityInStock': quantityInStock,
      'assemblyItems': assemblyItems.map((x) => x.toMap()).toList(),
      'type': type
    };
  }
}
