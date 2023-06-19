import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';

class Invoice {
  final int id;
  final int customerId;
  final String invoiceNumber;
  final Order order;
  final double totalAmount;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status;
  final List<OrderedItem> orderedItems;

  Invoice({
    required this.id,
    required this.customerId,
    required this.invoiceNumber,
    required this.order,
    required this.totalAmount,
    required this.invoiceDate,
    required this.dueDate,
    required this.status,
    required this.orderedItems,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    List<OrderedItem>? orderedItems = [];
    if (json['ordereditems'] != null) {
      orderedItems = List.from(json['ordereditems'])
          .map((item) => OrderedItem.fromJson(item))
          .cast<OrderedItem>()
          .toList();
    }
    return Invoice(
      id: json['id'],
      customerId: json['customer_id'],
      invoiceNumber: json['invoice_number'],
      order: Order.fromJson(json['order']),
      totalAmount: json['total_amount'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      orderedItems: orderedItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'invoice_number': invoiceNumber,
        'order': order.toJson(),
        'total_amount': totalAmount,
        'invoice_date': invoiceDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'status': status,
        'ordered_items': orderedItems.map((item) => item.toJson()).toList()
      };
}
