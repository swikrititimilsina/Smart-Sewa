import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'passport_form_screen.dart';
import 'birth_reg_form_screen.dart' show BirthFormScreen;
import 'nid_form_screen.dart'; // From sample

enum ServiceType {
  nid('National Identity Card (NID)', 'राष्ट्रिय परिचयपत्र', Icons.credit_card_rounded),
  passport('Passport Services', 'राहदानी सेवा', Icons.language_rounded),
  birthReg('Birth Registration', 'जन्म दर्ता', Icons.child_care_rounded);

  final String titleEn;
  final String titleNp;
  final IconData icon;

  const ServiceType(this.titleEn, this.titleNp, this.icon);
}

class GenericRedirectScreen extends StatelessWidget {
  final ServiceType serviceType;

  const GenericRedirectScreen({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(
          '${serviceType.titleNp} / ${serviceType.titleEn}',
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
                      serviceType.icon,
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
                          serviceType.titleNp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          serviceType.titleEn,
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
              child: _UploadDocTile(
                icon: Icons.badge_outlined,
                title: serviceType.titleNp,
                subtitle: serviceType.titleEn,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📎 ${serviceType.titleEn} upload — coming soon'),
                      backgroundColor: AppColors.navy,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                isLast: true,
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
                title: serviceType.titleNp,
                subtitle: serviceType.titleEn,
                isLast: true,
                onTap: () {
                  if (serviceType == ServiceType.nid) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const NIDFormScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else if (serviceType == ServiceType.passport) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PassportFormScreen()));
                  } else if (serviceType == ServiceType.birthReg) {
                    Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const BirthFormScreen(),
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

// ── Upload tile widget ─────────────────────────────────────────────────────
class _UploadDocTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _UploadDocTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  State<_UploadDocTile> createState() => _UploadDocTileState();
}

class _UploadDocTileState extends State<_UploadDocTile> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _uploaded = !_uploaded);
        if (!_uploaded) widget.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: AppColors.navy, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _uploaded
                  ? const Icon(Icons.check_circle,
                      key: ValueKey('done'), color: AppColors.teal, size: 22)
                  : Container(
                      key: const ValueKey('upload'),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.navy),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upload, size: 12, color: AppColors.navy),
                          SizedBox(width: 4),
                          Text('Upload',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.navy,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
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
