// lib/widgets/passport_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Color constants ───────────────────────────────────────────────────────────
const Color kGovBlue    = Color(0xFF1a3c6e);
const Color kNepalRed   = Color(0xFFBF0000);
const Color kBgRoot     = Color(0xFFF0F4FA);
const Color kBgCard     = Color(0xFFFFFFFF);
const Color kBgSection  = Color(0xFFE8EEF6);
const Color kBgOffice   = Color(0xFFFFF9E6);
const Color kBorderColor = Color(0xFFBBCCDD);
const Color kTextMuted  = Color(0xFF777777);
const Color kTextDark   = Color(0xFF222222);
const Color kTextMid    = Color(0xFF444444);
const Color kTextLight  = Color(0xFF888888);
const Color kEntryBg    = Color(0xFFFAFCFF);

// ── Passport section title ────────────────────────────────────────────────────
class PassportSectionTitle extends StatelessWidget {
  final String title;
  const PassportSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kBgSection,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: kGovBlue,
        ),
      ),
    );
  }
}

// ── Generic labeled text field ────────────────────────────────────────────────
class PassportField extends StatelessWidget {
  final String label;
  final double width;
  final String? defaultValue;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PassportField({
    super.key,
    required this.label,
    required this.width,
    this.defaultValue,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: kGovBlue),
          ),
          const SizedBox(height: 2),
          TextFormField(
            initialValue: defaultValue,
            maxLength: maxLength,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: kBorderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kBorderColor),
              ),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              counterText: '',
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Name sub-field (for Given Names row) ──────────────────────────────────────
class NameSubField extends StatelessWidget {
  final String nepLabel;
  final String engLabel;
  final int flex;

  const NameSubField({
    super.key,
    required this.nepLabel,
    required this.engLabel,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nepLabel / $engLabel',
            style: const TextStyle(fontSize: 10, color: kGovBlue),
          ),
          const SizedBox(height: 2),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor)),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Checkbox row item ─────────────────────────────────────────────────────────
class PassportCheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const PassportCheckItem({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: kGovBlue,
        ),
        Text(label,
            style: const TextStyle(fontSize: 12, color: kTextDark)),
      ],
    );
  }
}

// ── Radio row item ────────────────────────────────────────────────────────────
class PassportRadioItem<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const PassportRadioItem({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: kGovBlue,
        ),
        Text(label,
            style: const TextStyle(fontSize: 12, color: kTextDark)),
      ],
    );
  }
}

// ── Photo placeholder box ─────────────────────────────────────────────────────
class PhotoPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final String label;

  const PhotoPlaceholder({
    super.key,
    this.width = 100,
    this.height = 120,
    this.label = 'Photo',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor, width: 1.5),
        color: kBgSection,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: kGovBlue, size: 36),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kTextMuted)),
        ],
      ),
    );
  }
}

// ── Section divider ───────────────────────────────────────────────────────────
class PassportDivider extends StatelessWidget {
  const PassportDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: kBorderColor, height: 1),
    );
  }
}
