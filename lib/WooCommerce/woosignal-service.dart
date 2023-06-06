
import 'package:crafted_manager/config.dart';
import 'package:woosignal/models/response/customer.dart';
import 'package:woosignal/models/response/order.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/woosignal.dart';


/// WooSignal wrapper
///
/// Must be initialized before use
class WooSignalService {

  static void test() async {
    var app = await WooSignal.instance.getApp();

    print(app);
  }

  static Future<void> init(String appKey) async{
    return await WooSignal.instance.init(appKey: appKey, debugMode: false);
  }

  static Future <List<Product>> getProducts() async {
    return WooSignal.instance.getProducts(
      perPage: 50,
      page: 1,
      );
  }

  static Future <List<Customer>> getCustomers() async {
    return WooSignal.instance.getCustomers();
  }

  static Future<List<Order>> getOrders() async {
    return WooSignal.instance.getOrders();
  }

  static Future<WooSignalApp?> getApp() async {
    return WooSignal.instance.getApp();
  }

  //
  // static Future<>  () async {
  //   return WooSignal.instance.
  // }
  //
  // static Future< >  () async {
  //   return WooSignal.instance.
  // }
  //
  // static Future< >  () async {
  //   return WooSignal.instance.
  // }
  //
  // static Future< >  () async {
  //   return WooSignal.instance.
  // }
  // static Future< >  () async {
  //   return WooSignal.instance.
  // }
  //
  // static Future< >  () async {
  //   return WooSignal.instance.
  // }
  //



}
