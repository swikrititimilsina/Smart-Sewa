import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import 'passport_form_screen.dart';
import 'birth_reg_form_screen.dart' show BirthFormScreen;
import 'nid_form_screen.dart';
import '../../widgets/base64_upload_widget.dart';
import '../../services/form_draft_service.dart';

enum ServiceType {
  nid('National Identity Card (NID)', 'राष्ट्रिय परिचयपत्र', Icons.credit_card_rounded),
  passport('Passport Services', 'राहदानी सेवा', Icons.language_rounded),
  birthReg('Birth Registration', 'जन्म दर्ता', Icons.child_care_rounded);

  final String titleEn;
  final String titleNp;
  final IconData icon;

  const ServiceType(this.titleEn, this.titleNp, this.icon);
}

class GenericRedirectScreen extends StatefulWidget {
  final ServiceType serviceType;

  const GenericRedirectScreen({super.key, required this.serviceType});

  @override
  State<GenericRedirectScreen> createState() => _GenericRedirectScreenState();
}

class _GenericRedirectScreenState extends State<GenericRedirectScreen> {
  String? _attachedDocumentBase64;

  @override
  void initState() {
    super.initState();
    final draft = FormDraftService.getDraft('redirect_${widget.serviceType.name}');
    if (draft != null) {
      _attachedDocumentBase64 = draft['doc'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(
          '${widget.serviceType.titleNp} / ${widget.serviceType.titleEn}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.serviceType.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceType.titleNp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.serviceType.titleEn,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Upload Documents Section ─────────────────────────────────
            const _SectionLabel(
              icon: Icons.upload_file_outlined,
              title: 'Upload Documents',
              subtitle: 'आफ्नो कागजातहरू अपलोड गर्नुहोस्',
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Base64UploadWidget(
                icon: Icons.badge_outlined,
                title: widget.serviceType.titleNp,
                subtitle: widget.serviceType.titleEn,
                initialBase64: _attachedDocumentBase64,
                onImageChanged: (base64Str) async {
                  setState(() {
                    _attachedDocumentBase64 = base64Str;
                  });
                  if (base64Str != null) {
                    FormDraftService.saveDraft('redirect_${widget.serviceType.name}', {'doc': base64Str});
                    
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('documents')
                            .add({
                          'title': '${widget.serviceType.titleEn} Existing Document',
                          'base64': base64Str,
                          'uploadedAt': FieldValue.serverTimestamp(),
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document saved to My Documents'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error saving doc: $e');
                      }
                    }
                  } else {
                    FormDraftService.clearDraft('redirect_${widget.serviceType.name}');
                  }
                },
              ),
            ),

            const SizedBox(height: 28),

            // ── Apply Section ────────────────────────────────────────────
            const _SectionLabel(
              icon: Icons.edit_document,
              title: 'Apply',
              subtitle: 'नयाँ आवेदन दिनुहोस्',
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _ApplyTile(
                icon: Icons.article_outlined,
                title: widget.serviceType.titleNp,
                subtitle: widget.serviceType.titleEn,
                isLast: true,
                onTap: () {
                  if (widget.serviceType == ServiceType.nid) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => NIDFormScreen(attachedDocumentBase64: _attachedDocumentBase64),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else if (widget.serviceType == ServiceType.passport) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PassportFormScreen(attachedDocumentBase64: _attachedDocumentBase64)));
                  } else if (widget.serviceType == ServiceType.birthReg) {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => BirthFormScreen(attachedDocumentBase64: _attachedDocumentBase64),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ));
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Section label widget ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.navy, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


// ── Apply tile widget ──────────────────────────────────────────────────────
class _ApplyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _ApplyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.teal, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
