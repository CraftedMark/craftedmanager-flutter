import 'package:flutter/material.dart';

import '../assets/ui.dart';

class DropdownMenuCustom extends StatelessWidget {
  const DropdownMenuCustom({
    Key? key,
    required this.onChanged,
    required this.value,
    required this.items
  }) : super(key: key);

  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
      dropdownColor: UIConstants.GREY_LIGHT,
      borderRadius: BorderRadius.circular(15),
      decoration: InputDecoration(
        enabledBorder: UIConstants.FIELD_BORDER,
        disabledBorder: UIConstants.FIELD_BORDER,
        focusedBorder: UIConstants.FIELD_BORDER,
        labelText: 'Order Status:',
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        filled: true,
        fillColor: UIConstants.GREY_LIGHT,
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
