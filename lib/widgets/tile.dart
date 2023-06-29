import 'package:flutter/material.dart';

import '../assets/ui.dart';

class Tile extends StatelessWidget {
  final Widget child;
  final double height;
  const Tile({Key? key, required this.child, this.height = 160}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        height: height,
        decoration: BoxDecoration(
          color: UIConstants.GREY_MEDIUM_COLOR,
          borderRadius: BorderRadius.circular(15),
        ),
        child: child,
    );
  }
}
