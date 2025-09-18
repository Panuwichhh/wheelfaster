import 'package:flutter/material.dart';

extension Themeblackwhite on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get pureOnText => isDark ? Colors.white : Colors.black;
  Color get pureOnBackground => isDark ? Colors.black : Colors.white;
}