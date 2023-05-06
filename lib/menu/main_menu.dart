import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crafted_manager/menu/menu_item.dart';
import 'menu_item_widget.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:crafted_manager/menu/menu.dart';
import 'package:crafted_manager/Products/postgres_product.dart';

class MainMenu extends StatelessWidget {
  final Function(Product) onMenuItemSelected;

  const MainMenu({
    Key? key,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Menu'),
      ),
      child: Builder(builder: (context) {
        return CupertinoScrollbar(
          child: FutureBuilder<List<Product>>(
            future: ProductPostgres.getAllProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final products = snapshot.data;
                if (products != null) {
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      final product = products[index];

                      // Replace this with your custom product menu item widget
                      return MenuItemWidget(
                        item: MenuItem(
                          title: product.name,
                          description: product.description,
                          iconData: Icons.arrow_right, // Add the IconData here
                        ),
                        onTap: () => onMenuItemSelected(product),
                      );
                    },
                  );
                } else {
                  return const Text('No products available');
                }
              }
            },
          ),
        );
      }),
    );
  }
}
