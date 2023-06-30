import 'package:flutter/material.dart';

import '../assets/ui.dart';

class GreyScrollablePanel extends StatelessWidget {
  const GreyScrollablePanel({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const BoxDecoration(
          color: UIConstants.GREY_MEDIUM,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: child,
      ),
    );
  }
}
