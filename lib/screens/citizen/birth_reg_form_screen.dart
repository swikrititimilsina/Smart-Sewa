import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/birth_widgets.dart';

class BirthFormScreen extends StatefulWidget {
  const BirthFormScreen({super.key});

  @override
  State<BirthFormScreen> createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();

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

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ फाराम पेश गरिएको छ (Form Submitted)'),
        backgroundColor: kAccent,
      ),
    );
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
      backgroundColor: kBgMain,
      appBar: AppBar(
        backgroundColor: kNavyBlue,
        title: const Text(
          'जन्मको सूचना फाराम',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSection1(),
              _buildSection2(),
              _buildSection3(),
              _buildSignatory(),
              _buildButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: kBgCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          const SizedBox(height: 8),
          const Text(
            'जन्मको सूचना फाराम',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
          const Text('(सूचकले भर्नें)',
              style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF444444))),
          const Divider(color: kBorder),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('श्री स्थानीय पञ्जिकाधिकारीज्यू,',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    BirthLabeledField(label: 'वडा नं.', width: 60),
                    BirthLabeledField(label: 'ग.वि.स./न.पा.', width: 160),
                  ],
                ),
                const SizedBox(height: 6),
                const BirthLabeledField(label: 'जिल्ला:', width: 200),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    Text('निम्न लिखित विवरण खुलाई मेरो',
                        style: TextStyle(fontSize: 12)),
                    BirthLabeledField(label: '', width: 180, hint: 'सम्बन्ध'),
                    Text('को जन्मको सूचना दिन आएको छु ।',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('कानून बमोजिम जन्म दर्ता गरी पाउँ ।',
                    style: TextStyle(fontSize: 12)),
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
          const SizedBox(height: 6),
          // English name
          const NameRowBirthEn(),
          const SizedBox(height: 8),

          // DOB
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              BirthDateEntry(label: 'जन्म मिति वि.सं.:'),
              BirthDateEntry(label: 'ई.सं.:'),
            ],
          ),
          const SizedBox(height: 8),

          // Birth place checkboxes
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text('बच्चा जन्मेको ठाउँ :',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
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
          const SizedBox(height: 8),

          // Gender
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text('लिङ्ग / Gender:',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
              for (final e in [
                ('पुरुष', 'M'),
                ('महिला', 'F'),
                ('अन्य', 'O')
              ])
                _radioItem(e.$1, e.$2, _gender,
                        (v) => setState(() => _gender = v)),
            ],
          ),
          const SizedBox(height: 8),

          // Birth address
          const Text('बच्चा जन्मेको ठेगाना / Child\'s Birth Address:',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(spacing: 10, runSpacing: 8, children: const [
            BirthLabeledField(label: 'प्रदेश:', width: 100),
            BirthLabeledField(label: 'ग.पा./न.पा.:', width: 140),
            BirthLabeledField(label: 'वडा नं.:', width: 60),
          ]),
          const SizedBox(height: 8),

          // Born abroad
          const Text('विदेशमा जन्मेको भए / If born abroad:',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(spacing: 10, runSpacing: 8, children: const [
            BirthLabeledField(label: 'देश/Country:', width: 120),
            BirthLabeledField(label: 'Province/State:', width: 120),
            BirthLabeledField(label: 'Local Address:', width: 150),
          ]),
          const SizedBox(height: 8),

          // Birth type
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text('जन्मको किसिम / Type of Birth:',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
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
          const SizedBox(height: 8),

          // Birth weight
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const BirthLabeledField(
                  label: 'बच्चा जन्मेको तौल (ग्राम):', width: 80),
              const Text('ग्राम',
                  style: TextStyle(fontSize: 12, color: kMuted)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _weightUnknown,
                    onChanged: (v) =>
                        setState(() => _weightUnknown = v!),
                  ),
                  const Text('थाहा नभएको / Unknown',
                      style: TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Birth attendant
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: [
              const Text('मद्दत गर्ने व्यक्ति / Birth Attendant:',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
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
          const SizedBox(height: 4),
          const BirthLabeledField(label: '☐ अन्य/Other:', width: 200),
          const SizedBox(height: 8),

          // Birth process
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text('जन्म प्रक्रिया / Birth Process:',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
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
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 4),
          const NameRowBirthEn(),
          const BirthFormDivider(),
          const Text('ख) बज्यैको नाम:-',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 4),
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
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 4),
          const NameRowBirthEn(),
          const BirthFormDivider(),

          // Mother
          const Text('ख) आमाको नाम:-',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 4),
          const NameRowBirthEn(),
          const BirthFormDivider(),

          // Details table
          const Text('स्थायी ठेगाना तथा अन्य विवरण:',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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

    return Table(
      border: TableBorder.all(color: kBorder, width: 0.8),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(2.5),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: kBgSec),
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
                padding: const EdgeInsets.all(6),
                child: Text(row.$1,
                    style: const TextStyle(
                        fontSize: 11, color: kNavyBlue)),
              ),
              _tableFieldCell(),
              _tableFieldCell(),
            ],
          ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kNavyBlue)),
    );
  }

  Widget _tableFieldCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextFormField(
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        style: const TextStyle(fontSize: 12),
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
            style: TextStyle(fontSize: 11, color: kNavyBlue),
          ),
          const SizedBox(height: 10),

          // Name
          const Text('सूचकको नाम / Informant\'s Name:',
              style: TextStyle(fontSize: 12, color: kNavyBlue)),
          const SizedBox(height: 4),
          const NameRowBirth(nepLabel: ''),
          const SizedBox(height: 4),
          const NameRowBirthEn(),
          const SizedBox(height: 8),

          // Relationship
          const BirthLabeledField(
              label: 'बच्चासँगको नाता / Relationship:',
              width: 200),
          const SizedBox(height: 8),

          // Contact
          Wrap(spacing: 12, runSpacing: 8, children: const [
            BirthLabeledField(
                label: 'सम्पर्क नम्बर / Contact:', width: 130),
            BirthLabeledField(label: 'ई-मेल / Email:', width: 180),
          ]),
          const SizedBox(height: 10),

          // Nepali citizen
          const Text('सूचक नेपाली नागरिक भएमा:',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const BirthLabeledField(
              label: 'नागरिकता प्र.प.नं./राष्ट्रिय परिचय नं.:',
              width: 180),
          const SizedBox(height: 10),

          // Foreign citizen
          const Text('सूचक विदेशी नागरिक भएमा:',
              style: TextStyle(
                  fontSize: 12,
                  color: kNavyBlue,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Wrap(spacing: 12, runSpacing: 8, children: const [
            BirthLabeledField(label: 'राहदानी नं./Passport No.:', width: 160),
            BirthLabeledField(
                label: 'जारी गर्ने देश/Issuing Country:', width: 160),
          ]),
          const SizedBox(height: 10),

          // Date filled
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: const [
              Text('फाराम भरेको मिति (साल-महिना-गते):',
                  style: TextStyle(fontSize: 12, color: kNavyBlue)),
              BirthDateEntry(label: ''),
            ],
          ),
          const SizedBox(height: 12),

          // Fingerprint + signature
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fingerprints
              Row(
                children: [
                  for (final lbl in ['दायाँ', 'बायाँ'])
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: kBorder),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(lbl,
                              style: const TextStyle(
                                  fontSize: 11, color: kNavyBlue)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Signature
              Column(
                children: const [
                  SizedBox(height: 60),
                  Text('.................................',
                      style:
                      TextStyle(fontSize: 11, color: kNavyBlue)),
                  Text('सूचकको सिहछाप',
                      style:
                      TextStyle(fontSize: 11, color: kNavyBlue)),
                ],
              ),
            ],
          ),
          const BirthFormDivider(),

          // Official use
          const Text('(स्थानीय पञ्जिकाधिकारीले भर्ने)',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: kNavyBlue)),
          const SizedBox(height: 8),
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
                  border: Border.all(color: kBorder)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: Text(lbl,
                        style: const TextStyle(
                            fontSize: 11, color: kNavyBlue)),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          const BirthFormDivider(),

          // Required documents
          const Text('संलग्न गर्नुपर्ने कागजात:',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kNavyBlue)),
          const SizedBox(height: 6),
          for (final doc in [
            '१)  बाबु वा आमाको नागरिकता प्रमाण पत्रको प्रतिलिपि,',
            '२)  स्वास्थ्य संस्था/अस्पतालमा जन्म भएको भए उक्त संस्थाबाट जारी जन्म प्रतिवेदन,',
            '३)  घरमा जन्म भएको भए पछिल्लो खोप दिएको प्रमाण,',
            '४)  विदेशी भएमा बाबु, आमाको राहदानी प्रमाणपत्रको प्रतिलिपि तथा सम्बन्धित स्थानीय तहको वडामा बसोबास रहेको प्रमाण,',
            '५)  बाबु बेपत्ता वा ठेगाना थाहा नभएको भए सो सम्बन्धी प्रहरी प्रतिवेदन ।',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(doc,
                  style: const TextStyle(
                      fontSize: 11, color: kNavyBlue)),
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
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
            ),
            child: const Text('Submit / पेश गर्नुहोस्',
                style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: _clear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
            ),
            child: const Text('Clear / मेटाउनुहोस्',
                style: TextStyle(fontSize: 14)),
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
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: kNavyBlue)),
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
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(label,
            style: const TextStyle(fontSize: 12, color: kNavyBlue)),
      ],
    );
  }
}