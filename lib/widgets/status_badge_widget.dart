import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A reusable badge widget for showing status (e.g. Verified, Pending, etc.).
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color _statusColor() {
    switch (status) {
      case 'Verified': return Colors.green;
      case 'Pending':  return Colors.orange;
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default:         return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusColor(),
        ),
      ),
    );
  }
}
