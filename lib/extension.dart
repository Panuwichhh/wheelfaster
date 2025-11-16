import 'package:flutter/material.dart';

extension Themeblackwhite on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get onText => isDark ? const Color.fromARGB(255, 197, 197, 197) : Colors.black;
  Color get onBackground => isDark ? const Color.fromARGB(255, 8, 20, 11) : Colors.white;
  Color get pureOn => isDark ? const Color.fromARGB(255, 255, 255, 255) : Colors.black;
}