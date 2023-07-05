import 'package:flutter/material.dart';

import '../assets/ui.dart';
import 'big_button.dart';

class EditProductParamsAlert extends StatelessWidget {
  const EditProductParamsAlert({
    Key? key,
    required this.title,
    required this.children,
    required this.rightButton
  }) : super(key: key);

  final String title;
  final List<Widget> children;
  final BigButton rightButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: UIConstants.BACKGROUND_COLOR,
      title: Text(title),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
      actions: [
        Row(
          children: [
            Flexible(
              child: BigButton(
                text: 'Cancel',
                color: UIConstants.GREY,
                onPressed: () {Navigator.pop(context);},
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: rightButton,
            ),
          ],
        )
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}
