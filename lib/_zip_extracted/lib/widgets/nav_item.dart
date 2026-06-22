import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const NavItem({super.key, required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? AppColors.teal : AppColors.navy.withOpacity(0.45),
          size: 24,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AppColors.teal : AppColors.navy.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}