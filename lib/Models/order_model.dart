import 'package:uuid/uuid.dart';

import 'ordered_item_model.dart';

var uuid = Uuid();
String newOrderId = uuid.v4();

class Order {
  String id;
  int? wooSignalId;
  String customerId;
  DateTime orderDate;
  String shippingAddress;
  String billingAddress;
  double totalAmount;
  bool isPaid;
  int paymentId;
  double paidAmount;
  String orderStatus;
  String productName;
  String notes;
  bool archived;
  List<OrderedItem> orderedItems;

  Order({
    required this.id,
    this.wooSignalId,
    required this.customerId,
    required this.orderDate,
    required this.shippingAddress,
    required this.billingAddress,
    required this.totalAmount,
    this.paymentId = 0,
    this.isPaid = false,
    this.paidAmount = 0.0,
    required this.orderStatus,
    required this.productName,
    required this.notes,
    required this.archived,
    required this.orderedItems,
  });

  Order copyWith({
    String? id,
    int? wooSignalId,
    String? customerId,
    DateTime? orderDate,
    String? shippingAddress,
    String? billingAddress,
    double? totalAmount,
    int? paymentid,
    bool? ispaid,
    double? paidAmount,
    String? orderStatus,
    String? productName,
    String? notes,
    bool? archived,
    List<OrderedItem>? orderedItems,
  }) {
    return Order(
      id: id ?? this.id,
      wooSignalId: wooSignalId ?? this.wooSignalId,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentId: paymentid ?? this.paymentId,
      isPaid: ispaid ?? this.isPaid,
      paidAmount: paidAmount ?? this.paidAmount,
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
      paymentId: map['id'] ?? 0,
      isPaid: map['is_paid'] == 1,
      paidAmount: double.tryParse(map['paid_amount']?.toString() ?? '0') ?? 0.0,
      totalAmount:
          double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0.0,
      orderStatus: map['order_status'] ?? '',
      productName: map['product_name'] ?? '',
      notes: map['notes'] ?? '',
      archived: map['archived'] == 1,
      orderedItems: parseOrderedItems(map['ordered_items'] ?? []),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      orderDate: DateTime.parse(json['order_date']),
      shippingAddress: json['shipping_address'] ?? '',
      billingAddress: json['billing_address'] ?? '',
      totalAmount: json['total_amount'].toDouble(),
      paymentId: json['payment_id'] ?? 0,
      isPaid: json['is_paid'] == 1,
      orderStatus: json['order_status'] ?? '',
      productName: json['product_name'] ?? '',
      notes: json['notes'] ?? '',
      archived: json['archived'] == 1,
      orderedItems: (json['ordered_items'] as List)
          .map((i) => OrderedItem.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_date': orderDate.toIso8601String(),
      'shipping_address': shippingAddress,
      'billing_address': billingAddress,
      'total_amount': totalAmount,
      'payment_id': paymentId,
      'is_paid': isPaid ? 1 : 0,
      'order_status': orderStatus,
      'product_name': productName,
      'notes': notes,
      'archived': archived ? 1 : 0,
      'ordered_items': orderedItems.map((i) => i.toJson()).toList()
    };
  }

  // factory Order.fromOrderWS(wsOrder.Order order) {
  //   final orderedItems = List.generate(order.lineItems!.length, (index) {
  //     final currentItem = order.lineItems![index];
  //     var item = OrderedItem(
  //         productId: currentItem.id ?? -1,
  //         orderId: '0',
  //         name: currentItem.name ?? "",
  //         productName: currentItem.name ?? "",
  //         quantity: currentItem.quantity ?? 0,
  //         status: order.status ?? "pending", //TODO:CHANGE,
  //         discount: 0,
  //         price: double.parse(currentItem.price ?? '0'),
  //         packaging: '',
  //         itemSource: '',
  //         productDescription: '',
  //         productRetailPrice: double.parse(currentItem.price ?? '0'));
  //     return item;
  //   });
  //
  //   return Order(
  //     customerId: order.customerId.toString(),
  //     archived: false,
  //     id: '0',
  //     wooSignalId: order.id,
  //     notes: order.customerNote ?? '',
  //     orderDate: DateTime.parse(order.dateCreated ?? ''),
  //     orderStatus: order.status!,
  //     billingAddress: order.billing!.address1!,
  //     productName: "Test fetch product from WooCommerce order_model.dart",
  //     totalAmount: double.parse(order.total!),
  //     shippingAddress: order.shipping!.address1!,
  //     orderedItems: orderedItems,
  //   );
  // }

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
