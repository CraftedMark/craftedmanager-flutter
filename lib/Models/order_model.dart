import 'package:woosignal/models/response/order.dart'as wsOrder;


class Order {
  int id;
  String customerId;
  DateTime orderDate;
  String shippingAddress;
  String billingAddress;
  double totalAmount;
  String orderStatus;
  String productName;
  String notes;
  bool archived;

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
  });

  Order copyWith({
    int? id,
    String? customerId,
    DateTime? orderDate,
    String? shippingAddress,
    String? billingAddress,
    double? totalAmount,
    String? orderStatus,
    String? productName,
    String? notes,
    bool? archived,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': id,
      'customerId': customerId,
      'orderDate': orderDate.toIso8601String(),
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'productName': productName,
      'notes': notes,
      //'firstName': firstName, // added new field
      //'lastName': lastName, // added new field
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    DateTime parseOrderDate(String date) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return DateTime.now(); // Return a default date value when parsing fails
      }
    }

    return Order(
      id: int.parse(map['order_id'].toString()),
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
      //firstName: map['first_name'] ?? '', // added new field
      //lastName: map['last_name'] ?? '', // added new field
    );
  }

  factory Order.fromOrderWS(wsOrder.Order order){
    return Order(
      customerId: order.customerId.toString(),
      archived: false,
      id: order.id!,
      notes: order.customerNote ?? '',
      orderDate: DateTime.parse(order.dateCreated??''),
      orderStatus: order.status!,
      billingAddress: order.billing!.address1!,
      productName: "Test fetch product from WooCommerce order_model.dart",
      totalAmount: double.parse(order.total!),
      shippingAddress: order.shipping!.address1!,
    );
  }
}

