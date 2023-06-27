import 'package:flutter/material.dart';

class InvoicingWidget extends StatefulWidget {
  final String title;

  const InvoicingWidget({super.key, required this.title});

  @override
  _InvoicingWidgetState createState() => _InvoicingWidgetState();
}

class _InvoicingWidgetState extends State<InvoicingWidget> {
  bool _isEditing = false;
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _invoiceAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Details',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Invoice Number',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Invoice Number',
                  ),
                )
              : const Text(
                  'INV-1234',
                  style: TextStyle(fontSize: 16.0),
                ),
          const SizedBox(height: 16.0),
          const Text(
            'Invoice Date',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceDateController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Invoice Date',
                  ),
                )
              : const Text(
                  '01/01/2022',
                  style: TextStyle(fontSize: 16.0),
                ),
          const SizedBox(height: 16.0),
          const Text(
            'Invoice Amount',
            style: TextStyle(fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          _isEditing
              ? TextField(
                  controller: _invoiceAmountController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Invoice Amount',
                  ),
                )
              : const Text(
                  '\$500.00',
                  style: TextStyle(fontSize: 16.0),
                ),
          const SizedBox(height: 32.0),
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
                      child: const Text('Save'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: const Text('Edit'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
