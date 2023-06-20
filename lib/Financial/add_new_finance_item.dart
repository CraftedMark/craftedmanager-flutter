import 'package:flutter/cupertino.dart';

class AddNewFinanceItem extends StatefulWidget {
  final int itemType;

  const AddNewFinanceItem({super.key, required this.itemType});

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

  Future<DateTime?> showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDateTime,
    DateTime? minimumDate,
    DateTime? maximumDate,
  }) {
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: initialDateTime,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            onDateTimeChanged: (DateTime newDateTime) {
              selectedDate = newDateTime;
            },
          ),
        );
      },
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
    return CupertinoTextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      placeholder: labelText,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey, width: 0.0),
        ),
      ),
    );
  }

  Widget _dueDateFormField({String labelText = 'Due Date'}) {
    return GestureDetector(
      onTap: () async {
        selectedDate = await showCupertinoDatePicker(
          context: context,
          initialDateTime: selectedDate ?? DateTime.now(),
          minimumDate: DateTime(2020, 1, 1),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
        );

        setState(() {});
      },
      child: AbsorbPointer(
        child: _textFormField(
          labelText: labelText,
          onChanged: (value) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.itemType == 0) {
      title = 'Add new Bill';
    } else if (widget.itemType == 1) {
      title = 'Add new Expense';
    } else {
      title = 'Add new Payment';
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
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
                      _dueDateFormField(labelText: 'Due Date'),
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
                      _dueDateFormField(
                        labelText: 'Payment Date',
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
                          CupertinoSwitch(
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
                      child: CupertinoButton.filled(
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
