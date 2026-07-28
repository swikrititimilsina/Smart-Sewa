import 'package:flutter/material.dart';
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

  const AdminFormViewerScreen({
    super.key,
    required this.applicationId,
    required this.applicantName,
    required this.applicationType,
    required this.status,
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
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId)
          .update({'status': newStatus});
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

          return Column(
            children: [
              Expanded(
                child: _buildFormPreview(formData),
              ),
              _buildActionBar(),
            ],
          );
        },
      ),
    );
  }

  // ── Build the read-only form based on application type ──────────────────
  Widget _buildFormPreview(Map<String, dynamic> formData) {
    switch (widget.applicationType) {
      case 'NID Registration':
        return NIDFormScreen(readOnly: true, initialData: formData, asSubView: true);
      case 'Citizenship':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true);
      case 'Copy of Original — Surname Change':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true, formType: CitizenshipFormType.surnameChange);
      case 'Migration':
        return CitizenshipFormScreen(readOnly: true, initialData: formData, asSubView: true, formType: CitizenshipFormType.migration);
      case 'Birth Registration':
        return BirthFormScreen(readOnly: true, initialData: formData, asSubView: true);
      case 'Passport':
        return PassportFormScreen(readOnly: true, initialData: formData, asSubView: true);
      default:
        return SingleChildScrollView(child: _buildGenericPreview(formData));
    }
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
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

  Widget _buildGenericPreview(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(': '),
        )).toList(),
      ),
    );
  }
}
