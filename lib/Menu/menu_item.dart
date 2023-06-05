import 'package:crafted_manager/CBP/cbp_people_search.dart';
import 'package:crafted_manager/Ingredients/ingredient_list.dart';
import 'package:crafted_manager/Invoice/invoice_screen.dart';
import 'package:crafted_manager/Orders/orders_list.dart';
import 'package:crafted_manager/Products/product_page.dart';
import 'package:crafted_manager/Recipes/recipe_manager.dart';
import 'package:flutter/cupertino.dart';

import '../Assembly_Items/assembly_Item_list.dart';
import '../Contacts/contact_lists.dart';
import '../Financial/finances_list.dart';

class MenuItem {
  final IconData iconData;
  final String title;
  final Widget destination;
  final List<MenuItem> subItems;

  MenuItem({
    required this.iconData,
    required this.title,
    required this.destination,
    this.subItems = const [],
  });
}

List<MenuItem> menuItems = [
  MenuItem(
    title: "Orders/Invoicing",
    iconData: CupertinoIcons.cart_fill,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Open Orders",
        iconData: CupertinoIcons.doc_text_fill,
        destination: const OrdersList(title: "Orders"),
      ),
      MenuItem(
        title: "Archived Orders",
        iconData: CupertinoIcons.archivebox_fill,
        destination: const OrdersList(
          title: "Archive",
          listType: OrderListType.archived,
        ),
      ),
      MenuItem(
        title: "Invoices",
        iconData: CupertinoIcons.money_dollar,
        destination: InvoicingWidget(title: "Invoices"),
      ),
    ],
  ),
  MenuItem(
    title: "Contacts",
    iconData: CupertinoIcons.person_2_fill,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Customers",
        iconData: CupertinoIcons.person_crop_circle_fill,
        destination: ContactsList(),
      ),
    ],
  ),
  MenuItem(
    title: "Product Management",
    iconData: CupertinoIcons.cube_box_fill,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Products",
        iconData: CupertinoIcons.cube_box,
        destination: ProductListPage(),
      ),
      MenuItem(
        title: "Customer Based Pricing",
        iconData: CupertinoIcons.money_dollar_circle_fill,
        destination: CustomerSearchScreen(),
      ),
      MenuItem(
        title: "Ingredients",
        iconData: CupertinoIcons.money_dollar_circle_fill,
        destination: IngredientList(),
      ),
      MenuItem(
        title: "Recipes",
        iconData: CupertinoIcons.money_dollar_circle_fill,
        destination: RecipeManager(),
      ),
      MenuItem(
        title: "Assembly Items",
        iconData: CupertinoIcons.cube_box,
        destination: AssemblyItemManagement(),
      ),
    ],
  ),
  MenuItem(
    title: "Accounting",
    iconData: CupertinoIcons.cube_box_fill,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Expenses",
        iconData: CupertinoIcons.money_dollar_circle_fill,
        destination: FinancialScreen(),
      ),
    ],
  ),
//   MenuItem(
//     title: "Woocommerce",
//     iconData: CupertinoIcons.cube_box_fill,
//     Destination: WooCommerce(),
//   )
];
