import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onViewed;

  const NotificationsScreen({super.key, this.onViewed});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _allNotices = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription? _generalSub;
  StreamSubscription? _userSub;

  List<Map<String, dynamic>> _generalNotices = [];
  List<Map<String, dynamic>> _userNotices = [];

  bool _isSelectionMode = false;
  Set<String> _selectedNotices = {};

  Future<void> _deleteSelected() async {
    // Citizens can only delete personal (user) notifications
    final deletable = _selectedNotices.where((id) {
      final notice = _allNotices.firstWhere((n) => n['id'] == id, orElse: () => {});
      return notice.isNotEmpty && notice['isPersonal'] == true;
    }).toList();

    if (deletable.isEmpty) {
      setState(() { _isSelectionMode = false; _selectedNotices.clear(); });
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final id in deletable) {
      batch.delete(FirebaseFirestore.instance.collection('user_notifications').doc(id));
    }
    try {
      await batch.commit();
      setState(() { _isSelectionMode = false; _selectedNotices.clear(); });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete notifications.')));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onViewed?.call();
    });

    _subscribeToNotices();
  }

  void _subscribeToNotices() {
    final user = FirebaseAuth.instance.currentUser;

    _generalSub = FirebaseFirestore.instance
        .collection('general_notices')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _generalNotices = snapshot.docs.map((d) {
        final data = d.data();
        data['isPersonal'] = false;
        data['id'] = d.id;
        return data;
      }).toList();
      _mergeAndSortNotices();
    }, onError: (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    });

    if (user != null) {
      _userSub = FirebaseFirestore.instance
          .collection('user_notifications')
          .where('citizenId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        _userNotices = snapshot.docs.map((d) {
          final data = d.data();
          data['isPersonal'] = true;
          data['id'] = d.id;
          return data;
        }).toList();
        _mergeAndSortNotices();
      }, onError: (e) {
        setState(() { _error = e.toString(); _isLoading = false; });
      });
    }
  }

  void _mergeAndSortNotices() {
    final combined = [..._generalNotices, ..._userNotices];
    combined.sort((a, b) {
      final tsA = (a['postedAt'] ?? a['timestamp']) as Timestamp?;
      final tsB = (b['postedAt'] ?? b['timestamp']) as Timestamp?;
      if (tsA == null && tsB == null) return 0;
      if (tsA == null) return 1;
      if (tsB == null) return -1;
      return tsB.compareTo(tsA);
    });

    if (mounted) {
      setState(() {
        _allNotices = combined;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _generalSub?.cancel();
    _userSub?.cancel();
    super.dispose();
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

  void _showNoticeDetail(BuildContext context, String title, String message, String date, bool isPersonal) {
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
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isPersonal ? Colors.blue.withOpacity(0.12) : AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPersonal ? Icons.person_outline : Icons.campaign_outlined,
                    color: isPersonal ? Colors.blue : AppColors.navy, size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(date, style: TextStyle(fontSize: 12, color: AppColors.navy.withOpacity(0.4))),
            const SizedBox(height: 12),
            Divider(color: AppColors.navy.withOpacity(0.1)),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.navy.withOpacity(0.75))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        Row(
          children: [
            Expanded(
              child: Text(
                _isSelectionMode ? '${_selectedNotices.length} Selected' : 'Notifications',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy),
              ),
            ),
            if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.checklist, color: AppColors.teal),
                onPressed: () {
                  setState(() {
                    _selectedNotices.addAll(_allNotices.map((n) => n['id'] as String));
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (_selectedNotices.isEmpty) return;
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Selected'),
                      content: Text('Are you sure you want to delete ${_selectedNotices.length} notifications?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deleteSelected();
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.navy),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedNotices.clear();
                }),
              ),
            ],
          ],
        ),
        if (!_isSelectionMode) ...[
          const SizedBox(height: 4),
          const Text(
            'General announcements and personal updates',
            style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w500),
          ),
        ],
        const SizedBox(height: 20),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _allNotices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 72, color: AppColors.navy.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text('No new notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.navy.withOpacity(0.4))),
                              const SizedBox(height: 6),
                              Text('Admin announcements will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.navy.withOpacity(0.3))),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _allNotices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final data = _allNotices[index];
                            final ts = data['postedAt'] as Timestamp?;
                            final date = ts != null ? _formatDate(ts.toDate()) : 'Just now';
                            final title = data['title'] ?? 'Notice';
                            final message = data['message'] ?? '';
                            final isPersonal = data['isPersonal'] ?? false;

                            final isSelected = _selectedNotices.contains(data['id']);

                            return GestureDetector(
                              onTap: () {
                                if (_isSelectionMode) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedNotices.remove(data['id']);
                                      if (_selectedNotices.isEmpty) _isSelectionMode = false;
                                    } else {
                                      _selectedNotices.add(data['id']);
                                    }
                                  });
                                } else {
                                  _showNoticeDetail(context, title, message, date, isPersonal);
                                }
                              },
                              onLongPress: () {
                                // Only personal notifications can be deleted by citizen
                                if (!_isSelectionMode && isPersonal) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedNotices.add(data['id']);
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.navy.withOpacity(0.05) : (isPersonal ? Colors.blue.withOpacity(0.06) : AppColors.teal.withOpacity(0.06)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.navy : (isPersonal ? Colors.blue.withOpacity(0.3) : AppColors.teal.withOpacity(0.3)),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: AppColors.navy.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
                                  ],
                                ),
                               child: Row(
                                  children: [
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: AppColors.navy, size: 22)
                                    else
                                      Icon(isPersonal ? Icons.person_outline : Icons.campaign_outlined, color: isPersonal ? Colors.blue : AppColors.navy, size: 28),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
                                          const SizedBox(height: 2),
                                          Text(date, style: TextStyle(fontSize: 12, color: AppColors.navy.withOpacity(0.5))),
                                        ],
                                      ),
                                    ),
                                    if (_isSelectionMode && !isPersonal)
                                      Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 16)
                                    else
                                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.teal, size: 14),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
