// lib/screens/citizen/passport_payment_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../services/form_draft_service.dart';

class PassportPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final String? attachedDocumentBase64;

  const PassportPaymentScreen({
    super.key,
    required this.formData,
    this.attachedDocumentBase64,
  });

  @override
  State<PassportPaymentScreen> createState() => _PassportPaymentScreenState();
}

class _PassportPaymentScreenState extends State<PassportPaymentScreen> {
  String? _paymentProofBase64;
  bool _isSubmitting = false;

  Future<void> _pickPaymentProof() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _paymentProofBase64 = base64Encode(bytes);
    });
  }

  Future<void> _submitApplication() async {
    if (_paymentProofBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your payment screenshot first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      final formData = Map<String, dynamic>.from(widget.formData);

      final appData = {
        'applicant':
            '${formData['firstName_eng'] ?? ''} ${formData['lastName_eng'] ?? ''}'
                .trim()
                .isNotEmpty
            ? '${formData['firstName_eng'] ?? ''} ${formData['lastName_eng'] ?? ''}'
            : 'Applicant',
        'citizenId': user.uid,
        'title': 'Passport',
        'type': 'Passport',
        'status': 'Pending',
        'formData': formData,
        'paymentProofBase64': _paymentProofBase64,
        'paymentStatus': 'Paid',
                'paymentAmount': 5000,
        'createdAt': FieldValue.serverTimestamp(),
        'isHidden': false,
        if (widget.attachedDocumentBase64 != null)
          'attachedDocumentBase64': widget.attachedDocumentBase64,
      };

      // Save uploaded documents to user's global documents collection
      final docTypes = {
        'doc_citizenship': 'Passport: Citizenship',
        'doc_parents_citizenship': 'Passport: Parent Citizenship',
        'doc_marriage_certificate': 'Passport: Marriage Certificate',
      };

      final batch = FirebaseFirestore.instance.batch();
      final userDocsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('documents');

      for (final entry in docTypes.entries) {
        if (formData[entry.key] != null &&
            formData[entry.key].toString().isNotEmpty) {
          final docRef = userDocsRef.doc(entry.key);
          batch.set(docRef, {
            'title': entry.value,
            'base64': formData[entry.key],
            'uploadedAt': FieldValue.serverTimestamp(),
            'type': entry.key,
          });
        }
      }

      await batch.commit();
      await FirebaseFirestore.instance.collection('applications').add(appData);
      FormDraftService.clearDraft('passport');

      if (mounted) {
        // Pop the loading indicator if showing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Passport application submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Pop back to home (pop payment screen + form screen)
        Navigator.of(context)
          ..pop() // payment screen
          ..pop(); // passport form screen
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
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
        title: const Text(
          'Payment / भुक्तानी',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Passport Application Fee',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'NPR 5000',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'राहदानी आवेदन शुल्क',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Instructions ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Instructions',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy),
                  ),
                  SizedBox(height: 12),
                  _StepItem(
                      step: '1',
                      text: 'Scan the QR code below using your eSewa, Khalti, or bank app.'),
                  SizedBox(height: 8),
                  _StepItem(
                      step: '2',
                      text: 'Send exactly NPR 5000 as the passport application fee.'),
                  SizedBox(height: 8),
                  _StepItem(
                      step: '3',
                      text: 'Take a clear screenshot of the payment confirmation.'),
                  SizedBox(height: 8),
                  _StepItem(
                      step: '4',
                      text: 'Upload the screenshot below and tap "Submit Application".'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── QR Code ─────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Scan to Pay',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'स्क्यान गरेर भुक्तानी गर्नुहोस्',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/qr.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Amount: NPR 5000',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Upload payment proof ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Payment Screenshot',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'भुक्तानी स्क्रिनसट अपलोड गर्नुहोस्',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  if (_paymentProofBase64 != null) ...[
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(_paymentProofBase64!),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () => setState(() => _paymentProofBase64 = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickPaymentProof,
                      icon: const Icon(Icons.swap_horiz, color: AppColors.teal),
                      label: const Text('Change Image',
                          style: TextStyle(color: AppColors.teal)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.teal),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: _pickPaymentProof,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.teal.withOpacity(0.4),
                              width: 2,
                              style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.teal, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload screenshot',
                              style: TextStyle(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Payment proof required (NPR 5000)',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Submit button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitApplication,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Application',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _paymentProofBase64 != null
                      ? AppColors.teal
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: _paymentProofBase64 != null ? 4 : 0,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Notice ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please ensure your payment screenshot clearly shows the amount (NPR 5000) and transaction ID. Unclear or invalid receipts may cause delays.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ── Helper widget ─────────────────────────────────────────────────────────────
class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
