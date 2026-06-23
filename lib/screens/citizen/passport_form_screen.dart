import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/passport_widgets.dart';

class PassportFormScreen extends StatefulWidget {
  const PassportFormScreen({super.key});

  @override
  State<PassportFormScreen> createState() =>
      _PassportFormScreenState();
}

class _PassportFormScreenState extends State<PassportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _sex = 'M';

  // Application type checkboxes
  bool _appRegular = false;
  bool _appEmergency = false;

  // Document status
  bool _docNew = false;
  bool _docRenewal = false;
  bool _docDamaged = false;
  bool _docLost = false;

  // Document type
  bool _docOrd34 = false;
  bool _docOrd96 = false;
  bool _docTemp = false;
  bool _docTravel = false;
  bool _docDiplomatic = false;
  bool _docOfficial = false;

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            '✓ Your ePassport application has been submitted successfully!'),
        backgroundColor: kGovBlue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Form'),
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
              setState(() {
                _sex = 'M';
                _appRegular = false;
                _appEmergency = false;
                _docNew = false;
                _docRenewal = false;
                _docDamaged = false;
                _docLost = false;
                _docOrd34 = false;
                _docOrd96 = false;
                _docTemp = false;
                _docTravel = false;
                _docDiplomatic = false;
                _docOfficial = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('↺ Form has been reset'),
                    backgroundColor: Colors.grey),
              );
            },
            child: const Text('Reset',
                style: TextStyle(color: kNepalRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgRoot,
      appBar: AppBar(
        backgroundColor: kGovBlue,
        title: const Text(
          'Passport Application / राहदानी आवेदन',
          style: TextStyle(color: Colors.white, fontSize: 15),
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
              Container(
                color: kBgCard,
                margin: const EdgeInsets.symmetric(
                    horizontal: 2, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information
                    const PassportSectionTitle(
                        'Personal Information / व्यक्तिगत विवरण'),

                    // 1. Surname
                    _buildFieldLabel('1. Surname / थर *'),
                    _buildPadded(
                      Wrap(spacing: 12, runSpacing: 8, children: const [
                        PassportField(label: 'थर\nSurname', width: 300),
                      ]),
                    ),

                    // 2. Given Names
                    _buildFieldLabel('2. Given Names / नाम *'),
                    _buildPadded(
                      Row(children: const [
                        NameSubField(
                            nepLabel: 'पहिलो नाम',
                            engLabel: 'First Name',
                            flex: 3),
                        NameSubField(
                            nepLabel: 'बिचको नाम',
                            engLabel: 'Middle Name',
                            flex: 2),
                        NameSubField(
                            nepLabel: 'थर',
                            engLabel: 'Last Name',
                            flex: 2),
                      ]),
                    ),

                    // 3 & 4
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                          label:
                          '3. Place of Birth / जन्मस्थान *\n(District / Country if Abroad)',
                          width: 220,
                        ),
                        PassportField(
                          label: '4. Nationality / राष्ट्रियता *',
                          width: 160,
                          defaultValue: 'NEPALI',
                        ),
                      ],
                    )),

                    // 5. DOB
                    _buildFieldLabel(
                        '5. Date of Birth / जन्म मिति (Year/Month/Day)'),
                    _buildDOBRow(),

                    // 6. Sex
                    _buildFieldLabel('6. Sex / लिंग *'),
                    _buildPadded(_buildSexRow()),

                    // 7, 8, 9, 10
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '7. Citizenship or Permit No.\nनागरिकता/अनुमतिपत्र नं. *',
                            width: 200),
                        PassportField(
                            label:
                            '8. Date of Issue\n(YEAR/MONTH/DAY) *',
                            width: 180),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '9. Place of Issue / जारी भएको स्थान *',
                            width: 200),
                        PassportField(
                            label:
                            '10. National Identity No.\nराष्ट्रिय परिचयपत्र नं.',
                            width: 180),
                      ],
                    )),

                    // 11, 11A, 11B
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '11. Latest Passport or Travel Document No.\nपछिल्लो राहदानी वा यात्रा अनुमतिपत्र नं.',
                            width: 230),
                        PassportField(
                            label:
                            '11A. Date of Issue\nजारी मिति *',
                            width: 160),
                      ],
                    )),
                    _buildPadded(const PassportField(
                        label: '11B. Place of Issue / जारी भएको स्थान',
                        width: 340)),

                    const PassportDivider(),

                    // Address
                    const PassportSectionTitle(
                        '12. Address / ठेगाना'),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '12A. Province / प्रदेश *',
                            width: 180),
                        PassportField(
                            label: '12B. District / जिल्ला *',
                            width: 180),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '12C. Rural Municipality / Municipality\nगाउँ/नगर पालिका *',
                            width: 220),
                        PassportField(
                            label: '12D. Ward No.\nवडा नं.',
                            width: 80),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '12E. Street/Village\nसडक/गाँउ *',
                            width: 200),
                        PassportField(
                            label: '12F. House No.\nघर नं.',
                            width: 100),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '12G. Email / इमेल',
                            width: 220,
                            keyboardType: TextInputType.emailAddress),
                        PassportField(
                            label: '14. Phone No. / फोन नं. *',
                            width: 160,
                            keyboardType: TextInputType.phone),
                      ],
                    )),

                    const PassportDivider(),

                    // 15 & 16 Parents
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '15. Father\'s Full Name / बाबुको नाम, थर *',
                            width: 240),
                        PassportField(
                            label:
                            '16. Mother\'s Full Name / आमाको नाम, थर *',
                            width: 240),
                      ],
                    )),

                    const PassportDivider(),

                    // 17. Emergency contact
                    const PassportSectionTitle(
                        '17. Contact details in case of emergency / जरुरी परेका बखत सम्पर्क गर्ने व्यक्ति'),

                    _buildPadded(const PassportField(
                        label: '17A. Full Name / नाम, थर *',
                        width: 340)),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '17C. Province / प्रदेश *',
                            width: 180),
                        PassportField(
                            label: '17D. District / जिल्ला *',
                            width: 180),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label:
                            '17E. Municipality\nगाउँ/नगर पालिका *',
                            width: 220),
                        PassportField(
                            label: '17F. Ward No.\nवडा नं.',
                            width: 80),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '17G. Street/Village\nसडक/गाँउ *',
                            width: 200),
                        PassportField(
                            label: '17H. House No.\nघर नं.',
                            width: 100),
                      ],
                    )),
                    _buildPadded(Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: const [
                        PassportField(
                            label: '18. Email / इमेल',
                            width: 220,
                            keyboardType: TextInputType.emailAddress),
                        PassportField(
                            label: '19. Phone No. / फोन नं.',
                            width: 160,
                            keyboardType: TextInputType.phone),
                      ],
                    )),

                    const PassportDivider(),

                    // Declaration
                    _buildDeclaration(),

                    const PassportDivider(),

                    // Appointment details
                    _buildAppointment(),

                    const PassportDivider(),

                    // Office use only
                    _buildOfficeUse(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Footer buttons
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: kGovBlue,
      child: Column(
        children: [
          Container(height: 5, color: kNepalRed),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                Text(
                  'अनुसूची-२\n(नियम ४ को उपनियम (५), नियम ६, नियम ९ को उपनियम (५), नियम १५ को उपनियम (५) र नियम १७ को उपनियम (२) सँग सम्बन्धित)\nराहदानी र यात्रा अनुमतिपत्रको विवरणको ढाँचा ख',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10, color: Colors.white70),
                ),
                SizedBox(height: 6),
                Text('GOVERNMENT OF NEPAL',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    'Ministry of Foreign Affairs, Department of Passports',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFFc0cfe8))),
                SizedBox(height: 6),
                Text('ePASSPORT APPLICATION FORM',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffd700))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 5, color: kNepalRed),
        ],
      ),
    );
  }

  // ── DOB ROW ─────────────────────────────────────────────────────
  Widget _buildDOBRow() {
    return _buildPadded(
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final e in [
            ('वर्ष', 'YEAR (A.D.)', 70),
            ('महिना', 'MONTH', 55),
            ('दिन', 'DAY', 50),
            ('वर्ष (B.S.)', 'YEAR (B.S.)', 70),
            ('महिना', 'MONTH', 55),
            ('दिन', 'DAY', 50),
          ])
            SizedBox(
              width: e.$3.toDouble(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.$1,
                      style: const TextStyle(
                          fontSize: 10, color: kTextMid)),
                  const SizedBox(height: 3),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: kEntryBg,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(e.$2,
                      style: const TextStyle(
                          fontSize: 9, color: kTextLight)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── SEX ROW ─────────────────────────────────────────────────────
  Widget _buildSexRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final e in [
          ('M', 'M for Male / पुरुष'),
          ('F', 'F for Female / महिला'),
          ('X', 'X for Others / अन्य'),
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: e.$1,
                groupValue: _sex,
                onChanged: (v) => setState(() => _sex = v!),
                materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
              ),
              Text(e.$2,
                  style: const TextStyle(
                      fontSize: 12, color: kTextMid)),
              const SizedBox(width: 12),
            ],
          ),
      ],
    );
  }

  // ── DECLARATION ─────────────────────────────────────────────────
  Widget _buildDeclaration() {
    return _buildPadded(
      Container(
        color: kBgSection,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'माथि उल्लेखित विवरण सत्यो हो । मैले प्रचलित कानूनअनुसार अपराध ठहरिने कुनै काम गरेको छैन । कानूनकमोजिम राहदानी प्रयोग गर्नेछु । यस फाराममा उल्लेखित मेरो विवरण नेपाल सरकारको अङ्ग, अप्रलत लक्ष्यपन्का कुनै सरकारी निकाय र राहदानीसँग सम्बन्धित कन्नसिदिए नियमनकारी निकासका प्रयोग गर्न मेरो मन्जुरी छ ।',
              style: TextStyle(fontSize: 11, color: kTextMid),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: const [
                PassportField(
                  label:
                  'Applicant\'s Signature / Signature of Guardian (in case of minor)\nनिवेदकको सही / नाबालकको हकमा अभिभावकको सही *',
                  width: 260,
                ),
                PassportField(
                    label: 'Date / मिति *', width: 160),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── APPOINTMENT ─────────────────────────────────────────────────
  Widget _buildAppointment() {
    return _buildPadded(
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            color: kBgSection,
            border: Border.all(color: kBorderColor),
          ),
          padding: const EdgeInsets.all(12),
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Appointment Details',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: kTextDark)),
              SizedBox(height: 8),
              PassportField(
                  label: 'Enrollment Center:', width: 200),
              SizedBox(height: 8),
              PassportField(
                  label: 'Date & Time:', width: 200),
            ],
          ),
        ),
      ),
    );
  }

  // ── OFFICE USE ONLY ─────────────────────────────────────────────
  Widget _buildOfficeUse() {
    return _buildPadded(
      Container(
        decoration: BoxDecoration(
          color: kBgOffice,
          border: Border.all(color: kBorderColor),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FOR OFFICE USE ONLY ▼',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
            const Text(
                'Please fill in the appropriate box with an \'X\' mark.',
                style: TextStyle(
                    fontSize: 11, color: kTextMid)),
            const SizedBox(height: 10),

            // Application type
            _officeRow('Application Type:', [
              _officeCheck('Regular', _appRegular,
                      (v) => setState(() => _appRegular = v!)),
              _officeCheck('Emergency', _appEmergency,
                      (v) => setState(() => _appEmergency = v!)),
            ]),

            // Document status
            _officeRow('Document Status:', [
              _officeCheck('New', _docNew,
                      (v) => setState(() => _docNew = v!)),
              _officeCheck('Renewal', _docRenewal,
                      (v) => setState(() => _docRenewal = v!)),
              _officeCheck('Damaged', _docDamaged,
                      (v) => setState(() => _docDamaged = v!)),
              _officeCheck('Lost', _docLost,
                      (v) => setState(() => _docLost = v!)),
            ]),

            // Document type
            _officeRow('Document Type:', [
              _officeCheck('Ordinary (34 Pages)', _docOrd34,
                      (v) => setState(() => _docOrd34 = v!)),
              _officeCheck('Ordinary (96 Pages)', _docOrd96,
                      (v) => setState(() => _docOrd96 = v!)),
              _officeCheck('Temporary', _docTemp,
                      (v) => setState(() => _docTemp = v!)),
              _officeCheck('Travel Document', _docTravel,
                      (v) => setState(() => _docTravel = v!)),
              _officeCheck('Diplomatic', _docDiplomatic,
                      (v) => setState(() => _docDiplomatic = v!)),
              _officeCheck('Official', _docOfficial,
                      (v) => setState(() => _docOfficial = v!)),
            ]),

            const SizedBox(height: 10),

            // Verifying officer
            const Text('Verifying Officer',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: const [
                PassportField(
                    label: 'Name:', width: 160),
                PassportField(
                    label: 'Signature:', width: 140),
                PassportField(
                    label: 'Designation:', width: 160),
                PassportField(
                    label: 'Date:', width: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── FOOTER ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: kBgCard,
      padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Submit Application',
                    style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGovBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset Form',
                    style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '* Required fields  |  Ministry of Foreign Affairs, Nepal  |  ePassport Division',
            style: TextStyle(fontSize: 11, color: kTextLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────
  Widget _buildPadded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 6),
      child: child,
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 2),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kTextDark)),
    );
  }

  Widget _officeRow(String label, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _officeCheck(
      String label, bool value, void Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: kTextMid)),
      ],
    );
  }
}