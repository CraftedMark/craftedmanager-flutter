

import 'dart:io';

import 'package:crafted_manager/Menu/menu_item.dart';
import 'package:crafted_manager/WooCommerce/test_woo.dart';
import 'package:crafted_manager/WooCommerce/woosignal-service.dart';
import 'package:crafted_manager/config.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!Platform.isWindows){
    await OneSignal.shared.setAppId(AppConfig.ONESIGNAL_APP_KEY);
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print("new notification + ${result}");
      // TODO: open appropriate page
    });
  }
  WooSignalService.init(AppConfig.WOOSIGNAL_APP_KEY);
  // runApp(MyApp());

  runApp(TestWoo());

}


class MyApp extends StatelessWidget {
  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
      ),
    );
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
      theme: _buildThemeData(),
      // home: MyHomePage(),
      home: TestWoo(),
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

  List<Widget> buildHomepageCards() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ExpansionTileCard(
          leading: const CircleAvatar(child: Text('1')),
          title: const Text('Card 1'),
          subtitle: const Text('This is the first card.'),
          children: <Widget>[
            const ListTile(
              title: Text('Lorem Ipsum'),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ExpansionTileCard(
          leading: const CircleAvatar(child: Text('2')),
          title: const Text('Card 2'),
          subtitle: const Text('This is the second card.'),
          children: <Widget>[
            const ListTile(
              title: Text('Lorem Ipsum'),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _sliderDrawerKey.currentState?.openSlider();
          },
        ),
      ),
      body: SafeArea(
        child: SliderDrawer(
          key: _sliderDrawerKey,
          sliderOpenSize: 350,
          slider: _SliderView(
            onItemClick: (title) {
              _sliderDrawerKey.currentState!.closeSlider();
              setState(() {
                this.title = title;
              });
            },
          ),
          child: ListView(
            padding: EdgeInsets.all(24.0),
            children: buildHomepageCards(),
          ),
        ),
      ),
    );
  }
}

class _SliderView extends StatelessWidget {
  final Function(String)? onItemClick;
  final Color backgroundColor;
  final EdgeInsets padding;
  final TextStyle menuTitleStyle;
  final EdgeInsets menuContentPadding;
  final EdgeInsets expansionTilePadding;

  const _SliderView({
    Key? key,
    this.onItemClick,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.only(top: 30, bottom: 20),
    this.menuTitleStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    this.menuContentPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.expansionTilePadding = const EdgeInsets.symmetric(horizontal: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: padding,
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
                style: menuTitleStyle,
              ),
              const SizedBox(
                height: 20,
              ),
              ...menuItems.map<Widget>((menuItem) {
                return menuItem.subItems.isNotEmpty
                    ? ExpansionTile(
                        tilePadding: expansionTilePadding,
                        title: Text(menuItem.title, style: menuTitleStyle),
                        leading: Icon(
                          menuItem.iconData,
                          color: menuTitleStyle.color,
                        ),
                        children: menuItem.subItems.map<Widget>((subItem) {
                          return ListTile(
                            contentPadding: menuContentPadding,
                            leading: Icon(
                              subItem.iconData,
                              color: menuTitleStyle.color,
                            ),
                            title: Text(
                              subItem.title,
                              style: menuTitleStyle,
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
                        contentPadding: menuContentPadding,
                        title: Text(menuItem.title, style: menuTitleStyle),
                        leading: Icon(
                          menuItem.iconData,
                          color: menuTitleStyle.color,
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
