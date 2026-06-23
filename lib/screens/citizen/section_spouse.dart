import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _hasSpouse,
                onChanged: (v) => setState(() => _hasSpouse = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: kDarkBlue,
              ),
              const Text('पति/पत्नी छन् भने भर्नुहोस्',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
          if (_hasSpouse) ...[
            NameRow(nepLabel: 'पहिलो नाम', engLabel: 'First Name'),
            NameRow(nepLabel: 'बीचको नाम', engLabel: 'Middle Name'),
            NameRow(nepLabel: 'थर', engLabel: 'Last Name'),
            const SizedBox(height: 6),
            Wrap(spacing: 12, runSpacing: 6, children: [
              LabeledField(label: 'नागरिकता नं.:', width: 140),
              LabeledField(label: 'जारी जिल्ला:', width: 140),
            ]),
            const SizedBox(height: 6),
            DateEntryWidget(label: 'विवाह मिति:'),
          ],
        ],
      ),
    );
  }
}