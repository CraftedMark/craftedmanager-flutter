import 'package:flutter/material.dart';

class InvoicingWidget extends StatefulWidget {
  final String title;

  InvoicingWidget({required this.title});

  @override
  _InvoicingWidgetState createState() => _InvoicingWidgetState();
}

class _InvoicingWidgetState extends State<InvoicingWidget> {
  bool _isEditing = false;
  TextEditingController _invoiceNumberController = TextEditingController();
  TextEditingController _invoiceDateController = TextEditingController();
  TextEditingController _invoiceAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Details',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Text(
            'Invoice Number',
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter Invoice Number',
                  ),
                )
              : Text(
                  'INV-1234',
                  style: TextStyle(fontSize: 16.0),
                ),
          SizedBox(height: 16.0),
          Text(
            'Invoice Date',
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceDateController,
                  decoration: InputDecoration(
                    hintText: 'Enter Invoice Date',
                  ),
                )
              : Text(
                  '01/01/2022',
                  style: TextStyle(fontSize: 16.0),
                ),
          SizedBox(height: 16.0),
          Text(
            'Invoice Amount',
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceAmountController,
                  decoration: InputDecoration(
                    hintText: 'Enter Invoice Amount',
                  ),
                )
              : Text(
                  '\$500.00',
                  style: TextStyle(fontSize: 16.0),
                ),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isEditing
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                      child: Text('Save'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text('Edit'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
