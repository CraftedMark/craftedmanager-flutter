import 'dart:convert';

import 'package:crafted_manager/Orders/database_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({Key? key}) : super(key: key);

  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  Map<String, List<Map<String, dynamic>>> _schemas = {};

  @override
  void initState() {
    super.initState();
    fetchAndStoreAllSchemas();
    _loadAllSchemas();
  }

  Future<void> _loadAllSchemas() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString('all_schemas');
    if (jsonString != null) {
      setState(() {
        _schemas = jsonDecode(jsonString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Database Schema'),
      ),
      child: SafeArea(
        child: _schemas.isEmpty
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                itemCount: _schemas.length,
                itemBuilder: (BuildContext context, int index) {
                  final tableName = _schemas.keys.elementAt(index);
                  final columns = _schemas[tableName]!;
                  return ExpansionTile(
                    title: Text(tableName),
                    children: columns.map((column) {
                      return ListTile(
                        title: Text(column['column_name'].toString()),
                        subtitle: Text(column['data_type'].toString()),
                      );
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }
}
