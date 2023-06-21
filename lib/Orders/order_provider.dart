import 'package:flutter/foundation.dart';

import '../Contacts/people_db_manager.dart';
import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/people_model.dart';
import '../ProductionList/production_list_db_manager.dart';
import '../services/one_signal_api.dart';
import 'orders_db_manager.dart';

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

  Future<void> createOrder(Order newOrder, People customer) async {
    await OrderPostgres().createOrder(newOrder, newOrder.orderedItems);
    // WooSignalService.createOrder(newOrder, orderedItems);//TODO: Enable WooSignal

    var customerFullName = "${customer.firstName} ${customer.lastName}";
    var payload = "New order from: $customerFullName";
    _sendPushNotification(payload);
  }

  Future<bool> updateOrder(Order updatedOrder) async {
    return OrderPostgres.updateOrder(updatedOrder, updatedOrder.orderedItems);
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
      order.archived = true;
    }
    notifyListeners();
  }

  Future<List<FullOrder>> getFullOrders() async {
    if(_orders.isEmpty){
      await fetchOrders();
    }

    Set<People> customers = {};
    List<FullOrder> full = [];
    for(final o in _orders){
      if(customers.where((c) => c.id.toString() == o.customerId).isEmpty){
        final customer = await fetchCustomerById(int.parse(o.customerId));
        customers.add(customer);
      }
      full.add(FullOrder(o, customers.firstWhere((c) => c.id.toString() == o.customerId)));
    }

    return full;
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

  Future<void> _sendPushNotification(String payload) async {
    await OneSignalAPI.sendNotification(payload);
  }

}
