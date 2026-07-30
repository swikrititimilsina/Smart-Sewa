import 'package:flutter/material.dart';
import 'dart:convert' as dart_convert;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge_widget.dart';

// ─── Widget imports for read-only form rendering ───────────────────────────
import '../citizen/nid_form_screen.dart';
import '../citizen/citizenship_form_screen.dart';
import '../citizen/citizenship_apply_screen.dart';
import '../citizen/birth_reg_form_screen.dart';
import '../citizen/passport_form_screen.dart';


/// Admin screen that fetches formData from Firestore and renders it
/// in readOnly mode using the exact same citizen-side widgets.
class AdminFormViewerScreen extends StatefulWidget {
  final String applicationId;
  final String applicantName;
  final String applicationType;
  final String status;
  final bool isCitizenMode;

  const AdminFormViewerScreen({
    super.key,
    required this.applicationId,
    required this.applicantName,
    required this.applicationType,
    required this.status,
    this.isCitizenMode = false,
  });

  @override
  State<AdminFormViewerScreen> createState() => _AdminFormViewerScreenState();
}

class _AdminFormViewerScreenState extends State<AdminFormViewerScreen> {
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final appRef = FirebaseFirestore.instance.collection('applications').doc(widget.applicationId);
      final appDoc = await appRef.get();
      
      await appRef.update({'status': newStatus});
      
      if (appDoc.exists) {
        final data = appDoc.data() as Map<String, dynamic>;
        final citizenId = data['citizenId'] ?? data['userId'];
        if (citizenId != null) {
          await FirebaseFirestore.instance.collection('user_notifications').add({
            'citizenId': citizenId,
            'title': 'Application Update',
            'message': 'Your ${widget.applicationType} application is now $newStatus.',
            'postedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: AppColors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.applicationType,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text(widget.applicantName,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(status: _currentStatus),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('applications')
            .doc(widget.applicationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Could not load application data.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final formData = Map<String, dynamic>.from(data['formData'] ?? {});
          final attachedDocumentBase64 = data['attachedDocumentBase64'] as String?;

          return Column(
            children: [
              Expanded(
                child: _buildFormPreview(formData, attachedDocumentBase64),
              ),
              _buildActionBar(),
            ],
          );
        },
      ),
    );
  }

  // ── Build the read-only form based on application type ──────────────────
  Widget _buildFormPreview(Map<String, dynamic> formData, String? attachedDocumentBase64) {
    switch (widget.applicationType) {
      case 'NID Registration':
        return NIDFormScreen(readOnly: true, initialData: formData, asSubView: true, attachedDocumentBase64: attachedDocumentBase64);
      case 'Citizenship':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true, attachedDocumentBase64: attachedDocumentBase64);
      case 'Copy of Original — Surname Change':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true, formType: CitizenshipFormType.surnameChange, attachedDocumentBase64: attachedDocumentBase64);
      case 'Migration':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true, formType: CitizenshipFormType.migration, attachedDocumentBase64: attachedDocumentBase64);
      case 'Birth Registration':
        return BirthFormScreen(readOnly: true, initialData: formData, asSubView: true, attachedDocumentBase64: attachedDocumentBase64);
      case 'Passport':
        return PassportFormScreen(readOnly: true, initialData: formData, asSubView: true, attachedDocumentBase64: attachedDocumentBase64);
      default:
        return SingleChildScrollView(child: _buildGenericPreview(formData, attachedDocumentBase64));
    }
  }

  Widget _buildActionBar() {
    return widget.isCitizenMode ? const SizedBox.shrink() : Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _currentStatus,
            items: ['Pending', 'Processing', 'Approved', 'Rejected']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) {
              if (val != null && val != _currentStatus) {
                _updateStatus(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenericPreview(Map<String, dynamic> data, String? attachedDocumentBase64) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('${e.key}: ${e.value}'),
          )).toList(),
          if (attachedDocumentBase64 != null) ...[
            const SizedBox(height: 20),
            const Text('Attached Document:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  dart_convert.base64Decode(attachedDocumentBase64),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
