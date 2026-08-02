import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge_widget.dart';
import 'admin_form_viewer_screen.dart';

/// Screen for admin to review citizen applications.
class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key});

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  String _selectedFilter = 'All';
  bool _isSelectMode = false;
  Set<String> _selectedIds = {};

  static const _filters = ['All', 'NID Registration', 'Citizenship', 'Birth Registration', 'Passport'];

  Future<void> _deleteSelected() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Forms'),
        content: Text('Are you sure you want to delete ${_selectedIds.length} forms?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close confirm dialog
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                final ids = Set<String>.from(_selectedIds);
                for (String id in ids) {
                  // Soft delete — hidden from UI but kept in database
                  await FirebaseFirestore.instance.collection('applications').doc(id).update({'isHidden': true});
                }
                if (!mounted) return;
                Navigator.pop(context); // close loading
                setState(() {
                  _isSelectMode = false;
                  _selectedIds.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forms removed successfully'), backgroundColor: Colors.green)
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context); // close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 6))
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_isSelectMode) {
                              setState(() {
                                _isSelectMode = false;
                                _selectedIds.clear();
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(_isSelectMode ? Icons.close : Icons.arrow_back_ios_new_rounded, color: AppColors.navy),
                        ),
                        const SizedBox(width: 8),
                        Text(_isSelectMode ? '${_selectedIds.length} Selected' : 'Review Applications',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
                      ],
                    ),
                    if (_isSelectMode && _selectedIds.isNotEmpty)
                      IconButton(
                        onPressed: _deleteSelected,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _filters.map((f) {
                      final selected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f, style: TextStyle(
                            fontSize: 12,
                            color: selected ? Colors.white : AppColors.navy,
                            fontWeight: FontWeight.w600,
                          )),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedFilter = f),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.navy,
                          checkmarkColor: Colors.white,
                          side: BorderSide(color: AppColors.navy.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      // Filter out soft-deleted (hidden) and apply type filter
                      final visibleDocs = allDocs.where((d) {
                        final app = d.data() as Map<String, dynamic>;
                        return app['isHidden'] != true;
                      }).toList();
                      // Sort by createdAt descending in memory
                      visibleDocs.sort((a, b) {
                        final aTs = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                        final bTs = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                        if (aTs == null && bTs == null) return 0;
                        if (aTs == null) return 1;
                        if (bTs == null) return -1;
                        return bTs.compareTo(aTs);
                      });
                      final applications = _selectedFilter == 'All'
                          ? visibleDocs
                          : visibleDocs.where((d) {
                              final app = d.data() as Map<String, dynamic>;
                              return (app['type'] ?? '') == _selectedFilter;
                            }).toList();

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

                      return Column(
                        children: [
                          if (_isSelectMode)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (_selectedIds.length == applications.length) {
                                          _selectedIds.clear();
                                          _isSelectMode = false;
                                        } else {
                                          _selectedIds.addAll(applications.map((d) => d.id));
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      _selectedIds.length == applications.length ? Icons.deselect : Icons.select_all,
                                      color: AppColors.navy,
                                    ),
                                    label: Text(
                                      _selectedIds.length == applications.length ? 'Deselect All' : 'Select All',
                                      style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: applications.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                          final doc = applications[index];
                          final app = doc.data() as Map<String, dynamic>;

                          return InkWell(
                            onLongPress: () {
                              if (!_isSelectMode) {
                                setState(() {
                                  _isSelectMode = true;
                                  _selectedIds.add(doc.id);
                                });
                              }
                            },
                            onTap: () {
                              if (_isSelectMode) {
                                setState(() {
                                  if (_selectedIds.contains(doc.id)) {
                                    _selectedIds.remove(doc.id);
                                    if (_selectedIds.isEmpty) {
                                      _isSelectMode = false;
                                    }
                                  } else {
                                    _selectedIds.add(doc.id);
                                  }
                                });
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminFormViewerScreen(
                                      applicationId: doc.id,
                                      applicantName: app['applicant'] ?? 'Unknown',
                                      applicationType: app['type'] ?? app['title'] ?? 'Unknown',
                                      status: app['status'] ?? 'Pending',
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedIds.contains(doc.id) ? Colors.red.withOpacity(0.05) : Colors.white,
                                border: Border.all(color: _selectedIds.contains(doc.id) ? Colors.red : Colors.transparent),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: AppColors.navy.withOpacity(0.07),
                                      blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (_isSelectMode) ...[
                                    Icon(
                                      _selectedIds.contains(doc.id) ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: _selectedIds.contains(doc.id) ? Colors.red : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.navy.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_typeIcon(app['type'] ?? ''),
                                        color: AppColors.navy, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(app['title'] ?? app['type'] ?? '',
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
                      ),
                    ),
                  ],
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'NID Registration': return Icons.credit_card;
      case 'Citizenship': return Icons.account_balance;
      case 'Birth Registration': return Icons.child_care;
      case 'Passport': return Icons.book_outlined;
      default: return Icons.description_outlined;
    }
  }
}
