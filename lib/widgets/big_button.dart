import 'package:flutter/material.dart';

import '../assets/ui.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: UIConstants.WHITE),
        ),
      ),
    );
  }
}
