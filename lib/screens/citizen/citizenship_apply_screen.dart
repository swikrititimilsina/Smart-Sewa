// lib/screens/citizen/citizenship_apply_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'citizenship_form_screen.dart';

// ── Form type enum ─────────────────────────────────────────────────────────
enum CitizenshipFormType {
  citizenship,
  surnameChange,
  migration,
}

extension CitizenshipFormTypeX on CitizenshipFormType {
  String get nepaliLabel {
    switch (this) {
      case CitizenshipFormType.citizenship:
        return 'नागरिकता';
      case CitizenshipFormType.surnameChange:
        return 'नागरिकताको सक्कल नक्कल\n(थर परिवर्तन)';
      case CitizenshipFormType.migration:
        return 'बसाइसराई';
    }
  }

  String get englishLabel {
    switch (this) {
      case CitizenshipFormType.citizenship:
        return 'Citizenship';
      case CitizenshipFormType.surnameChange:
        return 'Copy of Original — Surname Change';
      case CitizenshipFormType.migration:
        return 'Migration';
    }
  }

  String get appBarTitle {
    switch (this) {
      case CitizenshipFormType.citizenship:
        return 'नागरिकता आवेदन';
      case CitizenshipFormType.surnameChange:
        return 'थर परिवर्तन / नक्कल';
      case CitizenshipFormType.migration:
        return 'बसाइसराई आवेदन';
    }
  }

  IconData get icon {
    switch (this) {
      case CitizenshipFormType.citizenship:
        return Icons.article_outlined;
      case CitizenshipFormType.surnameChange:
        return Icons.drive_file_rename_outline;
      case CitizenshipFormType.migration:
        return Icons.swap_horiz_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case CitizenshipFormType.citizenship:
        return const Color(0xFF27ae60);
      case CitizenshipFormType.surnameChange:
        return const Color(0xFF2980b9);
      case CitizenshipFormType.migration:
        return const Color(0xFF8e44ad);
    }
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────
class CitizenshipApplyScreen extends StatelessWidget {
  final CitizenshipFormType formType;

  const CitizenshipApplyScreen({super.key, required this.formType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(
          formType.appBarTitle,
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
            // ── Header banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    formType.accentColor,
                    formType.accentColor.withOpacity(0.7),
                  ],
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(formType.icon,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formType.nepaliLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formType.englishLabel,
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

            // ── Info note ──────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade700, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'फाराम भर्नु अघि सबै आवश्यक कागजातहरू तयार राख्नुहोस् ।\n'
                      'Please have all required documents ready before filling the form.',
                      style:
                          TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Form options ────────────────────────────────────────────
            const Text(
              'आवेदन फाराम / Application Form',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1a3c6e),
              ),
            ),
            const SizedBox(height: 10),

            _FormOptionCard(formType: formType),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Form option card ───────────────────────────────────────────────────────
class _FormOptionCard extends StatelessWidget {
  final CitizenshipFormType formType;
  const _FormOptionCard({required this.formType});

  String get _formDescription {
    switch (formType) {
      case CitizenshipFormType.citizenship:
        return 'नेपाली नागरिकताको प्रमाण-पत्रको लागि निवेदन फाराम (अनुसूची-१)।\n'
            'Application form for Nepali citizenship certificate (Schedule-1).';
      case CitizenshipFormType.surnameChange:
        return 'नागरिकता प्रमाण-पत्रमा थर परिवर्तन वा सक्कल नक्कलको लागि निवेदन।\n'
            'Application for surname change or copy of original citizenship.';
      case CitizenshipFormType.migration:
        return 'बसाइसराईको कारण नागरिकता अद्यावधिक गर्न निवेदन फाराम।\n'
            'Application to update citizenship records due to migration.';
    }
  }

  List<_RequiredDoc> get _requiredDocs {
    switch (formType) {
      case CitizenshipFormType.citizenship:
        return const [
          _RequiredDoc('नागरिकताको सिफारिस', 'VDC/Municipality Recommendation'),
          _RequiredDoc('बाबु/आमाको नागरिकता', "Parent's Citizenship"),
          _RequiredDoc('जन्मदर्ता प्रमाणपत्र', 'Birth Certificate'),
        ];
      case CitizenshipFormType.surnameChange:
        return const [
          _RequiredDoc('विवाह दर्ता प्रमाणपत्र', 'Marriage Certificate'),
          _RequiredDoc('पुरानो नागरिकताको प्रतिलिपि', 'Old Citizenship Copy'),
          _RequiredDoc('पतिको नागरिकता', "Husband's Citizenship"),
        ];
      case CitizenshipFormType.migration:
        return const [
          _RequiredDoc('बसाइसराई प्रमाणपत्र', 'Migration Certificate'),
          _RequiredDoc('पुरानो नागरिकताको प्रतिलिपि', 'Old Citizenship Copy'),
          _RequiredDoc('नयाँ ठेगानाको सिफारिस', 'New Address Recommendation'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              _formDescription,
              style: const TextStyle(
                  fontSize: 12, color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Required docs
            const Text(
              'आवश्यक कागजातहरू / Required Documents:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1a3c6e),
              ),
            ),
            const SizedBox(height: 8),
            ..._requiredDocs.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle,
                          size: 6,
                          color: Color(0xFF1a3c6e)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: d.nepali,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1a3c6e),
                                ),
                              ),
                              TextSpan(
                                text: ' — ${d.english}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CitizenshipFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded,
                    color: Colors.white, size: 18),
                label: const Text(
                  'फाराम भर्नुहोस् / Fill Form',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27ae60),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequiredDoc {
  final String nepali;
  final String english;
  const _RequiredDoc(this.nepali, this.english);
}