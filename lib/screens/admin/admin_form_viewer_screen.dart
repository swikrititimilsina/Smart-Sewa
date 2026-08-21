import 'package:flutter/material.dart';
import 'dart:convert' as dart_convert;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  DateTime? _biometricDate;
  bool _isLoading = true;

  bool get _needsBiometric {
    final t = widget.applicationType;
    return t == 'NID Registration' || t == 'Passport' || t == 'Citizenship';
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  Future<void> _pickBiometricDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _biometricDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.navy,
            onPrimary: Colors.white,
            secondary: AppColors.teal,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _biometricDate = picked);
    }
  }


  Future<void> _updateStatus(String newStatus) async {
    try {
      final appRef = FirebaseFirestore.instance
          .collection('applications')
          .doc(widget.applicationId);
      final appDoc = await appRef.get();

      final updateData = <String, dynamic>{'status': newStatus};
      if (newStatus == 'Approved' && _biometricDate != null) {
        updateData['biometricDate'] = Timestamp.fromDate(_biometricDate!);
      }

      await appRef.update(updateData);

      if (appDoc.exists) {
        final data = appDoc.data() as Map<String, dynamic>;
        final citizenId = data['citizenId'] ?? data['userId'];
        if (citizenId != null) {
          String message =
              'Your ${widget.applicationType} application is now $newStatus.';

          // Biometric date notification — only on Processing, only for relevant forms
          if (newStatus == 'Processing' && _biometricDate != null && _needsBiometric) {
            final formatted =
                DateFormat('EEEE, MMMM d, yyyy').format(_biometricDate!);
            message +=
                '\n\n📅 Your biometric appointment is scheduled for: $formatted. Please visit the office with your original documents.';
          }

          // Collect card message — on Approved for ALL form types
          if (newStatus == 'Approved') {
            message +=
                '\n\n🏢 Your card is ready for collection. Please visit the District Administration Office during office hours with your original documents to collect it.';
          }

          await FirebaseFirestore.instance
              .collection('user_notifications')
              .add({
            'citizenId': citizenId,
            'title': newStatus == 'Approved'
                ? '✅ Application Approved'
                : 'Application Update',
            'message': message,
            'postedAt': FieldValue.serverTimestamp(),
            if (newStatus == 'Processing' && _biometricDate != null && _needsBiometric)
              'biometricDate': Timestamp.fromDate(_biometricDate!),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
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
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
                child: Text('Could not load application data.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final formData = Map<String, dynamic>.from(data['formData'] ?? {});
          final attachedDocumentBase64 =
              data['attachedDocumentBase64'] as String?;
          final paymentProofBase64 = data['paymentProofBase64'] as String?;
          final paymentStatus = data['paymentStatus'] as String?;
          final paymentAmount = data['paymentAmount'];

          // Load existing biometric date from Firestore if set
          if (_biometricDate == null && data['biometricDate'] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _biometricDate =
                      (data['biometricDate'] as Timestamp).toDate();
                });
              }
            });
          }

          return Column(
            children: [
              Expanded(
                child: _buildFormPreview(
                    formData, attachedDocumentBase64, paymentProofBase64,
                    paymentStatus: paymentStatus,
                    paymentAmount: paymentAmount),
              ),
              _buildActionBar(),
            ],
          );
        },
      ),
    );
  }

  // ── Build the read-only form based on application type ──────────────────
  Widget _buildFormPreview(
    Map<String, dynamic> formData,
    String? attachedDocumentBase64,
    String? paymentProofBase64, {
    String? paymentStatus,
    dynamic paymentAmount,
  }) {
    final formWidget = _buildFormWidget(formData, attachedDocumentBase64);
    
    // If there's a payment proof, we need to show it alongside the form
    if (paymentProofBase64 != null || paymentStatus != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            // Payment proof card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: paymentStatus == 'Paid'
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          paymentStatus == 'Paid'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: paymentStatus == 'Paid'
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Payment: ${paymentStatus ?? 'Unknown'} ${paymentAmount != null ? '— NPR $paymentAmount' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: paymentStatus == 'Paid'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (paymentProofBase64 != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Screenshot (uploaded by applicant):',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _viewFullImage(
                            context, paymentProofBase64, 'Payment Proof'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            dart_convert.base64Decode(paymentProofBase64),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap to view full image',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Form content
            SizedBox(
              height: 600,
              child: formWidget,
            ),
          ],
        ),
      );
    }

    return formWidget;
  }

  Widget _buildFormWidget(
      Map<String, dynamic> formData, String? attachedDocumentBase64) {
    switch (widget.applicationType) {
      case 'NID Registration':
        return NIDFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            attachedDocumentBase64: attachedDocumentBase64);
      case 'Citizenship':
        return CitizenshipFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            attachedDocumentBase64: attachedDocumentBase64);
      case 'Copy of Original — Surname Change':
        return CitizenshipFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            formType: CitizenshipFormType.surnameChange,
            attachedDocumentBase64: attachedDocumentBase64);
      case 'Migration':
        return CitizenshipFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            formType: CitizenshipFormType.migration,
            attachedDocumentBase64: attachedDocumentBase64);
      case 'Birth Registration':
        return BirthFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            attachedDocumentBase64: attachedDocumentBase64);
      case 'Passport':
        return PassportFormScreen(
            readOnly: true,
            initialData: formData,
            asSubView: true,
            attachedDocumentBase64: attachedDocumentBase64);
      default:
        return SingleChildScrollView(
            child: _buildGenericPreview(formData, attachedDocumentBase64));
    }
  }

  void _viewFullImage(BuildContext context, String base64, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(dart_convert.base64Decode(base64),
                  fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    if (widget.isCitizenMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Biometric date picker — only for NID, Passport, Citizenship
          // Hidden once status is Approved (no longer needed)
          // Locked (read-only) once status is Processing (already set)
          if (_needsBiometric && _currentStatus != 'Approved') ...[
            Row(
              children: [
                Icon(Icons.fingerprint,
                    color: _currentStatus == 'Processing'
                        ? Colors.grey
                        : AppColors.navy,
                    size: 20),
                const SizedBox(width: 8),
                Text('Biometric Date:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _currentStatus == 'Processing'
                            ? Colors.grey
                            : AppColors.navy)),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    // Disabled once Processing — biometric date is already locked in
                    onTap: _currentStatus == 'Processing'
                        ? null
                        : _pickBiometricDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentStatus == 'Processing'
                            ? Colors.grey.shade100
                            : _biometricDate != null
                                ? AppColors.teal.withOpacity(0.1)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _currentStatus == 'Processing'
                              ? Colors.grey.shade300
                              : _biometricDate != null
                                  ? AppColors.teal
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _currentStatus == 'Processing'
                                ? Icons.lock_outline
                                : Icons.calendar_month_outlined,
                            size: 16,
                            color: _currentStatus == 'Processing'
                                ? Colors.grey
                                : _biometricDate != null
                                    ? AppColors.teal
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _biometricDate != null
                                  ? '${DateFormat('MMM d, yyyy').format(_biometricDate!)}${_currentStatus == 'Processing' ? ' (locked)' : ''}'
                                  : _currentStatus == 'Processing'
                                      ? 'No date set'
                                      : 'Tap to select date',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: _currentStatus == 'Processing'
                                    ? Colors.grey
                                    : _biometricDate != null
                                        ? AppColors.teal
                                        : Colors.grey,
                                fontWeight: _biometricDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],


          // Status update row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Update Status:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.navy)),
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

          if (_needsBiometric && _biometricDate != null) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Citizen will be notified with biometric date: ${DateFormat('MMMM d, yyyy').format(_biometricDate!)}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenericPreview(
      Map<String, dynamic> data, String? attachedDocumentBase64) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.entries
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('${e.key}: ${e.value}'),
                  ))
              .toList(),
          if (attachedDocumentBase64 != null) ...[
            const SizedBox(height: 20),
            const Text('Attached Document:',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
