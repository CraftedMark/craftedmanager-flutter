import 'package:flutter/material.dart';

import '../assets/ui.dart';

class TextInputField extends StatelessWidget {
  const TextInputField({
    Key? key,
    this.initialValue,
    required this.labelText,
    this.onChange,
    this.controller,
    this.enabled = false,
    this.keyboardType = TextInputType.text
  }) : super(key: key);

  final String labelText;
  final String? initialValue;
  final bool enabled;
  final Function(String)? onChange;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        focusedBorder: UIConstants.FIELD_BORDER,
        disabledBorder: UIConstants.FIELD_BORDER,
        enabledBorder: UIConstants.FIELD_BORDER,
        filled: true,
        fillColor: UIConstants.GREY_LIGHT,
        labelText: labelText,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: UIConstants.WHITE_LIGHT),
      // enabled: false,
      initialValue: controller == null? initialValue: null,
      onChanged: onChange,
    );
  }
}
