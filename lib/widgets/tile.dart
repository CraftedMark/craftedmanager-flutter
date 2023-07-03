import 'package:flutter/material.dart';

import '../assets/ui.dart';

class Tile extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsets margin;
  const Tile(
      {Key? key,
      required this.child,
      this.height,
      this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 8)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      height: height,
      decoration: BoxDecoration(
        color: UIConstants.GREY_MEDIUM,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
