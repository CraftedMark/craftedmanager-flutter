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
  const MyApp({super.key});

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
        itemSource: 'Production',
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
