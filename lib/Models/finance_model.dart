import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';

class Payments {
  int id;
  int? orderId;
  double amount;
  DateTime dateAdded;
  String collectedBy;
  String method;
  bool collectedbymark;
  String? description;

  Payments({
    required this.id,
    this.orderId,
    required this.amount,
    required this.dateAdded,
    required this.collectedBy,
    required this.method,
    required this.collectedbymark,
    this.description,
  });

  Payments.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        orderId = data['order_id'],
        amount = data['amount'],
        dateAdded = DateTime.parse(data['date_added']),
        collectedBy = data['collected_by'],
        method = data['method'],
        collectedbymark = data['collectedbymark'] == 1,
        description = data['description'];
}

class Bills {
  int id;
  String name;
  double amount;
  DateTime dateAdded;
  DateTime dueDate;

  Bills({
    required this.id,
    required this.name,
    required this.amount,
    required this.dateAdded,
    required this.dueDate,
  });

  Bills.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        amount = data['amount'],
        dateAdded = DateTime.parse(data['date_added']),
        dueDate = DateTime.parse(data['due_date']);
}

class Expenses {
  int id;
  String description;
  double amount;
  DateTime dateAdded;
  String category;
  String vendor;
  String paidBy;

  Expenses({
    required this.id,
    required this.description,
    required this.amount,
    required this.dateAdded,
    required this.category,
    required this.vendor,
    required this.paidBy,
  });

  Expenses.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        description = data['description'],
        amount = data['amount'],
        dateAdded = DateTime.parse(data['date_added']),
        category = data['category'],
        vendor = data['vendor'],
        paidBy = data['paid_by'];
}

class Invoices {
  final int id;
  final int customerId;
  final String invoiceNumber;
  final Order order;
  final double totalAmount;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String status;
  final List<OrderedItem> orderedItems;

  Invoices({
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

  factory Invoices.fromJson(Map<String, dynamic> json) {
    List<OrderedItem>? orderedItems = [];
    if (json['ordereditems'] != null) {
      orderedItems = List.from(json['ordereditems'])
          .map((item) => OrderedItem.fromJson(item))
          .cast<OrderedItem>()
          .toList();
    }
    return Invoices(
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
