import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/birth_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:smartsewa/utils/pdf_capture_helper.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BirthFormScreen extends StatefulWidget {
  const BirthFormScreen({super.key});

  @override
  State<BirthFormScreen> createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();

  // Radio state
  String? _gender;
  String? _birthType;
  String? _attendant;
  String? _process;

  // Checkboxes for birth place
  bool _placeHome = false;
  bool _placeHealth = false;
  bool _placeSanstha = false;
  bool _placeHospital = false;
  bool _placeOther = false;
  bool _weightUnknown = false;

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
          color: const Color(0xFFF0F4FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSection1(),
                    _buildSection2(),
                    _buildSection3(),
                    _buildSignatory(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('You must be logged in to submit a form.');
      }

      await FirebaseFirestore.instance.collection('applications').add({
        'applicant': 'Applicant',
        'citizenId': user.uid,
        'title': 'Birth Registration',
        'type': 'Birth Registration',
        'status': 'Pending',
        'pdfBase64': base64String,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ फाराम पेश गरिएको छ (Form Submitted)'),
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
    _formKey.currentState?.reset();
    setState(() {
      _gender = null;
      _birthType = null;
      _attendant = null;
      _process = null;
      _placeHome = false;
      _placeHealth = false;
      _placeSanstha = false;
      _placeHospital = false;
      _placeOther = false;
      _weightUnknown = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✗ फाराम मेटाइएको छ (Form Cleared)'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'जन्मको सूचना फाराम',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Screenshot(
          controller: _screenshotController,
          child: SingleChildScrollView(
            child: Container(
              color: const Color(0xFFF0F4FA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildSection1(),
                        _buildSection2(),
                        _buildSection3(),
                        _buildSignatory(),
                        _buildButtons(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('अनूसूची-१०',
              style: TextStyle(fontSize: 12, color: Color(0xFF222222))),
          const Text(
            '(नियम १६ को उपनियम (१) को खण्ड (क) सँग सम्बन्धित)',
            style: TextStyle(fontSize: 11, color: Color(0xFF444444)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'जन्मको सूचना फाराम',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
          const Text('(सूचकले भर्नें)',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF444444))),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('श्री स्थानीय पञ्जिकाधिकारीज्यू,',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    BirthLabeledField(label: 'वडा नं.', width: 80),
                    SizedBox(width: 16),
                    BirthLabeledField(label: 'ग.वि.स./न.पा.', width: 160, isExpanded: true),
                  ],
                ),
                const SizedBox(height: 10),
                const BirthLabeledField(label: 'जिल्ला:', width: 200),
                const SizedBox(height: 16),
                const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text('निम्न लिखित विवरण खुलाई मेरो',
                        style: TextStyle(fontSize: 13)),
                    BirthLabeledField(label: '', width: 180, hint: 'सम्बन्ध'),
                    Text('को जन्मको सूचना दिन आएको छु ।',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('कानून बमोजिम जन्म दर्ता गरी पाउँ ।',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION 1: Child's Personal Info ────────────────────────────────────
  Widget _buildSection1() {
    return BirthCard(
      title: '१) व्यक्तिगत विवरण:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nepali name
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 12),
          // English name
          const NameRowBirthEn(),
          const SizedBox(height: 16),

          // DOB
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BirthDateEntry(label: 'जन्म मिति वि.सं.:'),
              BirthDateEntry(label: 'ई.सं.:'),
            ],
          ),
          const SizedBox(height: 16),

          // Birth place checkboxes
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('बच्चा जन्मेको ठाउँ :',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              _checkItem('घर', _placeHome,
                      (v) => setState(() => _placeHome = v!)),
              _checkItem('स्वास्थ्य', _placeHealth,
                      (v) => setState(() => _placeHealth = v!)),
              _checkItem('संस्था', _placeSanstha,
                      (v) => setState(() => _placeSanstha = v!)),
              _checkItem('अस्पताल', _placeHospital,
                      (v) => setState(() => _placeHospital = v!)),
              _checkItem('अन्य', _placeOther,
                      (v) => setState(() => _placeOther = v!)),
            ],
          ),
          const SizedBox(height: 12),

          // Gender
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('लिङ्ग / Gender:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in [
                ('पुरुष', 'M'),
                ('महिला', 'F'),
                ('अन्य', 'O')
              ])
                _radioItem(e.$1, e.$2, _gender,
                        (v) => setState(() => _gender = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Birth address
          const Text('बच्चा जन्मेको ठेगाना / Child\'s Birth Address:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Row(children: [
            BirthLabeledField(label: 'प्रदेश:', width: 100, isExpanded: true),
            SizedBox(width: 12),
            BirthLabeledField(label: 'ग.पा./न.पा.:', width: 140, isExpanded: true),
            SizedBox(width: 12),
            BirthLabeledField(label: 'वडा नं.:', width: 60),
          ]),
          const SizedBox(height: 16),

          // Born abroad
          const Text('विदेशमा जन्मेको भए / If born abroad:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Row(children: [
            BirthLabeledField(label: 'देश/Country:', width: 120, isExpanded: true),
            SizedBox(width: 12),
            BirthLabeledField(label: 'Province/State:', width: 120, isExpanded: true),
            SizedBox(width: 12),
            BirthLabeledField(label: 'Local Address:', width: 150, isExpanded: true),
          ]),
          const SizedBox(height: 16),

          // Birth type
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('जन्मको किसिम / Type of Birth:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in [
                'एकल',
                'जुम्ल्याहा',
                'तिम्ल्याहा',
                'सो भन्दा बढी'
              ])
                _radioItem(e, e, _birthType,
                        (v) => setState(() => _birthType = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Birth weight
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const BirthLabeledField(
                  label: 'बच्चा जन्मेको तौल (ग्राम):', width: 100),
              const Text('ग्राम',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _weightUnknown,
                    activeColor: AppColors.teal,
                    onChanged: (v) =>
                        setState(() => _weightUnknown = v!),
                  ),
                  const Text('थाहा नभएको / Unknown',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Birth attendant
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('मद्दत गर्ने व्यक्ति / Birth Attendant:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in [
                'डाक्टर',
                'नर्स/अनमी',
                'परम्परागत सुडिनी',
                'तालिम प्राप्त सुडिनी',
                'घर परिवारका सदस्य'
              ])
                _radioItem(e, e, _attendant,
                        (v) => setState(() => _attendant = v)),
            ],
          ),
          const SizedBox(height: 8),
          const BirthLabeledField(label: '☐ अन्य/Other:', width: 200),
          const SizedBox(height: 16),

          // Birth process
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('जन्म प्रक्रिया / Birth Process:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in [
                'सामान्य',
                'औजार',
                'शल्यक्रिया',
                'भ्याकुम',
                'फर्सेप'
              ])
                _radioItem(e, e, _process,
                        (v) => setState(() => _process = v)),
            ],
          ),
        ],
      ),
    );
  }

  // ── SECTION 2: Grandparents ──────────────────────────────────────────────
  Widget _buildSection2() {
    return BirthCard(
      title: '२) बच्चाको बाजे/बज्यैको विवरण',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('क) बाजेको नाम:-',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 8),
          const NameRowBirthEn(),
          const BirthFormDivider(),
          const Text('ख) बज्यैको नाम:-',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 8),
          const NameRowBirthEn(),
        ],
      ),
    );
  }

  // ── SECTION 3: Parents ───────────────────────────────────────────────────
  Widget _buildSection3() {
    return BirthCard(
      title: '३) बच्चाको बाबु/आमाको विवरण',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Father
          const Text('क) बाबुको नाम:-',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 8),
          const NameRowBirthEn(),
          const BirthFormDivider(),

          // Mother
          const Text('ख) आमाको नाम:-',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 8),
          const NameRowBirthEn(),
          const BirthFormDivider(),

          // Details table
          const Text('स्थायी ठेगाना तथा अन्य विवरण:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildParentsTable(),
        ],
      ),
    );
  }

  Widget _buildParentsTable() {
    final rows = [
      ('प्रदेश', false),
      ('गा.पा./न.पा.', false),
      ('वडा नं.', false),
      ('सडक/मार्ग', false),
      ('गाउँ/टोल', false),
      ('घर नं.', false),
      ('राष्ट्रिय परिचय नं./नागरिकता प्र.प.नं.', false),
      ('विदेशी भएमा पासपोर्ट नं. र देशको नाम', false),
      ('विवाह दर्ता नं.', false),
      ('विवाह भएको मिति (वि.सं.)', false),
      ('विवाह भएको मिति (ई.सं.)', false),
      ('जन्म मिति (वि.सं.)', false),
      ('जन्म मिति (ई.सं.)', false),
      ('शैक्षिक स्तर', false),
      ('पेशा', false),
      ('धर्म', false),
      ('जात', false),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade200)),
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.05)),
            children: [
              _tableHeader('स्थायी ठेगाना'),
              _tableHeader('बाबुको विवरण'),
              _tableHeader('आमाको विवरण'),
            ],
          ),
          // Data rows
          for (final row in rows)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Text(row.$1,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
                ),
                _tableFieldCell(),
                _tableFieldCell(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.navy)),
    );
  }

  Widget _tableFieldCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  // ── SIGNATORY SECTION ────────────────────────────────────────────────────
  Widget _buildSignatory() {
    return BirthCard(
      title: 'सूचक (सही गर्ने) को विवरण / Informant Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'यसमा लेखिएको विवरण साँचो हो । झुट्टा ठहरे कानून बमोजिम सहुँला बुझाउँला भनी सिहछाप गर्ने सूचकको विवरण:',
            style: TextStyle(fontSize: 12, color: AppColors.navy),
          ),
          const SizedBox(height: 16),

          // Name
          const Text('सूचकको नाम / Informant\'s Name:',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 8),
          const NameRowBirthEn(),
          const SizedBox(height: 16),

          // Relationship
          const BirthLabeledField(
              label: 'बच्चासँगको नाता / Relationship:',
              width: 200),
          const SizedBox(height: 12),

          // Contact
          const Row(children: [
            BirthLabeledField(
                label: 'सम्पर्क नम्बर / Contact:', width: 130, isExpanded: true),
            SizedBox(width: 16),
            BirthLabeledField(label: 'ई-मेल / Email:', width: 180, isExpanded: true),
          ]),
          const SizedBox(height: 16),

          // Nepali citizen
          const Text('सूचक नेपाली नागरिक भएमा:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const BirthLabeledField(
              label: 'नागरिकता प्र.प.नं./राष्ट्रिय परिचय नं.:',
              width: 220),
          const SizedBox(height: 16),

          // Foreign citizen
          const Text('सूचक विदेशी नागरिक भएमा:',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Row(children: [
            BirthLabeledField(label: 'राहदानी नं./Passport No.:', width: 160, isExpanded: true),
            SizedBox(width: 16),
            BirthLabeledField(
                label: 'जारी गर्ने देश/Issuing Country:', width: 160, isExpanded: true),
          ]),
          const SizedBox(height: 16),

          // Date filled
          const Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 12,
            children: [
              Text('फाराम भरेको मिति (साल-महिना-गते):',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
              BirthDateEntry(label: ''),
            ],
          ),
          const SizedBox(height: 24),

          // Fingerprint + signature
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fingerprints
              Row(
                children: [
                  for (final lbl in ['दायाँ', 'बायाँ'])
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(lbl,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.navy)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 32),
              // Signature
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80),
                    Text('......................................................',
                        style:
                        TextStyle(fontSize: 13, color: AppColors.navy)),
                    SizedBox(height: 4),
                    Text('सूचकको सिहछाप',
                        style:
                        TextStyle(fontSize: 12, color: AppColors.navy)),
                  ],
                ),
              ),
            ],
          ),
          const BirthFormDivider(),

          // Official use
          const Text('(स्थानीय पञ्जिकाधिकारीले भर्ने)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal)),
          const SizedBox(height: 12),
          for (final lbl in [
            'स्थानीय पञ्जिकाधिकारीको नाम:',
            'कर्मचारी संकेत नं./परिचय नं.:',
            'फाराम दर्ता नं.:',
            'फाराम दर्ता मिति:',
            'परिवारको लगत नं.:',
            'कार्यालय (गाउँपालिका/नगरपालिका/वडा नं./नेपाली नियोग):',
          ])
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: Text(lbl,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const BirthFormDivider(),

          // Required documents
          const Text('संलग्न गर्नुपर्ने कागजात:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 10),
          for (final doc in [
            '१)  बाबु वा आमाको नागरिकता प्रमाण पत्रको प्रतिलिपि,',
            '२)  स्वास्थ्य संस्था/अस्पतालमा जन्म भएको भए उक्त संस्थाबाट जारी जन्म प्रतिवेदन,',
            '३)  घरमा जन्म भएको भए पछिल्लो खोप दिएको प्रमाण,',
            '४)  विदेशी भएमा बाबु, आमाको राहदानी प्रमाणपत्रको प्रतिलिपि तथा सम्बन्धित स्थानीय तहको वडामा बसोबास रहेको प्रमाण,',
            '५)  बाबु बेपत्ता वा ठेगाना थाहा नभएको भए सो सम्बन्धी प्रहरी प्रतिवेदन ।',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(doc,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.navy, height: 1.4)),
            ),
        ],
      ),
    );
  }

  // ── BUTTONS ──────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
            ),
            child: const Text('Submit / पेश गर्नुहोस्',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: _clear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
            ),
            child: const Text('Clear / मेटाउनुहोस्',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Widget _radioItem(String label, String value, String? groupValue,
      void Function(String?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppColors.teal,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
      ],
    );
  }

  Widget _checkItem(
      String label, bool value, void Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            value: value,
            activeColor: AppColors.teal,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.navy)),
      ],
    );
  }
}