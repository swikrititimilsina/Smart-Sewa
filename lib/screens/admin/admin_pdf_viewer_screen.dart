import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class AdminPdfViewerScreen extends StatefulWidget {
  final String applicationId;
  final String pdfBase64;
  final String applicantName;
  final String status;
  final String? applicationType;

  const AdminPdfViewerScreen({
    super.key,
    required this.applicationId,
    required this.pdfBase64,
    required this.applicantName,
    required this.status,
    this.applicationType,
  });

  @override
  State<AdminPdfViewerScreen> createState() => _AdminPdfViewerScreenState();
}

class _AdminPdfViewerScreenState extends State<AdminPdfViewerScreen> {
  bool _isVerifying = false;
  late String _currentStatus;
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _verifyApplication() async {
    setState(() => _isVerifying = true);
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .update({'status': 'Verified'});

      setState(() {
        _currentStatus = 'Verified';
        _isVerifying = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Application verified successfully!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfBytes = base64Decode(widget.pdfBase64);

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2E),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.applicantName,
              style: const TextStyle(
                  fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStatus == 'Verified'
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
                Text(
                  _currentStatus == 'Verified'
                      ? 'Verified'
                      : 'Pending Review',
                  style: TextStyle(
                    fontSize: 11,
                    color: _currentStatus == 'Verified'
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.applicationType != null) ...[
                  const Text('  ·  ',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                  Text(widget.applicationType!,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11)),
                ]
              ],
            ),
          ],
        ),
        actions: [
          if (_currentStatus != 'Verified')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyApplication,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.verified_outlined, size: 18),
                label: const Text('Verify',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 4),
                  const Text('Verified',
                      style: TextStyle(
                          color: Colors.greenAccent, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),

      // ── Page counter bar ──
      bottomNavigationBar: _totalPages > 0
          ? Container(
              color: AppColors.navy,
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prev
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white70),
                      onPressed: _currentPage > 1
                          ? () => _pdfController.previousPage()
                          : null,
                    ),
                    // Page label
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    // Next
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: Colors.white70),
                      onPressed: _currentPage < _totalPages
                          ? () => _pdfController.nextPage()
                          : null,
                    ),
                  ],
                ),
              ),
            )
          : null,

      body: SfPdfViewer.memory(
        pdfBytes,
        controller: _pdfController,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        scrollDirection: PdfScrollDirection.vertical,
        onDocumentLoaded: (details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (details) {
          setState(() => _currentPage = details.newPageNumber);
        },
      ),
    );
  }
}
