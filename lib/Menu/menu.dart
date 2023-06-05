import 'package:crafted_manager/Assembly_Items/assembly_Item_list.dart';
import 'package:crafted_manager/CBP/cbp_screen.dart';
import 'package:crafted_manager/Contacts/contact_lists.dart';
import 'package:crafted_manager/Financial/finances_list.dart';
import 'package:crafted_manager/Orders/orders_list.dart';
import 'package:crafted_manager/Products/product_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

import 'menu_item.dart';

class MenuView extends StatefulWidget {
  final ZoomDrawerController drawerController;

  const MenuView({Key? key, required this.drawerController}) : super(key: key);

  @override
  MenuViewState createState() => MenuViewState();
}

class MenuViewState extends State<MenuView> {
  @override
  void initState() {
    super.initState();
  }

  void _onMenuItemSelected(MenuItem menuItem) {
    if (menuItem.destination != null) {
      widget.drawerController.close!();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => menuItem.destination!),
      );
    }
  }

  final List<MenuItem> menuItems = [
    MenuItem(
      title: "Orders/Invoicing",
      iconData: CupertinoIcons.cart_fill,
      subItems: [
        MenuItem(
            title: "Open Orders",
            iconData: CupertinoIcons.doc_text_fill,
            destination: const OrdersList(title: "Orders")),
        MenuItem(
            title: "Invoices",
            iconData: CupertinoIcons.money_dollar,
            destination: OrdersList(title: "Invoices"))
      ],
      destination: Text('Placeholder'), //TODO:FIX
    ),
    MenuItem(
      title: "Contacts",
      iconData: CupertinoIcons.person_2_fill,
      subItems: [
        MenuItem(
          title: "Customers",
          iconData: CupertinoIcons.person_crop_circle_fill,
          destination: const ContactsList(),
        ),
      ],
      destination: Text('Placeholder'), //TODO:FIX
    ),
    MenuItem(
      title: "Product Management",
      iconData: CupertinoIcons.cube_box_fill,
      subItems: [
        MenuItem(
            title: "Products",
            iconData: CupertinoIcons.cube_box,
            destination: ProductListPage()),
        MenuItem(
            title: "Customer Based Pricing",
            iconData: CupertinoIcons.money_dollar_circle_fill,
            destination: CustomerPricingScreen()),
        MenuItem(
            title: "Assembly Items",
            iconData: CupertinoIcons.cube_box,
            destination: AssemblyItemManagement()) // New menu item added.
      ],
      destination: Text('Placeholder'), //TODO:FIX
    ),
    MenuItem(
      title: "Accounting",
      iconData: CupertinoIcons.cube_box_fill,
      subItems: [
        MenuItem(
            title: "Expenses",
            iconData: CupertinoIcons.money_dollar_circle_fill,
            destination: FinancialScreen()),
        MenuItem(
            title: "Customer Based Pricing",
            iconData: CupertinoIcons.money_dollar_circle_fill,
            destination: CustomerPricingScreen()),
        // MenuItem(
        //     title: "Assembly Items",
        //     iconData: CupertinoIcons.money_dollar_circle_fill,
        //     destination: AssemblyItemManagement()) // New menu item added.
      ],
      destination: Text('Recipies'), //TODO:FIX
    ),
    // Add more menu items/categories here if needed.
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crafted Manager'),
        ),
        body: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (BuildContext context, int index) {
            MenuItem menuItem = menuItems[index];
            return menuItem.subItems == null
                ? ListTile(
                    leading: Icon(menuItem.iconData,
                        color: Theme.of(context).iconTheme.color),
                    title: Text(menuItem.title),
                    onTap: () => _onMenuItemSelected(menuItem),
                  )
                : ExpansionTile(
                    leading: Icon(menuItem.iconData,
                        color: Theme.of(context).iconTheme.color),
                    title: Text(menuItem.title),
                    children: menuItem.subItems!
                        .map(
                          (subItem) => ListTile(
                            leading: Icon(
                              subItem.iconData,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            title: Text(subItem.title),
                            onTap: () => _onMenuItemSelected(subItem),
                          ),
                        )
                        .toList(),
                  );
          },
        ),
      ),
    );
  }
}
