import 'package:flutter/material.dart';

import '../assets/ui.dart';

PreferredSizeWidget searchField(
  BuildContext context,
  Function(String) onChanged, {
  EdgeInsets padding = const EdgeInsets.only(left: 16, right: 16, bottom: 16),
  String initValue = '',
  String label = 'Search',

}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 64),
    child: Padding(
      padding: padding,
      child: SizedBox(
        height: 46,
        child: TextField(
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: UIConstants.WHITE_LIGHT),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: UIConstants.SEARCH_BAR_COLOR,
            labelText: label,
            labelStyle: Theme.of(context).textTheme.bodyMedium,
            enabledBorder: UIConstants.FIELD_BORDER,
            focusedBorder: UIConstants.FIELD_BORDER,
          ),
        ),
      ),
    ),
  );
}
