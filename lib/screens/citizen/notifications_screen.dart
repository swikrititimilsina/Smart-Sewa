import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  /// Called when this tab is opened so the parent can reset the badge count.
  final VoidCallback? onViewed;

  const NotificationsScreen({super.key, this.onViewed});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Tell parent the tab was opened → reset badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onViewed?.call();
    });
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showNoticeDetail(BuildContext context, String title, String message, String date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon + title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.campaign_outlined,
                      color: AppColors.navy, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date
            Text(
              date,
              style: TextStyle(
                  fontSize: 12, color: AppColors.navy.withOpacity(0.4)),
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(color: AppColors.navy.withOpacity(0.1)),
            const SizedBox(height: 12),

            // Full message
            Text(
              message,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.navy.withOpacity(0.75)),
            ),
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'General announcements from admin',
          style: TextStyle(
              fontSize: 13,
              color: AppColors.teal,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),

        // ── Real-time stream from Firestore ──
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('general_notices')
                .orderBy('postedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 64, color: AppColors.navy.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('Could not load notifications.',
                          style: TextStyle(
                              color: AppColors.navy.withOpacity(0.4),
                              fontSize: 15)),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 72,
                          color: AppColors.navy.withOpacity(0.2)),
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
                        'Admin announcements will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.navy.withOpacity(0.3)),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final ts = data['postedAt'] as Timestamp?;
                  final date = ts != null
                      ? _formatDate(ts.toDate())
                      : 'Just now';
                  final title = data['title'] ?? 'Notice';
                  final message = data['message'] ?? '';

                  // ── Collapsed Card: only title + date visible ──
                  return GestureDetector(
                    onTap: () =>
                        _showNoticeDetail(context, title, message, date),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.teal.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.campaign_outlined,
                                color: AppColors.navy, size: 22),
                          ),
                          const SizedBox(width: 12),

                          // Title + date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  date,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.navy.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          ),

                          // Tap hint arrow
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.navy.withOpacity(0.3)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
