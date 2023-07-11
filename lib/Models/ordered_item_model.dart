import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/config.dart';

class OrderedItem {
  String orderId;
  Product product;
  String productName;
  int productId;
  String name;
  int quantity;
  double price;
  double discount;
  String productDescription;
  double productRetailPrice;
  String status;
  String itemSource;
  String packaging;
  String flavor;
  double dose;

  OrderedItem({
    required this.orderId,
    required this.product,
    required this.productName,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.productDescription,
    required this.productRetailPrice,
    required this.status,
    required this.itemSource,
    required this.packaging,
    this.flavor = '',
    this.dose = 0.0,
  });

  OrderedItem copyWith({
    String? orderId,
    Product? product,
    String? productName,
    int? productId,
    String? name,
    int? quantity,
    double? price,
    double? discount,
    String? productDescription,
    double? productRetailPrice,
    String? status,
    String? itemSource,
    String? packaging,
    String? flavor,
    double? dose,
  }) {
    return OrderedItem(
      orderId: orderId ?? this.orderId,
      product: product ?? this.product,
      productName: productName ?? this.productName,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      productDescription: productDescription ?? this.productDescription,
      productRetailPrice: productRetailPrice ?? this.productRetailPrice,
      status: status ?? this.status,
      itemSource: itemSource ?? this.itemSource,
      packaging: packaging ?? this.packaging,
      flavor: flavor ?? this.flavor,
      dose: dose ?? this.dose,
    );
  }

  factory OrderedItem.fromMap(Map<String, dynamic> map) {
    num parseNum(dynamic value) {
      if (value is num) {
        return value;
      } else {
        try {
          return num.parse(value);
        } catch (_) {
          return 0;
        }
      }
    }

    return OrderedItem(
      orderId: map['order_id'] as String,
      productId: map['product_id'] ?? 0,
      quantity: map['quantity'] ?? 0,
      price: parseNum(map['price']).toDouble(),
      discount: parseNum(map['discount']).toDouble(),
      productDescription: map['description'] as String? ?? '',
      productName: map['product_name'] as String? ?? 'Unknown',
      status: map['status'] ?? AppConfig.ORDERED_ITEM_STATUSES.first,
      itemSource: map['item_source'] ?? "Unknown",
      flavor: map['flavor'] ?? "Unknown",
      dose: double.parse(map['dose'].toString() ?? '0.0'),
      packaging: map['packaging'] ?? "Unknown",
      name: map['product_name'] as String? ?? 'Unknown',
      productRetailPrice: 0,
      product: Product.fromMap(map),
    );
  }

  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    return OrderedItem(
      orderId: json['order_id'] as String,
      product: Product.fromJson(json['product']),
      productName: json['product_name'] as String,
      productId: json['product_id'] ?? 0,
      name: json['name'] as String,
      quantity: json['quantity'] ?? 0,
      price: json['price'].toDouble(),
      discount: json['discount'].toDouble(),
      productDescription: json['description'] as String,
      productRetailPrice: json['retail_price'].toDouble(),
      status: json['status'] as String,
      itemSource: json['item_source'] as String,
      packaging: json['packaging'] as String,
      flavor: json['flavor'] as String,
      dose: json['dose'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product': product.toJson(),
      'product_name': productName,
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'description': productDescription,
      'retail_price': productRetailPrice,
      'status': status,
      'item_source': itemSource,
      'packaging': packaging,
      'flavor': flavor,
      'dose': dose,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'product': product.toMap(),
      'product_name': productName,
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'description': productDescription,
      'retail_price': productRetailPrice,
      'status': status,
      'item_source': itemSource,
      'packaging': packaging,
      'flavor': flavor,
      'dose': dose,
    };
  }

  Map<String, dynamic> toWSOrderedItemMap() {
    return {
      "name": name,
      "product_id": productId.toString(),
      "variation_id": 0,
      "quantity": quantity,
      "subtotal": (productRetailPrice * quantity).toString(),
      "total": (productRetailPrice * quantity).toString(),
    };
  }
}
