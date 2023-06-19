import 'package:flutter/material.dart';

import 'add_new_finance_item.dart';
import 'finances_db_manager.dart';

class FinancialScreen extends StatefulWidget {
  @override
  _FinancialScreenState createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  int segmentedControlValue = 0;

  Future<List<Map<String, dynamic>>> _initializeDataFuture() async {
    String tableName;

    switch (segmentedControlValue) {
      case 0:
        tableName = 'bills';
        break;
      case 1:
        tableName = 'expenses';
        break;
      case 2:
        tableName = 'payments';
        break;
      default:
        tableName = 'invoices';
    }

    return getAll(tableName);
  }

  Future<void> _handleRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: themeData.iconTheme.color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewFinanceItem(
                    itemType: segmentedControlValue,
                  ),
                ),
              );
            },
          ),
        ],
        backgroundColor: themeData.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ToggleButtons(
                color: themeData.colorScheme.secondary,
                selectedColor: themeData.colorScheme.primary,
                fillColor: themeData.colorScheme.secondary.withOpacity(0.2),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Bills"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Expenses"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Payments"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Invoices"),
                  ),
                ],
                onPressed: (val) {
                  setState(() {
                    segmentedControlValue = val;
                  });
                },
                isSelected:
                    List.generate(4, (index) => index == segmentedControlValue),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _initializeDataFuture(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error fetching data'));
                    } else {
                      List<Map<String, dynamic>> data = snapshot.data!;
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          if (segmentedControlValue == 0) {
                            return ListTile(
                              title: Text(
                                "Bill ${data[index]['id']}: ${data[index]['name']}",
                                style: themeData.textTheme.bodyText1,
                              ),
                            );
                          } else if (segmentedControlValue == 1) {
                            return ListTile(
                              title: Text(
                                  "Expense ${data[index]['id']}: ${data[index]['name']}",
                                  style: themeData.textTheme.bodyText1),
                            );
                          } else if (segmentedControlValue == 2) {
                            return ListTile(
                              title: Text(
                                  "Payment ${data[index]['id']}: ${data[index]['name']}",
                                  style: themeData.textTheme.bodyText1),
                            );
                          } else {
                            return ListTile(
                              title: Text(
                                  "Invoice ${data[index]['id']}: ${data[index]['name']}",
                                  style: themeData.textTheme.bodyText1),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
