import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyToClipboardButton extends StatefulWidget {
  const CopyToClipboardButton({Key? key, required this.data}) : super(key: key);

  final String data;

  @override
  State<CopyToClipboardButton> createState() => _CopyToClipboardButtonState();
}

class _CopyToClipboardButtonState extends State<CopyToClipboardButton> {

  Future<void> onCopyButtonTap() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        'Copied to clipboard',
        style: TextStyle(color: Colors.white),
      ),
    ));
    await Clipboard.setData(ClipboardData(text: widget.data));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onCopyButtonTap,
      child: const Icon(Icons.copy, size: 20),
    );
  }
}
