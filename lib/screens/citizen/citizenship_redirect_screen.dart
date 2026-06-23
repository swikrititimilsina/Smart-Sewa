// lib/screens/citizen/citizenship_redirect_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'citizenship_apply_screen.dart';

class CitizenshipRedirectScreen extends StatelessWidget {
  const CitizenshipRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'नागरिकता सेवा / Citizenship',
          style: TextStyle(color: Colors.white, fontSize: 16),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
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
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'नागरिकता प्रमाण-पत्र',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Citizenship Certificate Services',
                          style: TextStyle(
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
            _SectionLabel(
              icon: Icons.upload_file_outlined,
              title: 'Upload Documents',
              subtitle: 'आफ्नो कागजातहरू अपलोड गर्नुहोस्',
            ),
            const SizedBox(height: 10),
            _UploadDocumentCard(context: context),

            const SizedBox(height: 28),

            // ── Apply Section ────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.edit_document,
              title: 'Apply',
              subtitle: 'नयाँ आवेदन दिनुहोस्',
            ),
            const SizedBox(height: 10),
            _ApplyOptionsCard(context: context),

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

// ── Upload documents card ──────────────────────────────────────────────────
class _UploadDocumentCard extends StatelessWidget {
  final BuildContext context;
  const _UploadDocumentCard({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _UploadDocTile(
            icon: Icons.badge_outlined,
            title: 'नागरिकताको प्रमाणपत्र',
            subtitle: 'Citizenship Certificate',
            onTap: () => _showUploadSnackbar(context, 'Citizenship Certificate'),
          ),
          const Divider(height: 1, indent: 56),
          _UploadDocTile(
            icon: Icons.people_outline,
            title: 'बाबु / आमाको नागरिकता',
            subtitle: "Parent's Citizenship",
            onTap: () =>
                _showUploadSnackbar(context, "Parent's Citizenship"),
          ),
          const Divider(height: 1, indent: 56),
          _UploadDocTile(
            icon: Icons.calendar_today_outlined,
            title: 'जन्मदर्ता प्रमाणपत्र',
            subtitle: 'Birth Certificate',
            onTap: () => _showUploadSnackbar(context, 'Birth Certificate'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _showUploadSnackbar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📎 $name upload — coming soon'),
        backgroundColor: AppColors.navy,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

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
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(0),
        bottom: widget.isLast ? const Radius.circular(14) : Radius.zero,
      ),
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
              child: Icon(widget.icon,
                  color: AppColors.navy, size: 18),
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
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _uploaded
                  ? const Icon(Icons.check_circle,
                      key: ValueKey('done'),
                      color: AppColors.teal,
                      size: 22)
                  : Container(
                      key: const ValueKey('upload'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.navy),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.upload,
                              size: 12, color: AppColors.navy),
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

// ── Apply options card ─────────────────────────────────────────────────────
class _ApplyOptionsCard extends StatelessWidget {
  final BuildContext context;
  const _ApplyOptionsCard({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _ApplyTile(
            icon: Icons.article_outlined,
            title: 'नागरिकता',
            subtitle: 'Citizenship',
            formType: CitizenshipFormType.citizenship,
          ),
          const Divider(height: 1, indent: 56),
          _ApplyTile(
            icon: Icons.drive_file_rename_outline,
            title: 'नागरिकताको सक्कल नक्कल (थर परिवर्तन)',
            subtitle: 'Copy of Original — Surname Change',
            formType: CitizenshipFormType.surnameChange,
          ),
          const Divider(height: 1, indent: 56),
          _ApplyTile(
            icon: Icons.swap_horiz_rounded,
            title: 'बसाइसराई',
            subtitle: 'Migration',
            formType: CitizenshipFormType.migration,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ApplyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final CitizenshipFormType formType;
  final bool isLast;

  const _ApplyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.formType,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CitizenshipApplyScreen(formType: formType),
          ),
        );
      },
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
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Green apply button
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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