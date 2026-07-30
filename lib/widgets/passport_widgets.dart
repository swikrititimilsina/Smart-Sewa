import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

// ── Color constants ───────────────────────────────────────────────────────────
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
      color: AppColors.navy.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
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
  final String? fieldKey;
  final Map<String, dynamic>? dataMap;
  final bool readOnly;
  final String? hintText;

  const PassportField({
    super.key,
    required this.label,
    required this.width,
    this.defaultValue,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.fieldKey,
    this.dataMap,
    this.readOnly = false,
    this.hintText,
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          TextFormField(
            readOnly: readOnly,
            initialValue: (dataMap != null && fieldKey != null) ? (dataMap![fieldKey] ?? defaultValue) : defaultValue,
            onChanged: (val) {
              if (dataMap != null && fieldKey != null) {
                dataMap![fieldKey!] = val;
              }
            },
            maxLength: maxLength,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.navy),
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
  final String? fieldKey;
  final Map<String, dynamic>? dataMap;
  final bool readOnly;

  const NameSubField({
    super.key,
    required this.nepLabel,
    required this.engLabel,
    required this.flex,
    this.fieldKey,
    this.dataMap,
    this.readOnly = false,
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          TextFormField(
            readOnly: readOnly,
            initialValue: (dataMap != null && fieldKey != null) ? dataMap![fieldKey] : null,
            onChanged: (val) {
              if (dataMap != null && fieldKey != null) {
                dataMap![fieldKey!] = val;
              }
            },
            decoration: InputDecoration(
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.navy),
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
          activeColor: AppColors.teal,
        ),
        Text(label,
            style: const TextStyle(fontSize: 13, color: kTextDark)),
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
          activeColor: AppColors.teal,
        ),
        Text(label,
            style: const TextStyle(fontSize: 13, color: kTextDark)),
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
    this.width = 110,
    this.height = 140,
    this.label = 'Photo',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Colors.grey.shade300, height: 1),
    );
  }
}

// ── Generic labeled dropdown field ─────────────────────────────────────────────
class PassportDropdownField extends StatelessWidget {
  final String label;
  final double width;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? fieldKey;
  final Map<String, dynamic>? dataMap;
  final bool readOnly;

  const PassportDropdownField({
    super.key,
    required this.label,
    required this.width,
    required this.items,
    this.value,
    this.onChanged,
    this.fieldKey,
    this.dataMap,
    this.readOnly = false,
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
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: (dataMap != null && fieldKey != null && items.contains(dataMap![fieldKey])) 
                ? dataMap![fieldKey] 
                : items.contains(value) ? value : null,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
              );
            }).toList(),
            onChanged: readOnly ? null : (val) {
              if (dataMap != null && fieldKey != null) {
                dataMap![fieldKey!] = val;
              }
              if (onChanged != null) {
                onChanged!(val);
              }
            },
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
            dropdownColor: Colors.white,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

// ── Generic labeled date picker field ──────────────────────────────────────────
class PassportDateField extends StatefulWidget {
  final String label;
  final double width;
  final String? fieldKey;
  final Map<String, dynamic>? dataMap;
  final bool readOnly;

  const PassportDateField({
    super.key,
    required this.label,
    required this.width,
    this.fieldKey,
    this.dataMap,
    this.readOnly = false,
  });

  @override
  State<PassportDateField> createState() => _PassportDateFieldState();
}

class _PassportDateFieldState extends State<PassportDateField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy),
          ),
          const SizedBox(height: 6),
          TextFormField(
            readOnly: true,
            initialValue: (widget.dataMap != null && widget.fieldKey != null) ? widget.dataMap![widget.fieldKey] : null,
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.navy),
            onTap: widget.readOnly
                ? null
                : () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null && widget.dataMap != null && widget.fieldKey != null) {
                      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      widget.dataMap![widget.fieldKey!] = formatted;
                      setState(() {});
                    }
                  },
          ),
        ],
      ),
    );
  }
}
