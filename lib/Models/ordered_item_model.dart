class OrderedItem {
  int id;
  int orderId;
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
  });

  OrderedItem copyWith({
    int? id,
    int? orderId,
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
      id: map['ordered_item_id'] as int,
      orderId: map['order_id'] as int,
      productName: map['product_name'] as String? ?? 'Unknown',
      productId: map['product_id'] as int,
      name: map['name'] as String? ?? 'Unknown',
      quantity: map['quantity'] as int,
      price: parseNum(map['price']).toDouble(),
      discount: parseNum(map['discount']).toDouble(),
      productDescription: map['description'] as String? ?? '',
      productRetailPrice: parseNum(map['retail_price']).toDouble(),
      status: map['status'] ?? "Unknown",
      itemSource: map['item_source'] ?? "Unknown",
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
    };
  }
  Map<String, dynamic> mapForUpdateOrder(){
    return {
      "name":name,
      "product_id":productId.toString(),
      "variation_id":0,
      "quantity":quantity,
      "subtotal":(productRetailPrice*quantity).toString(),
      "total":(productRetailPrice*quantity).toString(),
    };
  }
}
