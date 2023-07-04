import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EditButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 28,
      icon: const Icon(Icons.edit, color: Colors.white),
      onPressed: onPressed,
    );
  }
}
