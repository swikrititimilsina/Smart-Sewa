import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NameRow(nepLabel: 'पहिलो नाम', engLabel: 'First Name'),
          NameRow(nepLabel: 'बीचको नाम', engLabel: 'Middle Name'),
          NameRow(nepLabel: 'थर', engLabel: 'Last Name'),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: _isForeign,
                onChanged: (v) => setState(() => _isForeign = v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: kDarkBlue,
              ),
              Expanded(
                child: Text(
                  widget.foreignLabel,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          if (_isForeign)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LabeledField(
                label: 'मुलुकको नाम (Country Name):',
                width: 220,
              ),
            ),
        ],
      ),
    );
  }
}