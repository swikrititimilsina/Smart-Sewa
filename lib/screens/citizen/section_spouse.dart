import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';

class SpouseSection extends StatefulWidget {
  const SpouseSection({super.key});

  @override
  State<SpouseSection> createState() => _SpouseSectionState();
}

class _SpouseSectionState extends State<SpouseSection> {
  bool _hasSpouse = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _hasSpouse,
                onChanged: (v) => setState(() => _hasSpouse = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.teal,
              ),
              const Text('पति/पत्नी छन् भने भर्नुहोस्',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
            ],
          ),
          if (_hasSpouse) ...[
            const SizedBox(height: 12),
            const NameRow(nepLabel: 'पहिलो नाम', engLabel: 'First Name'),
            const NameRow(nepLabel: 'बीचको नाम', engLabel: 'Middle Name'),
            const NameRow(nepLabel: 'थर', engLabel: 'Last Name'),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                if (isWide) {
                  return Row(
                    children: const [
                      Expanded(child: LabeledField(label: 'नागरिकता नं.:', width: double.infinity)),
                      SizedBox(width: 16),
                      Expanded(child: LabeledField(label: 'जारी जिल्ला:', width: double.infinity)),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      LabeledField(label: 'नागरिकता नं.:', width: double.infinity),
                      SizedBox(height: 12),
                      LabeledField(label: 'जारी जिल्ला:', width: double.infinity),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            const DateEntryWidget(label: 'विवाह मिति:'),
          ],
        ],
      ),
    );
  }
}