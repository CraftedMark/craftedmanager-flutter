import 'package:crafted_manager/Models/assembly_item_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_assembly_item.dart';

class AssemblyItemManagement extends StatefulWidget {
  @override
  _AssemblyItemManagementState createState() => _AssemblyItemManagementState();
}

class _AssemblyItemManagementState extends State<AssemblyItemManagement> {
  List<AssemblyItem> assemblyItems = []; // Example list for assembly items
  List<Product> products = []; // Example list for products

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Assembly Item Management"),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.add),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => AddAssemblyItem()),
            );
          },
        ),
      ),
      child: Container(
        color: CupertinoColors.darkBackgroundGray,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Manage Assembly Items',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: assemblyItems.length,
                itemBuilder: (context, index) {
                  return _buildItemTile(assemblyItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(AssemblyItem item) {
    // Retrieve the product names based on the id, assuming that the product list is already loaded
    String productName =
        products.firstWhere((element) => element.id == item.productId).name;
    String ingredientName =
        products.firstWhere((element) => element.id == item.ingredientId).name;

    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CupertinoColors.black,
      ),
      child: CupertinoListTile(
        title: Text(
          '$productName - $ingredientName',
          style: TextStyle(color: CupertinoColors.white),
        ),
        subtitle: Text(
          'Quantity: ${item.quantity.toString()}, Unit: ${item.unit}',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: IconButton(
          icon: Icon(CupertinoIcons.delete,
              color: CupertinoColors.destructiveRed),
          onPressed: () {
            // Add your delete functionality here
          },
        ),
        onTap: () {
          // Add your update or view functionality here
        },
      ),
    );
  }
}