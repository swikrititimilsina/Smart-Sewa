import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LogoBadge extends StatelessWidget {
  final double size;
  const LogoBadge({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.navy.withOpacity(0.15), width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}