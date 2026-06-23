// lib/widgets/citizenship_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Shared colour tokens ───────────────────────────────────────────────────
const Color kCitAccent = Color(0xFF1a3c6e); // deep government navy
const Color kCitBg = Color(0xFFF5F7FA);
const Color kCitBorder = Color(0xFFB0BEC5);
const Color kCitText = Color(0xFF37474F);

// ── Divider ────────────────────────────────────────────────────────────────
class CitDivider extends StatelessWidget {
  const CitDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(
        color: kCitBorder,
        thickness: 0.6,
        height: 16,
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
      color: kCitAccent,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Inline text field ──────────────────────────────────────────────────────
class CitField extends StatelessWidget {
  final double width;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CitField({
    super.key,
    this.width = 160,
    this.hint,
    this.label,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!,
              style: const TextStyle(fontSize: 11, color: kCitText)),
          const SizedBox(height: 2),
        ],
        SizedBox(
          width: width,
          height: 30,
          child: TextFormField(
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              isDense: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: kCitBorder),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kCitBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: kCitAccent.withOpacity(0.7), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 12, color: kCitText),
          ),
        ),
      ],
    );
  }
}

// ── Label + field row ──────────────────────────────────────────────────────
class CitLabeledRow extends StatelessWidget {
  final String label;
  final Widget field;

  const CitLabeledRow({super.key, required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 4,
        children: [
          SizedBox(
            width: 240,
            child:
                Text(label, style: const TextStyle(fontSize: 12, color: kCitText)),
          ),
          field,
        ],
      ),
    );
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
        _dateBox('DD', 38),
        const Text(' / ', style: TextStyle(fontSize: 12)),
        _dateBox('MM', 38),
        const Text(' / ', style: TextStyle(fontSize: 12)),
        _dateBox('YYYY', 54),
      ],
    );
  }

  Widget _dateBox(String hint, double w) {
    return SizedBox(
      width: w,
      height: 30,
      child: TextFormField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          isDense: true,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: kCitBorder)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: kCitBorder)),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 12),
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
        width: 90,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: _uploaded ? kCitAccent : kCitBorder, width: 1.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: _uploaded
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF27ae60), size: 26),
                  SizedBox(height: 4),
                  Text('Uploaded',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: Color(0xFF27ae60))),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, color: kCitText),
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
  const CitSignaturePad(
      {super.key, this.width = 200, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kCitBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'Tap to sign',
          style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
        ),
      ),
    );
  }
}