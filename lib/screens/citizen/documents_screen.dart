import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge_widget.dart';
import '../admin/admin_form_viewer_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isSelectMode = false;
  Set<String> _selectedIds = {};

  static const List<Map<String, dynamic>> _documents = [];

  Color _statusColor(String status) {
    switch (status) {
      case 'Verified': return Colors.green;
      case 'Pending':  return Colors.orange;
      default:         return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_isSelectMode) {
        setState(() {
          _isSelectMode = false;
          _selectedIds.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Applications',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        content: Text('Remove ${_selectedIds.length} selected application(s) from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                final ids = Set<String>.from(_selectedIds);
                for (final id in ids) {
                  await FirebaseFirestore.instance
                      .collection('applications')
                      .doc(id)
                      .update({'isHidden': true});
                }
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  _isSelectMode = false;
                  _selectedIds.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Applications removed'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 6)),
                );
              }
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.teal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'My Documents'),
            Tab(text: 'Applications'),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMyDocuments(),
              _buildApplications(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyDocuments() {
    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 72, color: AppColors.navy.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('No documents yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy.withOpacity(0.4))),
            const SizedBox(height: 6),
            Text('Your registered documents will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.3))),
          ],
        ),
      );
    }
    return ListView.separated(
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
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(doc['icon'] as IconData, color: AppColors.navy, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(doc['title'] as String,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  const SizedBox(height: 2),
                  Text(doc['subtitle'] as String,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.navy.withOpacity(0.5))),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(doc['status'] as String).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(doc['status'] as String,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(doc['status'] as String))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view applications.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('citizenId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teal));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.navy.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ),
          );
        }

        final allDocs = snapshot.data?.docs ?? [];
        // Filter hidden, sort newest first
        final sorted = allDocs
            .where((d) => (d.data() as Map<String, dynamic>)['isHidden'] != true)
            .toList();
        sorted.sort((a, b) {
          final aTs = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTs = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTs == null && bTs == null) return 0;
          if (aTs == null) return 1;
          if (bTs == null) return -1;
          return bTs.compareTo(aTs);
        });

        if (sorted.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 72, color: AppColors.navy.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No applications submitted yet',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy.withOpacity(0.4))),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Selection toolbar ──
            if (_isSelectMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            _isSelectMode = false;
                            _selectedIds.clear();
                          }),
                          icon: const Icon(Icons.close, color: AppColors.navy),
                        ),
                        Text('${_selectedIds.length} Selected',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                                fontSize: 16)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              if (_selectedIds.length == sorted.length) {
                                _selectedIds.clear();
                                _isSelectMode = false;
                              } else {
                                _selectedIds.addAll(sorted.map((d) => d.id));
                              }
                            });
                          },
                          icon: Icon(
                            _selectedIds.length == sorted.length
                                ? Icons.deselect
                                : Icons.select_all,
                            color: AppColors.navy,
                          ),
                          label: Text(
                            _selectedIds.length == sorted.length
                                ? 'Deselect All'
                                : 'Select All',
                            style: const TextStyle(
                                color: AppColors.navy, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_selectedIds.isNotEmpty)
                          IconButton(
                            onPressed: _deleteSelected,
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            // ── List ──
            Expanded(
              child: ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = sorted[index];
                  final app = doc.data() as Map<String, dynamic>;
                  final isSelected = _selectedIds.contains(doc.id);

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
                          if (isSelected) {
                            _selectedIds.remove(doc.id);
                            if (_selectedIds.isEmpty) _isSelectMode = false;
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
                              isCitizenMode: true,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
                        border: Border.all(
                            color: isSelected ? Colors.red : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.navy.withOpacity(0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (_isSelectMode) ...[
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: AppColors.navy.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10)),
                            child:
                                Icon(_typeIcon(app['type'] ?? ''), color: AppColors.navy, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app['title'] ?? app['type'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navy)),
                                const SizedBox(height: 4),
                                Text(app['applicant'] ?? '',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.navy.withOpacity(0.6))),
                              ],
                            ),
                          ),
                          StatusBadge(status: app['status'] ?? 'Pending'),
                          const SizedBox(width: 8),
                          if (!_isSelectMode)
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
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'NID Registration':   return Icons.credit_card;
      case 'Citizenship':        return Icons.account_balance;
      case 'Birth Registration': return Icons.child_care;
      case 'Passport':           return Icons.book_outlined;
      default:                   return Icons.description_outlined;
    }
  }
}
