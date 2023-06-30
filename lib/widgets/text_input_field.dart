import 'package:flutter/material.dart';

import '../assets/ui.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    Key? key,
    required this.initialValue,
    required this.labelText,
    this.onChange,
  }) : super(key: key);

  final String labelText;
  final String initialValue;
  final Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        disabledBorder: UIConstants.FIELD_BORDER,
        enabledBorder: UIConstants.FIELD_BORDER,
        filled: true,
        fillColor: UIConstants.GREY_LIGHT,
        labelText: labelText,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
      // enabled: false,
      initialValue: initialValue,
      onChanged: onChange,
    );
  }
}
