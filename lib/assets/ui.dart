import 'package:flutter/material.dart';

class UIConstants {
  UIConstants._();
  static const BACKGROUND_COLOR = Color(0xff181A20);
  static const TEXT_COLOR = Color(0xff707487);
  static const TEXT_FIELD_COLOR = Color(0xff262A34);
  static const ICON_COLOR = Color.fromARGB(255, 108, 112, 131);
  static const DIVIDER_COLOR = Color(0xff383B45);

  static const WHITE = Colors.white;
  static const WHITE_LIGHT = Colors.white70;

  static const GREY = Color(0xff383B45);
  static const GREY_MEDIUM = Color(0xff1F222A);
  static const GREY_LIGHT = Color(0xff262A34);
  static const GREY_BORDER = Color(0xff333642);

  static const BLUE = Color(0xff246BFE);
  static const GREEN = Color(0xff3DA74E);
  static const ORANGE = Color(0xffEFAF4B);
  static const RED = Colors.red;

  static InputBorder FIELD_BORDER = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: UIConstants.GREY_BORDER),
  );
}