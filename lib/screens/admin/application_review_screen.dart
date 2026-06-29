import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge_widget.dart';
import 'admin_pdf_viewer_screen.dart';

/// Screen for admin to review citizen applications.
class ApplicationReviewScreen extends StatelessWidget {
  const ApplicationReviewScreen({super.key});

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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final applications = snapshot.data?.docs ?? [];

                      if (applications.isEmpty) {
                        return Center(
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
                        );
                      }

                      return ListView.separated(
                        itemCount: applications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = applications[index];
                          final app = doc.data() as Map<String, dynamic>;
                          
                          return InkWell(
                            onTap: () {
                              if (app['pdfBase64'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminPdfViewerScreen(
                                      applicationId: doc.id,
                                      pdfBase64: app['pdfBase64'],
                                      applicantName: app['applicant'] ?? 'Unknown',
                                      status: app['status'] ?? 'Pending',
                                      applicationType: app['type'] ?? app['title'],
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No PDF available for this application')),
                                );
                              }
                            },
                            child: Container(
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
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
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
            ),
          ),
        ),
      ),
    );
  }
}
