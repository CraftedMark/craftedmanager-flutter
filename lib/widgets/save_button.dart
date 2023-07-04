import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: const Icon(Icons.save, color: Colors.white),
        splashRadius: 28,
        onPressed: onPressed,
      ),
    );
  }
}
