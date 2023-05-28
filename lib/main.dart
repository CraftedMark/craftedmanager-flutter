import 'package:crafted_manager/Menu/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(MyApp());
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
      home: MyHomePage(),
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
    title = "Home";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliderDrawer(
        appBar: SliderAppBar(
            appBarColor: Colors.black,
            title: Text(title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
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
        child: Center(
          child: Text('Your app body'),
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
    this.padding = const EdgeInsets.only(top: 30),
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
      padding: padding,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.grey,
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
    );
  }
}
