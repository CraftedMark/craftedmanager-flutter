import 'package:uuid/uuid.dart';

import 'ordered_item_model.dart';

var uuid = Uuid();
String newOrderId = uuid.v4();

class Order {
  String id;
  String customerId;
  DateTime orderDate;
  String shippingAddress;
  String billingAddress;
  double totalAmount;
  String orderStatus;
  String productName;
  String notes;
  bool archived;
  bool isArchived = false;
  List<OrderedItem> orderedItems;

  Order({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.shippingAddress,
    required this.billingAddress,
    required this.totalAmount,
    required this.orderStatus,
    required this.productName,
    required this.notes,
    required this.archived,
    required this.orderedItems,
  });

  Order copyWith({
    String? id,
    String? customerId,
    DateTime? orderDate,
    String? shippingAddress,
    String? billingAddress,
    double? totalAmount,
    String? orderStatus,
    String? productName,
    String? notes,
    bool? archived,
    List<OrderedItem>? orderedItems,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      productName: productName ?? this.productName,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
      orderedItems: orderedItems ?? this.orderedItems,
    );
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    // Add log
    print('Creating order from map: $map');
    DateTime parseOrderDate(String date) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now();
      }
    }

    List<OrderedItem> parseOrderedItems(List<dynamic> items) {
      return items.map((item) => OrderedItem.fromMap(item)).toList();
    }

    return Order(
      id: map['order_id'].toString(),
      customerId: map['people_id'].toString(),
      orderDate: parseOrderDate(map['order_date'].toString()),
      shippingAddress: map['shipping_address'] ?? '',
      billingAddress: map['billing_address'] ?? '',
      totalAmount:
          double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0.0,
      orderStatus: map['order_status'] ?? '',
      productName: map['product_name'] ?? '',
      notes: map['notes'] ?? '',
      archived: map['archived'] == 1,
      orderedItems: parseOrderedItems(map['ordered_items'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> orderedItemsToMap() {
      return orderedItems.map((item) => item.toMap()).toList();
    }

    return {
      'order_id': id,
      'people_id': customerId,
      'order_date': orderDate.toIso8601String(),
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'total_amount': totalAmount,
      'order_status': orderStatus,
      'product_name': productName,
      'notes': notes,
      'ordered_items': orderedItemsToMap(),
      'archived': archived
          ? 1
          : 0, // Assuming your backend expects a 1 for true and 0 for false.
    };
  }
}
