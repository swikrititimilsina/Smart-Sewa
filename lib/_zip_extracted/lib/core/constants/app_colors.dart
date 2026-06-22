import 'package:flutter/material.dart';

class AppColors {
  static const bgStart = Color(0xFF8EC5C0);
  static const bgEnd   = Color(0xFFB5D5A8);
  static const navy    = Color(0xFF1A3A5C);
  static const teal    = Color(0xFF1A7A7A);
  static const green   = Color(0xFF3DAA5C);
  static const white   = Colors.white;

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgStart, Color(0xFF9ECFCA), bgEnd],
  );
}