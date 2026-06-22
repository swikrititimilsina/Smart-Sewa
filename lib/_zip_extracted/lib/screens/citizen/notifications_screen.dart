import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Populate from backend when real notifications arrive
  static const List<Map<String, dynamic>> _notifications = [];

  @override
  Widget build(BuildContext context) {
    final bool hasNotifications = _notifications.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy),
              ),
            ),
            if (hasNotifications)
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Updates on your applications & services',
          style: TextStyle(
              fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: hasNotifications
              ? ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    final bool isRead = n['read'] as bool;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.white
                            : AppColors.teal.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: isRead
                            ? null
                            : Border.all(
                                color: AppColors.teal.withOpacity(0.3),
                                width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(n['icon'] as IconData,
                                color: AppColors.navy, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isRead
                                              ? FontWeight.w600
                                              : FontWeight.w700,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.teal,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n['body'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.navy.withOpacity(0.55)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n['time'] as String,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.navy.withOpacity(0.35)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 72, color: AppColors.navy.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "You'll be notified when there are updates\non your applications.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.navy.withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}