import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';

class ParentSection extends StatefulWidget {
  final String foreignLabel;
  const ParentSection({super.key, required this.foreignLabel});

  @override
  State<ParentSection> createState() => _ParentSectionState();
}

class _ParentSectionState extends State<ParentSection> {
  bool _isForeign = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NameRow(nepLabel: 'पहिलो नाम', engLabel: 'First Name'),
          const NameRow(nepLabel: 'बीचको नाम', engLabel: 'Middle Name'),
          const NameRow(nepLabel: 'थर', engLabel: 'Last Name'),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _isForeign,
                onChanged: (v) => setState(() => _isForeign = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.teal,
              ),
              Expanded(
                child: Text(
                  widget.foreignLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.navy),
                ),
              ),
            ],
          ),
          if (_isForeign)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LabeledField(
                label: 'मुलुकको नाम (Country Name):',
                width: 260,
              ),
            ),
        ],
      ),
    );
  }
}