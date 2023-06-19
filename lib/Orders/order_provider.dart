import 'package:flutter/foundation.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../ProductionList/production_list_db_manager.dart';

class FullOrder {
  final Order order;
  final People person;

  FullOrder(this.order, this.person);
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<OrderedItem> _filteredItems = [];

  List<Order> get orders => _orders;

  Order getOrderedItemsForOrder(int orderId) {
    return _orders.firstWhere((order) => order.id == orderId);
  }

  List<OrderedItem> get filteredItems => _filteredItems;

  Future<void> fetchOrders() async {
    try {
      _orders =
          await ProductionListDbManager.getOpenOrdersWithAllOrderedItems();
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void filterOrderedItems(String itemSource) {
    _filteredItems = [];
    for (var order in _orders) {
      for (var item in order.orderedItems) {
        if (item.itemSource == itemSource) {
          _filteredItems.add(item);
        }
      }
    }

    _filteredItems.sort((a, b) => a.productId.compareTo(b.productId));

    for (var i = 1; i < _filteredItems.length; i++) {
      var prev = _filteredItems[i - 1];
      var current = _filteredItems[i];
      if (prev.productId == current.productId) {
        prev.quantity += current.quantity;
        _filteredItems.removeAt(i);
        i--;
      }
    }
    notifyListeners();
  }

  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void deleteOrder(Order order) {
    _orders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void addOrderedItem(int orderId, OrderedItem orderedItem) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderedItems.add(orderedItem);
    notifyListeners();
  }

  void updateOrderedItem(int orderId, OrderedItem updatedItem) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    final index =
        order.orderedItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      order.orderedItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteOrderedItem(int orderId, OrderedItem item) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderedItems.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  void updateOrderStatus(int orderId, String newStatus, bool isArchived) {
    final order = _orders.firstWhere((order) => order.id == orderId);
    order.orderStatus = newStatus;
    if (isArchived) {
      order.isArchived = true;
    }
    notifyListeners();
  }

  Future<List<FullOrder>> getFullOrders() async {
    await fetchOrders();
    return Future.wait(_orders.map((Order order) async {
      People person = await fetchCustomerById(int.parse(order.customerId));
      return FullOrder(order, person);
    }).toList());
  }

  // Fetch People data by their id
  Future<People> fetchCustomerById(int id) async {
    // Fetch customer's data using fetchCustomer from PeoplePostgres
    People? customer = await PeoplePostgres.fetchCustomer(id);

    if (customer == null) {
      throw Exception('No customer data found with ID: $id');
    }

    return customer;
  }
}
