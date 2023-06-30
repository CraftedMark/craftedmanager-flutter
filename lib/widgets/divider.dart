import 'package:flutter/material.dart';

import '../assets/ui.dart';

class DividerCustom extends StatelessWidget {
  const DividerCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(color: UIConstants.DIVIDER_COLOR);
  }
}
