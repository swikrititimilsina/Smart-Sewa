import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge_widget.dart';

/// Screen for admin to review citizen applications.
class ApplicationReviewScreen extends StatelessWidget {
  const ApplicationReviewScreen({super.key});

  // TODO: populate from backend once connected
  static const List<Map<String, dynamic>> _applications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
                    ),
                    const SizedBox(width: 8),
                    const Text('Review Applications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _applications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_outlined,
                                  size: 72, color: AppColors.navy.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text('No applications to review',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                      color: AppColors.navy.withOpacity(0.4))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _applications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final app = _applications[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: AppColors.navy.withOpacity(0.07),
                                      blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(app['title'] ?? '',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                                        const SizedBox(height: 4),
                                        Text(app['applicant'] ?? '',
                                            style: TextStyle(fontSize: 12, color: AppColors.navy.withOpacity(0.6))),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: app['status'] ?? 'Pending'),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
