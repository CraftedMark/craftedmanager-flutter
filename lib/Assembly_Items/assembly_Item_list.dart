import 'package:crafted_manager/Models/assembly_item_model.dart';
import 'package:crafted_manager/Models/product_model.dart';
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
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Assembly Item Management"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAssemblyItem()),
                );
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 45),
                child: Text(
                  'Manage Assembly Items',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[900],
      ),
      child: ListTile(
        title: Text(
          '$productName - $ingredientName',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          'Quantity: ${item.quantity.toString()}, Unit: ${item.unit}',
          style: const TextStyle(color: Colors.white),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
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
