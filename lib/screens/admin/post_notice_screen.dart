import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class PostNoticeScreen extends StatefulWidget {
  const PostNoticeScreen({super.key});

  @override
  State<PostNoticeScreen> createState() => _PostNoticeScreenState();
}

class _PostNoticeScreenState extends State<PostNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _postNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    try {
      await FirebaseFirestore.instance.collection('general_notices').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'postedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Clear the form
        _titleController.clear();
        _messageController.clear();

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Notice broadcasted to all citizens!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppColors.teal,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post notice: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.navy),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Broadcast Notice',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        Text('Send announcement to all citizens',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.teal,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Info Banner ──
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.teal.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign_outlined,
                                  color: AppColors.teal, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This notice will be visible to ALL registered citizens immediately.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.navy.withOpacity(0.8),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Title Field ──
                        const Text('Notice Title',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'e.g., Public Holiday Announcement',
                            hintStyle: TextStyle(
                                color: AppColors.navy.withOpacity(0.35),
                                fontSize: 14),
                            prefixIcon: const Icon(
                                Icons.title_rounded,
                                color: AppColors.teal),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.teal, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Please enter a title'
                                  : null,
                        ),

                        const SizedBox(height: 20),

                        // ── Message Field ──
                        const Text('Notice Message',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText:
                                'Type your full announcement here...',
                            hintStyle: TextStyle(
                                color: AppColors.navy.withOpacity(0.35),
                                fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.teal, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Please enter the notice message'
                                  : null,
                        ),

                        const SizedBox(height: 32),

                        // ── Submit Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isPosting ? null : _postNotice,
                            icon: _isPosting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white),
                            label: Text(
                              _isPosting
                                  ? 'Broadcasting...'
                                  : 'Broadcast Notice',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              disabledBackgroundColor:
                                  AppColors.navy.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Previous Notices ──
                        const Text('Previously Sent Notices',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                        const SizedBox(height: 12),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('general_notices')
                              .orderBy('postedAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.teal));
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 24),
                                  child: Text('No notices sent yet.',
                                      style: TextStyle(
                                          color:
                                              AppColors.navy.withOpacity(0.4))),
                                ),
                              );
                            }

                            final docs = snapshot.data!.docs;
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final data =
                                    docs[i].data() as Map<String, dynamic>;
                                final ts =
                                    data['postedAt'] as Timestamp?;
                                final date = ts != null
                                    ? _formatDate(ts.toDate())
                                    : 'Just now';

                                return GestureDetector(
                                  onLongPress: () async {
                                    final docId = docs[i].id;
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        title: const Text(
                                          'Remove Notice',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.navy),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this notice? It will be removed for all citizens.',
                                          style: TextStyle(
                                              color: AppColors.navy,
                                              fontSize: 14),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel',
                                                style: TextStyle(
                                                    color: AppColors.teal,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            ),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('general_notices')
                                          .doc(docId)
                                          .delete();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.campaign_outlined,
                                                size: 16,
                                                color: AppColors.teal),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                data['title'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: AppColors.navy),
                                              ),
                                            ),
                                            Text(date,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.navy
                                                        .withOpacity(0.4))),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          data['message'] ?? '',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.navy
                                                  .withOpacity(0.6)),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Long press to remove',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.navy
                                                  .withOpacity(0.25),
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
