import 'package:flutter/material.dart';

class AddNewFinanceItem extends StatefulWidget {
  final int itemType;

  const AddNewFinanceItem({Key? key, required this.itemType}) : super(key: key);

  @override
  _AddNewFinanceItemState createState() => _AddNewFinanceItemState();
}

class _AddNewFinanceItemState extends State<AddNewFinanceItem> {
  String _name = '';
  String _description = '';
  String _amountStr = '';
  String _category = '';
  String _vendor = '';
  String _paidBy = '';

  int _orderId = 0;
  String _collectedBy = '';
  String _method = '';
  bool _collectedbymark = false;

  DateTime? selectedDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  Future<DateTime?> selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save the form data and upload to the server
    }
  }

  Widget _textFormField({
    String? labelText,
    TextInputType? keyboardType,
    required String? Function(String) onChanged,
  }) {
    return TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.itemType == 0) {
      title = 'Add Bill';
    } else if (widget.itemType == 1) {
      title = 'Add Expense';
    } else {
      title = 'Add Payment';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (widget.itemType == 0)
                      _textFormField(
                        labelText: 'Name',
                        onChanged: (_) => _name = _,
                      ),
                    const SizedBox(height: 16),
                    _textFormField(
                      labelText: 'Description',
                      onChanged: (_) => _description = _,
                    ),
                    const SizedBox(height: 16),
                    if (widget.itemType == 0 || widget.itemType == 1)
                      _textFormField(
                        labelText: 'Amount',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _amountStr = _,
                      ),
                    const SizedBox(height: 16),
                    if (widget.itemType == 0)
                      ListTile(
                        title: _textFormField(
                          labelText: 'Due Date',
                          onChanged: (value) {},
                        ),
                        onTap: () async {
                          selectedDate = await selectDate();
                          setState(() {});
                        },
                      ),
                    if (widget.itemType == 1) ...[
                      _textFormField(
                        labelText: 'Category',
                        onChanged: (_) => _category = _,
                      ),
                      _textFormField(
                        labelText: 'Vendor',
                        onChanged: (_) => _vendor = _,
                      ),
                      _textFormField(
                        labelText: 'Paid By',
                        onChanged: (_) => _paidBy = _,
                      ),
                    ],
                    if (widget.itemType == 2) ...[
                      _textFormField(
                        labelText: 'Order ID',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _orderId = int.tryParse(value) ?? 0;
                          return null;
                        },
                      ),
                      ListTile(
                        title: _textFormField(
                          labelText: 'Payment Date',
                          onChanged: (value) {},
                        ),
                        onTap: () async {
                          selectedDate = await selectDate();
                          setState(() {});
                        },
                      ),
                      _textFormField(
                        labelText: 'Collected By',
                        onChanged: (_) => _collectedBy = _,
                      ),
                      _textFormField(
                        labelText: 'Payment Method',
                        onChanged: (_) => _method = _,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Collected by Mark'),
                          Switch(
                            value: _collectedbymark,
                            onChanged: (value) {
                              setState(() {
                                _collectedbymark = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _saveForm,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
