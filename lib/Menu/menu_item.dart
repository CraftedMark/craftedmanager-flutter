import 'package:crafted_manager/Admin/create_user.dart';
import 'package:crafted_manager/CBP/cbp_people_search.dart';
import 'package:crafted_manager/Calculators/chocolate_calculator.dart';
import 'package:crafted_manager/Calculators/material_calc.dart';
import 'package:crafted_manager/Employee/employee_list.dart';
import 'package:crafted_manager/Ingredients/ingredient_list.dart';
import 'package:crafted_manager/Invoice/invoice_screen.dart';
import 'package:crafted_manager/Orders/orders_list.dart';
import 'package:crafted_manager/ProductionList/production_list.dart';
import 'package:crafted_manager/Products/product_page.dart';
import 'package:crafted_manager/Recipes/recipe_manager.dart';
import 'package:flutter/material.dart';

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
    title: "Calculators",
    iconData: Icons.calculate_rounded,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Calculator",
        iconData: Icons.calculate_outlined,
        destination: ChocoBarCalc(),
      ),
      MenuItem(
        title: "Dosing Calculator",
        iconData: Icons.calculate_outlined,
        destination: MaterialCalculator(),
      ),
    ],
  ),
  MenuItem(
    title: "Orders/Invoicing",
    iconData: Icons.shopping_cart,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Create Orders",
        iconData: Icons.list_alt,
        destination: const OrdersList(listType: OrderListType.newOrders),
      ),
      MenuItem(
        title: "Open Orders",
        iconData: Icons.list_alt,
        destination:
            const OrdersList(listType: OrderListType.productionAndCancelled),
      ),
      MenuItem(
        title: "Archived Orders",
        iconData: Icons.archive,
        destination: const OrdersList(listType: OrderListType.archived),
      ),
      MenuItem(
        title: "Invoices",
        iconData: Icons.attach_money,
        destination: const InvoicesList(
          invoices: [],
        ),
      ),
    ],
  ),
  MenuItem(
    title: "Contacts",
    iconData: Icons.contacts,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Customers",
        iconData: Icons.people,
        destination: const ContactsList(),
      ),
    ],
  ),
  MenuItem(
    title: "Product Management",
    iconData: Icons.inventory_2,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Products",
        iconData: Icons.shopping_basket,
        destination: const ProductListPage(),
      ),
      MenuItem(
        title: "Customer Based Pricing",
        iconData: Icons.price_change,
        destination: const CustomerSearchScreen(),
      ),
      MenuItem(
        title: "Ingredients",
        iconData: Icons.local_dining,
        destination: const IngredientList(),
      ),
      MenuItem(
          title: "Recipes",
          iconData: Icons.book,
          destination: RecipeManager(onAddRecipe: (newRecipe) {})),
      MenuItem(
        title: "Production List",
        iconData: Icons.book,
        destination: ProductionList(),
      ),
      MenuItem(
        title: "Assembly Items",
        iconData: Icons.layers,
        destination: const AssemblyItemManagement(),
      ),
    ],
  ),
  // MenuItem(
  //   title: "Production",
  //   iconData: Icons.account_balance,
  //   destination: Container(),
  //   subItems: [
  //     MenuItem(
  //       title: "Production Sheets",
  //       iconData: Icons.money_off,
  //destination: ProductionReport(),
  //     ),
  //   ],
  // ),
  MenuItem(
    title: "Accounting",
    iconData: Icons.account_balance,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Money In/Out",
        iconData: Icons.money_off,
        destination: FinancialScreen(),
      ),
    ],
  ),
  MenuItem(
    title: "Management",
    iconData: Icons.account_balance,
    destination: Container(),
    subItems: [
      MenuItem(
        title: "Users",
        iconData: Icons.money_off,
        destination: UserCreate(),
      ),
      MenuItem(
        title: "Employees",
        iconData: Icons.money_off,
        destination: EmployeeManager(),
      ),
      MenuItem(
        title: "Labor Rates",
        iconData: Icons.money_off,
        destination: UserCreate(),
      ),
    ],
  ),
  // MenuItem(
  //   title: "Woocommerce",
  //   iconData: Icons.shopping_cart_outlined,
  //   Destination: WooCommerce(),
  // )
];
