
import 'package:crafted_manager/Contacts/people_db_manager.dart';
import 'package:crafted_manager/Models/people_model.dart';
import 'package:crafted_manager/config.dart';
import 'package:woosignal/models/payload/order_wc.dart' as bs ;
import 'package:woosignal/models/response/order.dart'as wsOrder;
import 'package:woosignal/models/response/product.dart' as wsProduct;
import 'package:woosignal/models/response/woosignal_app.dart';
import 'package:woosignal/woosignal.dart';

import '../Models/order_model.dart';
import '../Models/ordered_item_model.dart';
import '../Models/product_model.dart';


/// WooSignal wrapper
///
/// Must be initialized before use
class WooSignalService {
  WooSignalService._();

  static Future<void> init() async{
    return await WooSignal.instance.init(appKey: AppConfig.WOOSIGNAL_APP_KEY, debugMode: false);
  }

  static Future<WooSignalApp?> getApp() async {
    return WooSignal.instance.getApp();
  }

  static void test() async {
    var app = await WooSignal.instance.getApp();
    print(app!.appName);
  }

  static Future<void> createProduct(Product product) async{
    //TODO: add product category to WooCommerce
    var category = {'id': 1};
    //TODO: check atributes
    var atributes = {
      "attributes": [
        {
          "id": 6,
          "position": 0,
          "visible": false,
          "variation": true,
          "options": [
            "Black",
            "Green"
          ]
        },
        {
          "name": "Size",
          "position": 0,
          "visible": true,
          "variation": true,
          "options": [
            "S",
            "M"
          ]
        }
      ],
      "default_attributes": [
        {
          "id": 6,
          "option": "Black"
        },
        {
          "name": "Size",
          "option": "S"
        }
      ]
    };


    // await WooSignal.instance.createProduct(
    //     name: product.name,
    //     regularPrice: product.retailPrice.toString(),
    //     description: product.description,
    //     shortDescription: product.description,
    //     categories: category,
    //     images: {'src':'https://unsplash.com/photos/oL3-V8xhqlI'},
    // );
    var cat = wsProduct.Category(2, 'flutterTest', 'flutter_test');

    await WooSignal.instance.createProduct(
      name: product.name,
      regularPrice: product.retailPrice.toString(),
      description: product.description,
      shortDescription: product.description,
      categories: {},
      images: {},
    );
  }

  static Future <List<Product>> getProducts() async {
    List<wsProduct.Product> products = await  WooSignal.instance.getProducts();

    var res = List.generate(
        products.length,
        (index){
          var current = products[index];
          return Product.fromWSProduct(current);
        });

    return res;
  }

  static Future <int?> updateProduct(Product product) async {
    var data = product.toWSMap();
    print(data);
    var response = await WooSignal.instance.updateProduct(product.id!, data: data);

    return response?.id;
  }

  static Future<Product?> getProductById (int id) async {
    var rawProduct = await WooSignal.instance.retrieveProduct(id: id);

    if(rawProduct != null){
      return Product.fromWSProduct(rawProduct);
    }
    return null;
  }

  static Future<wsProduct.Product?> deleteProduct(int id) async {
    return await WooSignal.instance.deleteProduct(id);
  }



  ///Created a customer in WooCoomerce
  ///
  ///IF success: return new customer id in DB
  ///
  ///IF fail: return -1
  static Future<int> createCustomer(People customer) async {
    var wsCustomer = customer.toWSCustomer();

    var newCustomer = await WooSignal.instance.createCustomer(
      firstName: customer.firstName,
      lastName: customer.lastName,
      userName: "${customer.firstName}_${customer.lastName}",
      email: customer.email,
      billing: wsCustomer.billing?.toJson(),
      shipping: wsCustomer.shipping?.toJson(),
    );
    return newCustomer?.id ?? -1;
  }

  static Future<List<People>> getCustomers() async {
    var rawCustomers = await WooSignal.instance.getCustomers(page: 1, perPage: 20);
    return List.generate(
      rawCustomers.length,
      (index) {
        var current = rawCustomers[index];
        return People.fromWSCustomer(current);
      },
    );
  }

  ///IF user with [id] exist: return customer
  ///
  ///IF fail: return null
  static Future<People?> getCustomerById(int id) async{
    final wsCustomer = await WooSignal.instance.retrieveCustomer(id: id);
    if(wsCustomer != null){
      return People.fromWSCustomerS(wsCustomer);
    }
    return null;
  }

  static Future<void> updateCustomer(People customer) async {
    var data = customer.toWSCustomer().toJson();
    data.removeWhere((key, value) => key =='username');//with [username] field don`t work

    await WooSignal.instance.updateCustomer(customer.id, data: data);
  }

  static Future<void> deleteCustomer(int id) async {
    await WooSignal.instance.deleteCustomer(id, force: true);
  }



  static Future<void> createOrder(Order order, List<OrderedItem> items) async {
    final customer = await  WooSignal.instance.retrieveCustomer(id: int.parse(order.customerId));

    final orderStatuses = ["processing", "completed"];

    List<bs.LineItems> orderedItems = List.generate(
        items.length,
        (index)  {
          final currentItem = items[index];
          return bs.LineItems(
            // name: currentItem.productName,
            productId: currentItem.productId,
            quantity: currentItem.quantity,
            // subtotal: (currentItem.productRetailPrice*currentItem.quantity).toString(),
            // taxClass: '0.0',
            // total: (currentItem.productRetailPrice*currentItem.quantity).toString(),
            // variationId: 0
          );
        },
    );

    var customerBilling = customer?.billing;
    var billing = bs.Billing.fromJson(customerBilling!.toJson());

    var customerShipping = customer?.shipping;
    var shipping = bs.Shipping.fromJson(customerShipping!.toJson());


    bs.OrderWC _order = bs.OrderWC(
      status: "processing",
      // setPaid: false, //work
      // paymentMethod: 'bacs',
      billing: billing,//work
      shipping: shipping,//work
      lineItems: orderedItems,
      customerId: int.parse(order.customerId),
      // paymentMethodTitle: "Direct Bank Transfer",//work
      // shippingLines: [bs.ShippingLines(total: '0', methodId: "flat_rate", methodTitle: "Flat_rate")],
      customerNote: "Test notes",
      // currency: null,
      // feeLines: null,
      // metaData: null,
      // parentId: 0,
      // paymentMethod: null,
      // paymentMethodTitle: null,
      // setPaid: null,
      // shippingLines: null,
    );
    await WooSignal.instance.createOrder(_order);

  }

  static Future<List<Order>> getOrders() async {
    var wcOrders = await WooSignal.instance.getOrders();
    wcOrders.forEach((element) {print(element.toJson());});
    return List.generate(wcOrders.length, (index) => Order.fromOrderWS(wcOrders[index]));
  }

  static Future<Order?> getOrderById(int id) async {
    var rawOrder = await  WooSignal.instance.retrieveOrder(id);

    if(rawOrder != null){
      return Order.fromOrderWS(rawOrder);
    }
    return null;
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
