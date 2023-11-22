import 'package:flutter/material.dart';

abstract class ThemeColor {
  // This constructor prevents instantiation and extension.
  ThemeColor._();

  // Main Theme Colors

  static const Color primaryDarkBlueColor = Color(0xff255aaa);
  static const Color primaryBlueColor = Color(0xff82d0fa);

  static const Color blackThemeColor = Color(0xff3c4a5f);
  static const Color greyThemeColor = Color(0xffc2cad7);
  static const Color backgroundLightBlueThemeColor = Color(0xffeff4f7);

  // Events
  static const Color success = Color(0xff81f9bf);
  static const Color warning = Color(0xfff9f871);
  static const Color error = Color(0xfff38f91);

  // 15 Shades of grey

  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightest = Color(0xffE9F0F7);
  static const Color lighter = Color.fromRGBO(217, 230, 247, 1);
  static const Color light = Color.fromRGBO(187, 200, 217, 1);
  static const Color lightGrey = Color.fromRGBO(157, 170, 187, 1);
  static const Color grey = Color.fromRGBO(127, 140, 157, 1);
  static const Color darkGrey = Color.fromRGBO(97, 110, 127, 1);
  static const Color dark = Color.fromRGBO(67, 80, 97, 1);
  static const Color darker = Color.fromRGBO(37, 50, 67, 1);
  static const Color darkest = Color.fromRGBO(7, 20, 37, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);

  // Disabled
  static Color disabledColor = light.withOpacity(0.95);
  static Color disabledFontColor = darkGrey.withOpacity(0.5);
  static const Color disabledIcon = Color(0xff9E9E9E);
  static const Color borderGrey = Color(0xffc1c9d6);
}
