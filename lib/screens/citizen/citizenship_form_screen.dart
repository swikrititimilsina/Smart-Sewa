import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/citizenship_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:smartsewa/utils/pdf_capture_helper.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CitizenshipFormScreen extends StatefulWidget {
  const CitizenshipFormScreen({super.key});

  @override
  State<CitizenshipFormScreen> createState() =>
      _CitizenshipFormScreenState();
}

class _CitizenshipFormScreenState extends State<CitizenshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();
  String? _sex;

  Future<void> _submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final base64String = await captureFormAsPdfBase64(
        controller: _screenshotController,
        context: context,
        formWidget: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: _buildFormContent(),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('You must be logged in to submit a form.');
      }

      await FirebaseFirestore.instance.collection('applications').add({
        'applicant': 'Applicant',
        'citizenId': user.uid,
        'title': 'Citizenship Application',
        'type': 'Citizenship',
        'status': 'Pending',
        'pdfBase64': base64String,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✔ Form submitted / फारम पेश गरियो'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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
        backgroundColor: AppColors.teal,
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        const SizedBox(height: 16),
        _buildAddressBlock(),
        const SizedBox(height: 16),
        _buildSubjectLine(),
        const SizedBox(height: 16),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'नागरिकताको प्रमाण-पत्र (अनुसूची-१)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Screenshot(
          controller: _screenshotController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormContent(),
                  const CitDivider(),
                  _buildButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy),
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const Text('जिल्ला प्रशासन कार्यालय,',
            style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: const [
            CitField(hint: 'ठाउँ', width: 160),
            Text(',', style: TextStyle(fontSize: 14)),
            CitField(hint: 'जिल्ला', width: 160),
            Text('जिल्ला', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  // ── SUBJECT LINE ───────────────────────────────────────────────────────────
  Widget _buildSubjectLine() {
    return Center(
      child: Text(
        'विषय : नेपाली नागरिकताको प्रमाण-पत्र पाउँ ।',
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.navy),
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
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        SizedBox(height: 12),
        Text(
          'मैले माथि लेखिदिएको व्यहोरा ठिक साँचो हो । झुट्ठा ठहरे कानून बमोजिम सहुँला बुझाउँला ।',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  // ── SECTION A: Personal Details ────────────────────────────────────────────
  Widget _buildSectionA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader('  व्यक्तिगत विवरण / Personal Details'),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, constraints) {
          final wide = constraints.maxWidth > 600;
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildLeftColumn()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildRightColumn()),
                  ],
                )
              : Column(children: [
                  _buildLeftColumn(),
                  const SizedBox(height: 16),
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
          field: CitField(),
        ),

        // Sex
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const SizedBox(
                width: 240,
                child: Text('२. लिङ्ग / Sex:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
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
                      activeColor: AppColors.teal,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(s,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.navy)),
                    const SizedBox(width: 12),
                  ],
                ),
            ],
          ),
        ),

        const CitLabeledRow(
          label: '३. जन्म स्थान / Place of Birth:',
          field: CitField(),
        ),
        const CitLabeledRow(
          label: '४. स्थायी वास स्थान – जिल्ला:',
          field: CitField(),
        ),
        const CitLabeledRow(
          label: '    गा.वि.स. / VDC/Municipality:',
          field: CitField(),
        ),
        const CitLabeledRow(
          label: '    वडा नं.:',
          field: CitField(
              width: 100, keyboardType: TextInputType.number),
        ),

        // DOB
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: const [
              SizedBox(
                width: 240,
                child: Text(
                    '५. जन्म मिति (Date of Birth AD):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
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
            field: CitField()),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField()),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField()),
        CitLabeledRow(
            label: '७. आमाको नाम, घर:',
            field: CitField()),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField()),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField()),
        CitLabeledRow(
            label: '८. पति/पत्नीको नाम, घर:',
            field: CitField()),
        CitLabeledRow(
            label: '    ठेगाना:', field: CitField()),
        CitLabeledRow(
            label: '    नागरिकता नं.:', field: CitField()),
        CitLabeledRow(
            label: '९. संरक्षकको नाम, घर:',
            field: CitField()),
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
        const SizedBox(height: 12),
        LayoutBuilder(builder: (ctx, constraints) {
          return constraints.maxWidth > 500
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbprints(),
                    const SizedBox(width: 32),
                    Expanded(child: _buildDigitalSignature()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbprints(),
                    const SizedBox(height: 20),
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
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Text(lbl,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                        lbl.contains('Right') ? 'R' : 'L',
                        style: const TextStyle(
                            fontSize: 28,
                            color: Color(0xFFE0E0E0))),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('निवेदकको डिजिटल दस्तखत / Digital Signature:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
        SizedBox(height: 8),
        CitSignaturePad(width: double.infinity, height: 80),
        SizedBox(height: 12),
        Text('मिति / Date: ____________________',
            style: TextStyle(fontSize: 13, color: AppColors.navy)),
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Text(
                      '...... गाउँ विकास समिति / नगरपालिका / उपमहानगरपालिका / महानगरपालिकाको वडा नं.',
                      style: TextStyle(fontSize: 13, height: 1.5)),
                  CitField(width: 80, hint: 'वडा'),
                  Text('बस्ने', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Text('मा मिति', style: TextStyle(fontSize: 13)),
                  CitDateEntry(),
                  Text('मा जन्म भई हाल',
                      style: TextStyle(fontSize: 13)),
                  CitField(width: 200, hint: 'हालको ठेगाना'),
                  Text(
                      'गाउँ विकास समिति / नगरपालिका / उपमहानगरपालिका / महानगरपालिका वडा नं.',
                      style: TextStyle(fontSize: 13)),
                  CitField(width: 80, hint: 'वडा'),
                  Text('मा स्थायी रूपमा बसोबास गरी आएका',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Text('लेखिएका श्रीमान्/श्रीमती',
                      style: TextStyle(fontSize: 13)),
                  CitField(width: 200, hint: 'पति/पत्नीको नाम'),
                  Text('को छोरा / छोरी / पत्नी वर्ष',
                      style: TextStyle(fontSize: 13)),
                  CitField(
                    width: 80,
                    hint: 'उमेर',
                    keyboardType: TextInputType.number,
                  ),
                  Text('को', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Text('श्री / सुश्री / श्रीमती',
                      style: TextStyle(fontSize: 13)),
                  CitField(width: 240, hint: 'निवेदकको नाम'),
                  Text('लाई म राम्ररी चिन्दछु ।',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'उपर्युक्त लेखिए बमोजिमको निजको व्यहोरा मैले जाने बुझे सम्म साँचो हो । निजलाई बंशज / जन्मका आधारले नागरिकताको प्रमाण-पत्र दिएमा हुन्छ । उक्त विवरण झुट्ठा ठहरे कानून बमोजिम सहुँला बुझाउँला ।',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const CitDivider(),

              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: const [
                  CitField(label: 'मिति :-', width: 200),
                  CitField(
                      label: 'कार्यालयको नाम र छाप :',
                      width: 260),
                ],
              ),
              const SizedBox(height: 16),

              LayoutBuilder(builder: (ctx, constraints) {
                return constraints.maxWidth > 500
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('सिफारिस गर्नेको :',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy)),
                          const SizedBox(width: 32),
                          Expanded(child: _buildVdcSignBlock()),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('सिफारिस गर्नेको :',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy)),
                          const SizedBox(height: 12),
                          _buildVdcSignBlock(),
                        ],
                      );
              }),
              const SizedBox(height: 20),

              const Text(
                  'संलग्न कागजातहरू / Attached Documents (optional):',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 16,
                runSpacing: 12,
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
        const Text('दस्तखत / Digital Signature:',
            style: TextStyle(fontSize: 12, color: AppColors.navy)),
        const SizedBox(height: 8),
        const CitSignaturePad(width: double.infinity, height: 60),
        const SizedBox(height: 12),
        const CitLabeledRow(
            label: 'नाम, घर :', field: CitField()),
        const SizedBox(height: 8),
        const CitLabeledRow(
            label: 'पद :', field: CitField()),
      ],
    );
  }

  // ── SECTION D: निर्णय / Decision ──────────────────────────────────────────
  Widget _buildSectionD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CitSectionHeader('  निर्णय / Decision'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            CitField(label: 'वितरित ना:प्र.प.नं.:', width: 220),
            CitField(label: 'मिति :', width: 200),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (ctx, constraints) {
          final w = ((constraints.maxWidth - 40) / 3).clamp(120.0, 240.0);
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for (final role in [
                'सनाखत गराउने',
                'पेश गर्ने',
                'सदर गर्ने'
              ])
                SizedBox(
                  width: w,
                  child: Column(
                    children: [
                      Text(role,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy)),
                      const SizedBox(height: 8),
                      const CitSignaturePad(
                          width: double.infinity, height: 70),
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
        const SizedBox(height: 8),
        const Text(
          'तलका कागजातहरू अनिवार्य छैनन् — उपलब्ध भएमा मात्र संलग्न गर्नुहोस् ।\n(The following documents are optional — attach only if available.)',
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 16,
          runSpacing: 16,
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
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
    );
  }

  // ── BUTTONS ────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Submit / दर्ता', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _printPreview,
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print Preview / प्रिन्ट', style: TextStyle(fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Clear Form / मेटाउनुहोस्', style: TextStyle(fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            width: 110,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _uploaded ? AppColors.teal : Colors.grey.shade300, width: 1.5),
            ),
            child: _uploaded
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.teal, size: 32),
                      SizedBox(height: 8),
                      Text('Uploaded',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal)),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file,
                          color: Colors.grey, size: 26),
                      SizedBox(height: 6),
                      Text('Click to upload\n(optional)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 110,
            child: Text(widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}