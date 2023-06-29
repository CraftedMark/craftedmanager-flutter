import 'package:flutter/material.dart';

import '../assets/ui.dart';

class PlusButton extends StatelessWidget {
  final VoidCallback onPress;
  const PlusButton({Key? key, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 35,
      height: 35,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: UIConstants.ORDER_TILE_BLUE,
        ),
        onPressed: onPress,
        child: const Icon(Icons.add, size: 20, color: Colors.white),
      ),
    );
  }
}
