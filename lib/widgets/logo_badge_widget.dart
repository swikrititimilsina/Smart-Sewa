import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.account_balance, size: size * 0.5, color: AppColors.navy);
          },
        ),
      ),
    );
  }
}
