import 'package:flutter/material.dart';

import '../assets/ui.dart';

class VerticalDividerCustom extends StatelessWidget {
  const VerticalDividerCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(color: UIConstants.DIVIDER_COLOR);
  }
}
