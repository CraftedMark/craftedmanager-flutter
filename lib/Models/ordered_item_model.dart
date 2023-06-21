class OrderedItem {
  String id;
  String orderId;
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
    required this.id,
    required this.orderId,
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
    String? id,
    String? orderId,
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
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
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
      id: map['ordered_item_id'].toString(),
      orderId: map['order_id'].toString(),
      productName: map['product_name'] as String? ?? 'Unknown',
      productId: int.tryParse(map['product_id'].toString()) ?? 0,
      name: map['name'] as String? ?? 'Unknown',
      quantity: int.tryParse(map['quantity'].toString()) ?? 0,
      price: parseNum(map['price']).toDouble(),
      discount: parseNum(map['discount']).toDouble(),
      productDescription: map['description'] as String? ?? '',
      productRetailPrice: parseNum(map['retail_price']).toDouble(),
      status: map['status'] ?? "Unknown",
      itemSource: map['item_source'] ?? "Unknown",
      packaging: map['packaging'] ?? "Unknown",
      flavor: map['flavor'] ?? "Unknown",
      dose: double.tryParse(map['dose'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ordered_item_id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': name,
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
}
