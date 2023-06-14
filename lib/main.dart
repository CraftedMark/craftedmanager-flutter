import 'dart:io';

import 'package:crafted_manager/Menu/menu_item.dart';
import 'package:crafted_manager/Models/order_model.dart';
import 'package:crafted_manager/Models/ordered_item_model.dart';
import 'package:crafted_manager/ProductionList/production_list.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isWindows) {
    await OneSignal.shared.setAppId(AppConfig.ONESIGNAL_APP_KEY);
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("new notification + ${result}");
    });
  }
  WooSignalService.init(AppConfig.WOOSIGNAL_APP_KEY);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        backgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.blueAccent,
          secondary: Color(0xFFB085F5),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color(0xFFB085F5)),
          bodyText2: TextStyle(color: Color(0xFFB085F5)),
        ),
        iconTheme: IconThemeData(color: Color(0xFFB085F5)),
      ),
      home: ProductionList(
        orderedItems: [],
        itemSource: '',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  late String title;

  @override
  void initState() {
    title = "Dashboard";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            _sliderDrawerKey.currentState?.openSlider();
          },
        ),
      ),
      body: SafeArea(
        child: SliderDrawer(
          key: _sliderDrawerKey,
          sliderOpenSize: 350,
          slider: SliderView(
            onItemClick: (title) {
              _sliderDrawerKey.currentState!.closeSlider();
              setState(() {
                this.title = title;
              });
            },
          ),
          child: ListView(
              padding: EdgeInsets.all(24.0), children: buildHomepageCards()),
        ),
      ),
    );
  }

  List<Widget> buildHomepageCards() {
    List<Order> openOrders = [
      Order(
        id: 1,
        customerId: '1',
        orderDate: DateTime.now(),
        shippingAddress: '1234 Street, City, Country',
        billingAddress: '1234 Street, City, Country',
        orderedItems: [
          OrderedItem(
            id: 1,
            orderId: 1,
            productName: 'Product 1',
            productId: 101,
            name: 'Item 1',
            quantity: 10,
            price: 100.0,
            discount: 0.0,
            productDescription: 'Description for Item 1',
            productRetailPrice: 100.0,
            status: 'New',
            itemSource: 'Production',
          ),
        ],
        totalAmount: 100.0,
        orderStatus: 'New',
        productName: 'Product 1',
        notes: '',
        archived: false,
      ),
    ];

    return [
      ...openOrders.map((order) {
        return Column(
          children: order.orderedItems.map((item) {
            return ListTile(
              title: Text(item.productName),
              trailing: Text(item.quantity.toString()),
            );
          }).toList(),
        );
      }).toList(),
    ];
  }
}

class SliderView extends StatelessWidget {
  final Function(String)? onItemClick;

  const SliderView({
    Key? key,
    this.onItemClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: Image.network(
                          'https://nikhilvadoliya.github.io/assets/images/nikhil_1.webp')
                      .image,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Crafted Manager',
                textAlign: TextAlign.left,
                style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(
                height: 20,
              ),
              ...menuItems.map<Widget>((menuItem) {
                return menuItem.subItems.isNotEmpty
                    ? ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 2),
                        title: Text(menuItem.title,
                            style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                        leading: Icon(
                          menuItem.iconData,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        children: menuItem.subItems.map<Widget>((subItem) {
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: Icon(
                              subItem.iconData,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            title: Text(
                              subItem.title,
                              style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18)
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => subItem.destination,
                                ),
                              );
                            },
                          );
                        }).toList(),
                      )
                    : ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(menuItem.title,
                            style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                        leading: Icon(
                          menuItem.iconData,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onTap: () {
                          onItemClick?.call(menuItem.title);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => menuItem.destination,
                            ),
                          );
                        },
                      );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
