import 'dart:io';
import 'package:crafted_manager/Menu/menu_item.dart';
import 'package:crafted_manager/PostresqlConnection/postqresql_connection_manager.dart';
import 'package:crafted_manager/ProductionList/production_list.dart';
import 'package:crafted_manager/Providers/employee_provider.dart';
import 'package:crafted_manager/Providers/order_provider.dart'; // Assuming your OrderProvider is in this file
import 'package:crafted_manager/Providers/people_provider.dart';
import 'package:crafted_manager/Providers/product_provider.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'WooCommerce/woosignal-service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  PostgreSQLConnectionManager.init();
  await PostgreSQLConnectionManager.open();

  // Initialize the providers before runApp is called.
  final OrderProvider orderProvider = OrderProvider();
  final PeopleProvider peopleProvider = PeopleProvider();
  final ProductProvider productProvider = ProductProvider();

  if (!Platform.isWindows) {
    await OneSignal.shared.setAppId(AppConfig.ONESIGNAL_APP_KEY);
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("new notification + $result");
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) async {
      print('___________update orders___________');
      await orderProvider.fetchOrders();
    });
  }
  if(AppConfig.ENABLE_WOOSIGNAL){
    await WooSignalService.init();//TODO: enable WooSignal

  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<OrderProvider>(
            create: (context) => orderProvider),
        ChangeNotifierProvider<PeopleProvider>(
            create: (context) => PeopleProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (context) => ProductProvider()),
        ChangeNotifierProvider<EmployeeProvider>(
            create: (context) => EmployeeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    Provider.of<PeopleProvider>(context, listen: false).fetchPeople();
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    //Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await PostgreSQLConnectionManager.close();
    }
    if (state == AppLifecycleState.resumed) {
      PostgreSQLConnectionManager.init();
      await PostgreSQLConnectionManager.open();
    }
  }

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
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor:  UIConstants.BACKGROUND_COLOR,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: UIConstants.BACKGROUND_COLOR,
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.blueAccent,
          secondary: const Color(0xFFB085F5),
          background: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFB085F5)),
          bodyMedium: TextStyle(color: UIConstants.TEXT_COLOR),
        ),
        iconTheme: const IconThemeData(color: UIConstants.ICON_COLOR),
      ),
      home: Builder(
        builder: (context) => ProductionList(
          orderedItems: const [],
          itemSource: 'Production',
        ),
      ),
    );
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
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: Image.network(
                          'https://craftedsolutions.co/UserProfile.png')
                      .image,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Crafted Manager',
                textAlign: TextAlign.left,
                style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
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
