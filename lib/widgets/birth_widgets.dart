// lib/widgets/birth_widgets.dart
import 'package:flutter/material.dart';

// ── Color constants ───────────────────────────────────────────────────────────
const Color kNavyBlue = Color(0xFF1a3c6e);
const Color kAccent   = Color(0xFF27ae60);
const Color kBgMain   = Color(0xFFF0F4FA);
const Color kBgCard   = Color(0xFFFFFFFF);
const Color kBgSec    = Color(0xFFE8EEF6);
const Color kBorder   = Color(0xFFBBCCDD);
const Color kMuted    = Color(0xFF888888);

// ── Reusable labeled text field ───────────────────────────────────────────────
class BirthLabeledField extends StatelessWidget {
  final String label;
  final double width;
  final String? hint;

  const BirthLabeledField({
    super.key,
    required this.label,
    required this.width,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    // Use ConstrainedBox so the field has a preferred width but can shrink
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width + (label.isNotEmpty ? 100 : 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(fontSize: 12, color: kNavyBlue)),
            const SizedBox(height: 2),
          ],
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11, color: kMuted),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: kBorder),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Date entry row ────────────────────────────────────────────────────────────
class BirthDateEntry extends StatelessWidget {
  final String label;

  const BirthDateEntry({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(fontSize: 12, color: kNavyBlue)),
        if (label.isNotEmpty) const SizedBox(width: 4),
        for (final w in [50.0, 40.0, 40.0]) ...[
          SizedBox(
            width: w,
            child: TextFormField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: kBorder)),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (w != 40.0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Text('-', style: TextStyle(fontSize: 12, color: kMuted)),
            ),
        ],
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
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        BirthLabeledField(label: 'थर:', width: 120),
        BirthLabeledField(label: 'नाम:', width: 120),
        BirthLabeledField(label: 'मध्यनाम:', width: 100),
      ],
    );
  }
}

// ── English name row ──────────────────────────────────────────────────────────
class NameRowBirthEn extends StatelessWidget {
  const NameRowBirthEn({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        BirthLabeledField(label: 'Surname:', width: 120),
        BirthLabeledField(label: 'Given Name:', width: 120),
        BirthLabeledField(label: 'Middle Name:', width: 100),
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBgCard,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: kBgSec,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: kNavyBlue,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: kBorder, height: 1),
    );
  }
}
