import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

class ViewReportsScreen extends StatefulWidget {
  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  String _filterStatus = 'All';
  String _filterCategory = 'All';

  final List<String> _statusFilters = ['All', 'open', 'resolved'];
  final List<String> _categoryFilters = [
    'All', 'App Crashing', 'Document Upload Failed', 'Payment Issue',
    'Login / Authentication Problem', 'Notification Not Working',
    'Application Status Error', 'Slow Performance', 'Other',
  ];

  bool _isSelectionMode = false;
  Set<String> _selectedReports = {};
  List<String> _visibleDocIds = [];

  Future<void> _deleteSelected() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedReports) {
      batch.delete(FirebaseFirestore.instance.collection('problem_reports').doc(id));
    }
    await batch.commit();
    setState(() {
      _isSelectionMode = false;
      _selectedReports.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected reports deleted')));
    }
  }

  Future<void> _toggleStatus(String docId, String currentStatus, Map<String, dynamic> data) async {
    final newStatus = currentStatus == 'open' ? 'resolved' : 'open';
    await FirebaseFirestore.instance.collection('problem_reports').doc(docId).update({'status': newStatus});

    // Notify citizen if marked as resolved
    if (newStatus == 'resolved' && data['citizenId'] != null) {
      await FirebaseFirestore.instance.collection('user_notifications').add({
        'citizenId': data['citizenId'],
        'title': 'Issue Resolved',
        'message': 'Your issue that you have submitted ("${data['category'] ?? 'Issue'}") has been resolved.',
        'postedAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  void _viewScreenshot(BuildContext context, String base64Str) {
    final Uint8List bytes = base64Decode(base64Str);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedReports.length} Selected' : 'Citizen Reports', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedReports.clear();
                }),
              )
            : null,
        actions: _isSelectionMode
            ? [
                TextButton.icon(
                  icon: const Icon(Icons.select_all, color: Colors.white, size: 18),
                  label: const Text('Select All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    setState(() {
                      _selectedReports.addAll(_visibleDocIds);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    if (_selectedReports.isEmpty) return;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Selected'),
                        content: Text('Are you sure you want to delete ${_selectedReports.length} reports?'),
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
              ]
            : null,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: AppColors.navy.withOpacity(0.05),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter by Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _statusFilters.map((s) {
                      final selected = _filterStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.navy, fontWeight: FontWeight.w600)),
                          selected: selected,
                          selectedColor: AppColors.navy,
                          backgroundColor: Colors.white,
                          onSelected: (_) => setState(() => _filterStatus = s),
                          side: BorderSide(color: AppColors.navy.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Filter by Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categoryFilters.map((c) {
                      final selected = _filterCategory == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.navy, fontWeight: FontWeight.w600)),
                          selected: selected,
                          selectedColor: AppColors.teal,
                          backgroundColor: Colors.white,
                          onSelected: (_) => setState(() => _filterCategory = c),
                          side: BorderSide(color: AppColors.teal.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Reports list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('problem_reports')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                var docs = snapshot.data?.docs ?? [];

                // Apply filters
                if (_filterStatus != 'All') {
                  docs = docs.where((d) => (d.data() as Map)['status'] == _filterStatus).toList();
                }
                if (_filterCategory != 'All') {
                  docs = docs.where((d) => (d.data() as Map)['category'] == _filterCategory).toList();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _visibleDocIds = docs.map((d) => d.id).toList();
                    // Clean up selection if reports were deleted externally
                    _selectedReports.removeWhere((id) => !_visibleDocIds.contains(id));
                    if (_selectedReports.isEmpty && _isSelectionMode) {
                      setState(() => _isSelectionMode = false);
                    }
                  }
                });

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No reports found', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'open';
                    final isOpen = status == 'open';
                    final ts = data['createdAt'] as Timestamp?;
                    final dateStr = ts != null
                        ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
                        : 'Unknown date';
                    final hasScreenshot = data['screenshotBase64'] != null &&
                        (data['screenshotBase64'] as String).isNotEmpty;

                    final isSelected = _selectedReports.contains(doc.id);

                    return GestureDetector(
                      onTap: () {
                        if (_isSelectionMode) {
                          setState(() {
                            if (isSelected) {
                              _selectedReports.remove(doc.id);
                              if (_selectedReports.isEmpty) _isSelectionMode = false;
                            } else {
                              _selectedReports.add(doc.id);
                            }
                          });
                        }
                      },
                      onLongPress: () {
                        if (!_isSelectionMode) {
                          setState(() {
                            _isSelectionMode = true;
                            _selectedReports.add(doc.id);
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.navy.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.navy 
                              : (isOpen ? Colors.orange.withOpacity(0.4) : Colors.green.withOpacity(0.4)),
                          width: isSelected ? 2.0 : 1.5,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.orange.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: Row(
                              children: [
                                Icon(isOpen ? Icons.error_outline : Icons.check_circle_outline,
                                    color: isOpen ? Colors.orange : Colors.green, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['category'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? Colors.orange.shade800 : Colors.green.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOpen ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isOpen ? 'Open' : 'Resolved',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Body
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Citizen info
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${data['citizenName'] ?? 'Unknown'} • ${data['citizenEmail'] ?? ''}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Description
                                Text(
                                  data['description'] ?? '',
                                  style: const TextStyle(fontSize: 14, color: AppColors.navy, height: 1.5),
                                ),

                                // Screenshot
                                if (hasScreenshot) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _viewScreenshot(context, data['screenshotBase64']),
                                    child: Container(
                                      height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.memory(
                                              base64Decode(data['screenshotBase64']),
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color: Colors.black.withOpacity(0.3),
                                              child: const Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.zoom_in, color: Colors.white, size: 20),
                                                    SizedBox(width: 6),
                                                    Text('Tap to view screenshot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 12),
                                // Action button
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _toggleStatus(doc.id, status, data),
                                    icon: Icon(
                                      isOpen ? Icons.check_circle_outline : Icons.replay,
                                      size: 16,
                                      color: isOpen ? Colors.green : Colors.orange,
                                    ),
                                    label: Text(
                                      isOpen ? 'Mark as Resolved' : 'Reopen Issue',
                                      style: TextStyle(color: isOpen ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: isOpen ? Colors.green : Colors.orange),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ), // Close Column
                    ), // Close Container
                    ); // Close GestureDetector
                  }, // Close builder
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
