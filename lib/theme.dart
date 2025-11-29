import 'package:flutter/material.dart';

const Color mainThemeColor = Colors.blueAccent;

extension ExtendedThemeData on ColorScheme {
  Color get primaryBase => mainThemeColor;
}
