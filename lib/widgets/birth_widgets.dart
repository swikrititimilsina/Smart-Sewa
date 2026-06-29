// lib/widgets/birth_widgets.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ── Reusable labeled text field ───────────────────────────────────────────────
class BirthLabeledField extends StatelessWidget {
  final String label;
  final double width;
  final String? hint;
  final bool isExpanded;

  const BirthLabeledField({
    super.key,
    required this.label,
    required this.width,
    this.hint,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );

    if (isExpanded) {
      return Expanded(child: field);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width + (label.isNotEmpty ? 100 : 0)),
      child: field,
    );
  }
}

// ── Date entry row ────────────────────────────────────────────────────────────
class BirthDateEntry extends StatelessWidget {
  final String label;

  const BirthDateEntry({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 6),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final w in [60.0, 50.0, 50.0]) ...[
              SizedBox(
                width: w,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (w != 50.0 || w == 60.0) // Correctly place dashes
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('-', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Nepali name row (नाम, थर, मध्यनाम fields) ──────────────────────────────
class NameRowBirth extends StatelessWidget {
  final String nepLabel;

  const NameRowBirth({super.key, required this.nepLabel});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BirthLabeledField(label: 'थर:', width: 120, isExpanded: true),
        SizedBox(width: 12),
        BirthLabeledField(label: 'नाम:', width: 120, isExpanded: true),
        SizedBox(width: 12),
        BirthLabeledField(label: 'मध्यनाम:', width: 100, isExpanded: true),
      ],
    );
  }
}

// ── English name row ──────────────────────────────────────────────────────────
class NameRowBirthEn extends StatelessWidget {
  const NameRowBirthEn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BirthLabeledField(label: 'Surname:', width: 120, isExpanded: true),
        SizedBox(width: 12),
        BirthLabeledField(label: 'Given Name:', width: 120, isExpanded: true),
        SizedBox(width: 12),
        BirthLabeledField(label: 'Middle Name:', width: 100, isExpanded: true),
      ],
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class BirthCard extends StatelessWidget {
  final String title;
  final Widget child;

  const BirthCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.navy.withOpacity(0.04),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Section divider ───────────────────────────────────────────────────────────
class BirthFormDivider extends StatelessWidget {
  const BirthFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey.shade300, height: 1),
    );
  }
}

