import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

// ── Shared colour tokens ───────────────────────────────────────────────────
const Color kCitBg = Color(0xFFF0F4FA);

// ── Divider ────────────────────────────────────────────────────────────────
class CitDivider extends StatelessWidget {
  const CitDivider({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          height: 1,
        ),
      );
}

// ── Section header ─────────────────────────────────────────────────────────
class CitSectionHeader extends StatelessWidget {
  final String title;
  const CitSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navy.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Inline text field ──────────────────────────────────────────────────────
class CitField extends StatelessWidget {
  final double? width;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CitField({
    super.key,
    this.width,
    this.hint,
    this.label,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
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
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 13, color: AppColors.navy),
    );

    Widget result = width != null ? SizedBox(width: width, child: field) : field;

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 6),
          result,
        ],
      );
    }
    return result;
  }
}

// ── Label + field row ──────────────────────────────────────────────────────
class CitLabeledRow extends StatelessWidget {
  final String label;
  final Widget field;
  final bool isExpanded;

  const CitLabeledRow({super.key, required this.label, required this.field, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 6),
          SizedBox(width: double.infinity, child: field),
        ],
      ),
    );

    if (isExpanded) {
      return Expanded(child: content);
    }
    return content;
  }
}

// ── Date entry (DD / MM / YYYY) ────────────────────────────────────────────
class CitDateEntry extends StatelessWidget {
  const CitDateEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dateBox('DD', 50),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(' / ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        _dateBox('MM', 50),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(' / ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        _dateBox('YYYY', 70),
      ],
    );
  }

  Widget _dateBox(String hint, double w) {
    return SizedBox(
      width: w,
      child: TextFormField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          isDense: true,
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
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 13, color: AppColors.navy),
      ),
    );
  }
}

// ── Photo upload placeholder ───────────────────────────────────────────────
class CitPhotoUpload extends StatefulWidget {
  final String label;
  const CitPhotoUpload({super.key, required this.label});

  @override
  State<CitPhotoUpload> createState() => _CitPhotoUploadState();
}

class _CitPhotoUploadState extends State<CitPhotoUpload> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _uploaded = !_uploaded),
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: _uploaded ? AppColors.teal : Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _uploaded
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.teal, size: 32),
                  SizedBox(height: 8),
                  Text('Uploaded',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.bold)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.navy, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Signature pad placeholder ──────────────────────────────────────────────
class CitSignaturePad extends StatelessWidget {
  final double width;
  final double height;
  const CitSignaturePad({super.key, this.width = double.infinity, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Tap to sign',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}