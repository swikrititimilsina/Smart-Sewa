// lib/screens/citizen/citizenship_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/citizenship_widgets.dart';

class CitizenshipFormScreen extends StatefulWidget {
  const CitizenshipFormScreen({super.key});

  @override
  State<CitizenshipFormScreen> createState() =>
      _CitizenshipFormScreenState();
}

class _CitizenshipFormScreenState
    extends State<CitizenshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _sex;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✔ Form submitted / फारम पेश गरियो'),
        backgroundColor: Color(0xFF27ae60),
      ),
    );
  }

  void _clear() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Form'),
        content: const Text(
            'Are you sure you want to clear all fields?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState?.reset();
              setState(() => _sex = null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('🗑 Form cleared'),
                    backgroundColor: Color(0xFFc0392b)),
              );
            },
            child: const Text('Clear',
                style: TextStyle(color: Color(0xFFc0392b))),
          ),
        ],
      ),
    );
  }

  void _printPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖨 Print feature coming soon'),
        backgroundColor: Color(0xFF2980b9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCitBg,
      appBar: AppBar(
        backgroundColor: kCitAccent,
        title: const Text(
          'नागरिकताको प्रमाण-पत्र (अनुसूची-१)',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              _buildAddressBlock(),
              _buildSubjectLine(),
              _buildBodyText(),
              const CitDivider(),
              _buildSectionA(),
              const CitDivider(),
              _buildSectionB(),
              const CitDivider(),
              _buildSectionC(),
              const CitDivider(),
              _buildSectionD(),
              const CitDivider(),
              _buildSectionE(),
              const CitDivider(),
              _buildDateFooter(),
              const CitDivider(),
              _buildButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── TITLE ──────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Text(
              'अनुसूची-१',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kCitAccent),
            ),
          ),
        ),
        const CitPhotoUpload(
          label:
          'निवेदकको\nदुवै कान देखिने\nपासपोर्ट साइजको\nफोटो\n(Click to upload)',
        ),
      ],
    );
  }

  // ── ADDRESS BLOCK ──────────────────────────────────────────────────────────
  Widget _buildAddressBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('श्री प्रमुख जिल्ला अधिकारी ज्यू,',
            style: TextStyle(fontSize: 12)),
        const Text('जिल्ला प्रशासन कार्यालय,',
            style: TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: const [
            CitField(hint: 'ठाउँ', width: 150),
            Text(',', style: TextStyle(fontSize: 13)),
            CitField(hint: 'जिल्ला', width: 150),
            Text('जिल्ला', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // ── SUBJECT LINE ───────────────────────────────────────────────────────────
  Widget _buildSubjectLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'विषय : नेपाली नागरिकताको प्रमाण-पत्र पाउँ ।',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kCitAccent),
        ),
      ),
    );
  }

  // ── BODY TEXT ──────────────────────────────────────────────────────────────
  Widget _buildBodyText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'महोदय,\n\n    म बंशजको नाताले जन्मका आधारले नेपाली नागरिकता भएकोले देहायको विवरण खोली नेपाली नागरिकताको प्रमाण-पत्र पाउनको लागि सिफारिस साथ रु.१०१-को टिकट टाँसी यो निवेदन पत्र पेश गरेको छु । मैले यस अघि नेपाली नागरिकताको प्रमाण-पत्र लिएको छैन ।',
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: 8),
        Text(
          'मैले माथि लेखिदिएको व्यहोरा ठिक साँचो हो । झुट्ठा ठहरे कानून बमोजिम सहुँला बुझाउँला ।',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ── SECTION A: Personal Details ────────────────────────────────────────────
  Widget _buildSectionA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader(
            '  व्यक्तिगत विवरण / Personal Details'),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (ctx, constraints) {
          final wide = constraints.maxWidth > 600;
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLeftColumn()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRightColumn()),
                  ],
                )
              : Column(children: [
                  _buildLeftColumn(),
                  const SizedBox(height: 12),
                  _buildRightColumn(),
                ]);
        }),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitLabeledRow(
          label: '१. नाम, घर (Full Name in block):',
          field: CitField(width: 200),
        ),

        // Sex
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const SizedBox(
                width: 240,
                child: Text('२. लिङ्ग / Sex:',
                    style: TextStyle(fontSize: 12, color: kCitText)),
              ),
              for (final s in [
                'पुरुष / Male',
                'महिला / Female',
                'अन्य / Other'
              ])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: s,
                      groupValue: _sex,
                      onChanged: (v) => setState(() => _sex = v),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(s,
                        style: const TextStyle(
                            fontSize: 12, color: kCitText)),
                    const SizedBox(width: 6),
                  ],
                ),
            ],
          ),
        ),

        const CitLabeledRow(
          label: '३. जन्म स्थान / Place of Birth:',
          field: CitField(width: 200),
        ),
        const CitLabeledRow(
          label: '४. स्थायी वास स्थान – जिल्ला:',
          field: CitField(width: 200),
        ),
        const CitLabeledRow(
          label: '    गा.वि.स. / VDC/Municipality:',
          field: CitField(width: 200),
        ),
        const CitLabeledRow(
          label: '    वडा नं.:',
          field: CitField(
              width: 80, keyboardType: TextInputType.number),
        ),

        // DOB
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: const [
              SizedBox(
                width: 240,
                child: Text(
                    '५. जन्म मिति (Date of Birth AD):',
                    style: TextStyle(fontSize: 12, color: kCitText)),
              ),
              CitDateEntry(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        CitLabeledRow(
            label: '६. बाबुको नाम, घर:',
            field: CitField(width: 180)),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '७. आमाको नाम, घर:',
            field: CitField(width: 180)),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '८. पति/पत्नीको नाम, घर:',
            field: CitField(width: 180)),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField(width: 180)),
        CitLabeledRow(
            label: '९. संरक्षकको नाम, घर:',
            field: CitField(width: 180)),
      ],
    );
  }

  // ── SECTION B: Thumbprint + Signature ─────────────────────────────────────
  Widget _buildSectionB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader(
            '  औँठाको छाप / Thumbprint & Digital Signature'),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (ctx, constraints) {
          return constraints.maxWidth > 500
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbprints(),
                    const Spacer(),
                    _buildDigitalSignature(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbprints(),
                    const SizedBox(height: 12),
                    _buildDigitalSignature(),
                  ],
                );
        }),
      ],
    );
  }

  Widget _buildThumbprints() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final lbl in ['दायाँ / Right', 'बायाँ / Left'])
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Text(lbl,
                    style: const TextStyle(
                        fontSize: 11, color: kCitText)),
                const SizedBox(height: 4),
                Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: kCitBorder),
                  ),
                  child: Center(
                    child: Text(
                        lbl.contains('Right') ? 'R' : 'L',
                        style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFFcccccc))),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDigitalSignature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Text('निवेदकको डिजिटल दस्तखत / Digital Signature:',
            style: TextStyle(fontSize: 12, color: kCitText)),
        SizedBox(height: 4),
        CitSignaturePad(width: 210, height: 60),
        SizedBox(height: 8),
        Text('मिति / Date: ____________________',
            style: TextStyle(fontSize: 12, color: kCitText)),
      ],
    );
  }

  // ── SECTION C: VDC Recommendation ─────────────────────────────────────────
  Widget _buildSectionC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader(
            '  गाउँ विकास समिति / उप/मह/नगरपालिकाको सिफारिस'),
        Container(
          decoration: BoxDecoration(
            color: kCitBg,
            border: Border.all(color: kCitBorder, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: const [
                  Text(
                      '...... गाउँ विकास समिति / नगरपालिका / उपमहानगरपालिका / महानगरपालिकाको वडा नं.',
                      style: TextStyle(fontSize: 12)),
                  CitField(width: 60, hint: 'वडा'),
                  Text('बस्ने', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: const [
                  Text('मा मिति', style: TextStyle(fontSize: 12)),
                  CitDateEntry(),
                  Text('मा जन्म भई हाल',
                      style: TextStyle(fontSize: 12)),
                  CitField(width: 160, hint: 'हालको ठेगाना'),
                  Text(
                      'गाउँ विकास समिति / नगरपालिका / उपमहानगरपालिका / महानगरपालिका वडा नं.',
                      style: TextStyle(fontSize: 12)),
                  CitField(width: 60, hint: 'वडा'),
                  Text('मा स्थायी रूपमा बसोबास गरी आएका',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: const [
                  Text('लेखिएका श्रीमान्/श्रीमती',
                      style: TextStyle(fontSize: 12)),
                  CitField(width: 160, hint: 'पति/पत्नीको नाम'),
                  Text('को छोरा / छोरी / पत्नी वर्ष',
                      style: TextStyle(fontSize: 12)),
                  CitField(
                    width: 60,
                    hint: 'उमेर',
                    keyboardType: TextInputType.number,
                  ),
                  Text('को', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: const [
                  Text('श्री / सुश्री / श्रीमती',
                      style: TextStyle(fontSize: 12)),
                  CitField(width: 220, hint: 'निवेदकको नाम'),
                  Text('लाई म राम्ररी चिन्दछु ।',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'उपर्युक्त लेखिए बमोजिमको निजको व्यहोरा मैले जाने बुझे सम्म साँचो हो । निजलाई बंशज / जन्मका आधारले नागरिकताको प्रमाण-पत्र दिएमा हुन्छ । उक्त विवरण झुट्ठा ठहरे कानून बमोजिम सहुँला बुझाउँला ।',
                style: TextStyle(fontSize: 12),
              ),
              const CitDivider(),

              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: const [
                  CitField(label: 'मिति :-', width: 180),
                  CitField(
                      label: 'कार्यालयको नाम र छाप :',
                      width: 220),
                ],
              ),
              const SizedBox(height: 12),

              LayoutBuilder(builder: (ctx, constraints) {
                return constraints.maxWidth > 500
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('सिफारिस गर्नेको :',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kCitText)),
                          const Spacer(),
                          _buildVdcSignBlock(),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('सिफारिस गर्नेको :',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kCitText)),
                          const SizedBox(height: 8),
                          _buildVdcSignBlock(),
                        ],
                      );
              }),
              const SizedBox(height: 12),

              const Text(
                  'संलग्न कागजातहरू / Attached Documents (optional):',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kCitText)),
              const SizedBox(height: 6),
              const Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _DocSlot(label: 'सिफारिस पत्र\n(Recommendation)'),
                  _DocSlot(
                      label: 'नागरिकता प्रमाण\n(Citizenship Proof)'),
                  _DocSlot(
                      label: 'अन्य कागजात\n(Other Document)'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVdcSignBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('दस्तखत / Digital Signature:',
                style: TextStyle(fontSize: 12, color: kCitText)),
            SizedBox(width: 8),
            CitSignaturePad(width: 220, height: 55),
          ],
        ),
        const SizedBox(height: 6),
        const CitLabeledRow(
            label: 'नाम, घर :', field: CitField(width: 200)),
        const SizedBox(height: 6),
        const CitLabeledRow(
            label: 'पद :', field: CitField(width: 200)),
      ],
    );
  }

  // ── SECTION D: निर्णय / Decision ──────────────────────────────────────────
  Widget _buildSectionD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader('  निर्णय / Decision'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            CitField(label: 'वितरित ना:प्र.प.नं.:', width: 160),
            CitField(label: 'मिति :', width: 140),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, constraints) {
          final w = (constraints.maxWidth - 32) / 3;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final role in [
                'सनाखत गराउने',
                'पेश गर्ने',
                'सदर गर्ने'
              ])
                SizedBox(
                  width: w.clamp(140, 240),
                  child: Column(
                    children: [
                      Text(role,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kCitText)),
                      const SizedBox(height: 6),
                      const CitSignaturePad(
                          width: 170, height: 60),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // ── SECTION E: Optional Documents ─────────────────────────────────────────
  Widget _buildSectionE() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader(
            '  संलग्न कागजातहरू / Supporting Documents (Optional)'),
        const SizedBox(height: 4),
        const Text(
          'तलका कागजातहरू अनिवार्य छैनन् — उपलब्ध भएमा मात्र संलग्न गर्नुहोस् ।\n(The following documents are optional — attach only if available.)',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _DocSlot(
                label: 'जन्मदर्ता प्रमाण\n(Birth Certificate)'),
            _DocSlot(
                label:
                    'बाबु/आमाको\nनागरिकता\n(Parent Citizenship)'),
            _DocSlot(
                label: 'विद्यालय प्रमाण\n(School Certificate)'),
            _DocSlot(
                label: 'अन्य कागजात\n(Other Document)'),
          ],
        ),
      ],
    );
  }

  // ── DATE FOOTER ────────────────────────────────────────────────────────────
  Widget _buildDateFooter() {
    final today =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    return Text(
      'मिति / Date:  $today',
      style: const TextStyle(fontSize: 12, color: kCitText),
    );
  }

  // ── BUTTONS ────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Clear Form / मेटाउनुहोस्'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFc0392b),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _printPreview,
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Print Preview / प्रिन्ट'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2980b9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Submit / दर्ता'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27ae60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doc Slot Widget ──────────────────────────────────────────────────────────
class _DocSlot extends StatefulWidget {
  final String label;
  const _DocSlot({required this.label});

  @override
  State<_DocSlot> createState() => _DocSlotState();
}

class _DocSlotState extends State<_DocSlot> {
  bool _uploaded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _uploaded = !_uploaded),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: _uploaded ? kCitAccent : Colors.grey),
            ),
            child: _uploaded
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF27ae60), size: 28),
                      Text('Uploaded',
                          style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF27ae60))),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.attach_file,
                          color: Colors.grey, size: 22),
                      SizedBox(height: 4),
                      Text('Click to upload\n(optional)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey)),
                    ],
                  ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 9, color: kCitText)),
          ),
        ],
      ),
    );
  }
}