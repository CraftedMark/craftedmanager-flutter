import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/copy_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderIdField extends StatefulWidget {
  final String orderId;
  TextStyle? style;
  OrderIdField({Key? key, required this.orderId, this.style}) : super(key: key);

  @override
  State<OrderIdField> createState() => _OrderIdFieldState();
}

class _OrderIdFieldState extends State<OrderIdField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order ID:', style: widget.style),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.orderId,
              style: widget.style?.copyWith(color: UIConstants.WHITE_LIGHT) ??
                  const TextStyle(color: UIConstants.WHITE_LIGHT),
            ),
            CopyToClipboardButton(data: widget.orderId),
          ],
        ),
      ],
    );
  }
}
