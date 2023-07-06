import 'package:flutter/material.dart';

import '../assets/ui.dart';

class DropdownMenuCustom extends StatelessWidget {
  const DropdownMenuCustom({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
    required this.items,
    this.isCollapsed = false,
    this.contentPadding
  }) : super(key: key);

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final bool isCollapsed;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
      dropdownColor: UIConstants.GREY_LIGHT,
      borderRadius: BorderRadius.circular(15),
      decoration: InputDecoration(
        isCollapsed: isCollapsed,
        contentPadding: contentPadding,
        enabledBorder: UIConstants.FIELD_BORDER,
        disabledBorder: UIConstants.FIELD_BORDER,
        focusedBorder: UIConstants.FIELD_BORDER,
        labelText: label,
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
