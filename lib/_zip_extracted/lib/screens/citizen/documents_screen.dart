import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  // TODO: populate from backend once frontend-backend-db are connected
  static const List<Map<String, dynamic>> _documents = [];

  Color _statusColor(String status) {
    switch (status) {
      case 'Verified': return Colors.green;
      case 'Pending':  return Colors.orange;
      default:         return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDocuments = _documents.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'My Documents',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        const SizedBox(height: 4),
        const Text(
          'All your registered documents',
          style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: hasDocuments
              ? ListView.separated(
                  itemCount: _documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(doc['icon'] as IconData,
                                color: AppColors.navy, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['title'] as String,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doc['subtitle'] as String,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.navy.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(doc['status'] as String)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              doc['status'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(doc['status'] as String),
                              ),
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
                      Icon(Icons.folder_off_outlined,
                          size: 72, color: AppColors.navy.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'No documents yet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy.withOpacity(0.4)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your registered documents will appear here.',
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