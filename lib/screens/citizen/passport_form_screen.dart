import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/passport_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsewa/widgets/attached_document_viewer.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';
import 'package:smartsewa/widgets/base64_upload_widget.dart';
import 'package:intl/intl.dart';
import 'package:smartsewa/services/form_draft_service.dart';
import 'passport_payment_screen.dart';

class PassportFormScreen extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? initialData;
  final bool asSubView;
  final String? attachedDocumentBase64;

  const PassportFormScreen({
    super.key,
    this.readOnly = false,
    this.initialData,
    this.asSubView = false,
    this.attachedDocumentBase64,
  });

  @override
  State<PassportFormScreen> createState() =>
      _PassportFormScreenState();
}

class _PassportFormScreenState extends State<PassportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  String? _sex;

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


  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
      _sex = _formData['sex'];
      _appRegular = _formData['appRegular'] ?? false;
      _appEmergency = _formData['appEmergency'] ?? false;
      _docNew = _formData['docNew'] ?? false;
      _docRenewal = _formData['docRenewal'] ?? false;
      _docDamaged = _formData['docDamaged'] ?? false;
      _docLost = _formData['docLost'] ?? false;
      _docOrd34 = _formData['docOrd34'] ?? false;
      _docOrd96 = _formData['docOrd96'] ?? false;
      _docTemp = _formData['docTemp'] ?? false;
      _docTravel = _formData['docTravel'] ?? false;
      _docDiplomatic = _formData['docDiplomatic'] ?? false;
      _docOfficial = _formData['docOfficial'] ?? false;
    } else if (!widget.readOnly) {
      final draft = FormDraftService.getDraft('passport');
      if (draft != null) {
        _formData.addAll(draft);
        _sex = _formData['sex'];
        _appRegular = _formData['appRegular'] ?? false;
        _appEmergency = _formData['appEmergency'] ?? false;
        _docNew = _formData['docNew'] ?? false;
        _docRenewal = _formData['docRenewal'] ?? false;
        _docDamaged = _formData['docDamaged'] ?? false;
        _docLost = _formData['docLost'] ?? false;
        _docOrd34 = _formData['docOrd34'] ?? false;
        _docOrd96 = _formData['docOrd96'] ?? false;
        _docTemp = _formData['docTemp'] ?? false;
        _docTravel = _formData['docTravel'] ?? false;
        _docDiplomatic = _formData['docDiplomatic'] ?? false;
        _docOfficial = _formData['docOfficial'] ?? false;
      }
    }
  }

  @override
  void dispose() {
    if (!widget.readOnly && widget.initialData == null) {
      FormDraftService.saveDraft('passport', _formData);
    }
    super.dispose();
  }

  Future<void> _submit() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to submit a form.');
      }

      if (_sex == null) {
        throw Exception('Please select Sex / लिंग');
      }

      _formData['sex'] = _sex;
      _formData['appRegular'] = _appRegular;
      _formData['appEmergency'] = _appEmergency;
      _formData['docNew'] = _docNew;
      _formData['docRenewal'] = _docRenewal;
      _formData['docDamaged'] = _docDamaged;
      _formData['docLost'] = _docLost;
      _formData['docOrd34'] = _docOrd34;
      _formData['docOrd96'] = _docOrd96;
      _formData['docTemp'] = _docTemp;
      _formData['docTravel'] = _docTravel;
      _formData['docDiplomatic'] = _docDiplomatic;
      _formData['docOfficial'] = _docOfficial;

        final appData = {
          'applicant': '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}'.trim().isNotEmpty ? '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}' : 'Applicant',
          'citizenId': user.uid,
          'title': 'Passport',
          'type': 'Passport',
          'status': 'Pending',
          'formData': _formData,
          'createdAt': FieldValue.serverTimestamp(),
          'isHidden': false,
          if (widget.attachedDocumentBase64 != null)
            'attachedDocumentBase64': widget.attachedDocumentBase64,
        };
        // Save uploaded documents to user's global documents collection
        final docTypes = {
          'doc_citizenship': 'Passport: Citizenship',
          'doc_parents_citizenship': 'Passport: Parent Citizenship',
          'doc_marriage_certificate': 'Passport: Marriage Certificate',
        };
        
        final batch = FirebaseFirestore.instance.batch();
        final userDocsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('documents');
        
        for (final entry in docTypes.entries) {
          if (_formData[entry.key] != null && _formData[entry.key].toString().isNotEmpty) {
            final docRef = userDocsRef.doc(entry.key);
            batch.set(docRef, {
              'title': entry.value,
              'base64': _formData[entry.key],
              'uploadedAt': FieldValue.serverTimestamp(),
              'type': entry.key,
            });
          }
        }
        
        await batch.commit();

        await FirebaseFirestore.instance.collection('applications').add(appData);
        FormDraftService.clearDraft('passport');
        if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '✓ Your ePassport application has been submitted successfully!'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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
              FormDraftService.clearDraft('passport');
              Navigator.pop(context);
              _formKey.currentState?.reset();
              setState(() {
                _sex = null;
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
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// The actual form fields (no ScrollView / Screenshot wrapper).
  /// Used by both build() and _submit().
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                PassportSectionTitle('Personal Information / व्यक्तिगत विवरण'),
                _buildFieldLabel('1. Surname / थर *'),
                _buildPadded(Wrap(spacing: 12, runSpacing: 8, children: [PassportField(readOnly: widget.readOnly, label: 'थर\nSurname', width: 300, fieldKey: 'passportField1', dataMap: _formData)])),
                _buildFieldLabel('2. Given Names / नाम *'),
                _buildPadded(Row(children: [
                  NameSubField(nepLabel: 'पहिलो नाम', engLabel: 'First Name', flex: 1, fieldKey: 'nameSubField1', dataMap: _formData),
                  NameSubField(nepLabel: 'बिचको नाम', engLabel: 'Middle Name (Optional)', flex: 1, fieldKey: 'nameSubField2', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '3. Place of Birth / जन्मस्थान *\n(District / Country if Abroad)', width: 220, fieldKey: 'passportField2', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '4. Nationality / राष्ट्रियता *', width: 160, fieldKey: 'passportField3', dataMap: _formData),
                ])),
                _buildFieldLabel('5. Date of Birth / जन्म मिति (Year/Month/Day)'),
                _buildDOBRow(),
                _buildFieldLabel('6. Sex / लिंग *'),
                _buildPadded(_buildSexRow()),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '7. Citizenship or Permit No.\nनागरिकता/अनुमतिपत्र नं. *', width: 200, fieldKey: 'passportField4', dataMap: _formData),
                  PassportDateField(readOnly: widget.readOnly, label: '8. Date of Issue\n(YEAR/MONTH/DAY) *', width: 180, fieldKey: 'passportField5', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '9. Place of Issue / जारी भएको स्थान *', width: 200, fieldKey: 'passportField6', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '10. National Identity No.\nराष्ट्रिय परिचयपत्र नं.', width: 180, fieldKey: 'passportField7', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '11. Latest Passport or Travel Document No.\nपछिल्लो राहदानी वा यात्रा अनुमतिपत्र नं.', width: 230, fieldKey: 'passportField8', dataMap: _formData),
                  PassportDateField(readOnly: widget.readOnly, label: '11A. Date of Issue\nजारी मिति *', width: 160, fieldKey: 'passportField9', dataMap: _formData),
                ])),
                _buildPadded(PassportField(readOnly: widget.readOnly, label: '11B. Place of Issue / जारी भएको स्थान', width: 340, fieldKey: 'passportField10', dataMap: _formData)),
                PassportDivider(),
                PassportSectionTitle('12. Address / ठेगाना'),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportDropdownField(readOnly: widget.readOnly, label: '12A. Province / प्रदेश *', width: 180, items: const ['Koshi', 'Madhesh', 'Bagmati', 'Gandaki', 'Lumbini', 'Karnali', 'Sudurpashchim'], fieldKey: 'passportField11', dataMap: _formData),
                  PassportDropdownField(readOnly: widget.readOnly, label: '12B. District / जिल्ला *', width: 180, items: const ['Achham', 'Arghakhanchi', 'Baglung', 'Baitadi', 'Bajhang', 'Bajura', 'Banke', 'Bara', 'Bardiya', 'Bhaktapur', 'Bhojpur', 'Chitwan', 'Dadeldhura', 'Dailekh', 'Dang', 'Darchula', 'Dhading', 'Dhankuta', 'Dhanusha', 'Dolakha', 'Dolpa', 'Doti', 'Eastern Rukum', 'Gorkha', 'Gulmi', 'Humla', 'Ilam', 'Jajarkot', 'Jhapa', 'Jumla', 'Kailali', 'Kalikot', 'Kanchanpur', 'Kapilvastu', 'Kaski', 'Kathmandu', 'Kavrepalanchok', 'Khotang', 'Lalitpur', 'Lamjung', 'Mahottari', 'Makwanpur', 'Manang', 'Morang', 'Mugu', 'Mustang', 'Myagdi', 'Nawalpur', 'Nuwakot', 'Okhaldhunga', 'Palpa', 'Panchthar', 'Parbat', 'Parsa', 'Pyuthan', 'Ramechhap', 'Rasuwa', 'Rautahat', 'Rolpa', 'Rupandehi', 'Salyan', 'Sankhuwasabha', 'Saptari', 'Sarlahi', 'Sindhuli', 'Sindhupalchok', 'Siraha', 'Solukhumbu', 'Sunsari', 'Surkhet', 'Syangja', 'Tanahun', 'Taplejung', 'Terhathum', 'Udayapur', 'Western Rukum'], fieldKey: 'passportField12', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '12C. Rural Municipality / Municipality\nगाउँ/नगर पालिका *', width: 220, fieldKey: 'passportField13', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '12D. Ward No.\nवडा नं.', width: 80, fieldKey: 'passportField14', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '12E. Street/Village\nसडक/गाँउ *', width: 200, fieldKey: 'passportField15', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '12F. House No.\nघर नं. (Optional)', width: 100, fieldKey: 'passportField16', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '12G. Email / इमेल (Optional)', width: 220, keyboardType: TextInputType.emailAddress, fieldKey: 'passportField17', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '14. Phone No. / फोन नं. *', width: 160, keyboardType: TextInputType.phone, fieldKey: 'passportField18', dataMap: _formData),
                ])),
                PassportDivider(),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '15. Father\'s Full Name / बाबुको नाम, थर *', width: 240, fieldKey: 'passportField19', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '16. Mother\'s Full Name / आमाको नाम, थर *', width: 240, fieldKey: 'passportField20', dataMap: _formData),
                ])),
                PassportDivider(),
                PassportSectionTitle('17. Contact details in case of emergency / जरुरी परेका बखत सम्पर्क गर्ने व्यक्ति'),
                _buildPadded(PassportField(readOnly: widget.readOnly, label: '17A. Full Name / नाम, थर *', width: 340, fieldKey: 'passportField21', dataMap: _formData)),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '17C. Province / प्रदेश *', width: 180, fieldKey: 'passportField22', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '17D. District / जिल्ला *', width: 180, fieldKey: 'passportField23', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '17E. Municipality\nगाउँ/नगर पालिका *', width: 220, fieldKey: 'passportField24', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '17F. Ward No.\nवडा नं.', width: 80, fieldKey: 'passportField25', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '17G. Street/Village\nसडक/गाँउ *', width: 200, fieldKey: 'passportField26', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '17H. House No.\nघर नं. (Optional)', width: 100, fieldKey: 'passportField27', dataMap: _formData),
                ])),
                _buildPadded(Wrap(spacing: 20, runSpacing: 10, children: [
                  PassportField(readOnly: widget.readOnly, label: '18. Email / इमेल (Optional)', width: 220, keyboardType: TextInputType.emailAddress, fieldKey: 'passportField28', dataMap: _formData),
                  PassportField(readOnly: widget.readOnly, label: '19. Phone No. / फोन नं.', width: 160, keyboardType: TextInputType.phone, fieldKey: 'passportField29', dataMap: _formData),
                ])),
                PassportDivider(),
                _buildDeclaration(),
                PassportDivider(),
                _buildOfficeUse(),
                PassportDivider(),
                _buildUploads(),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget formBody = Form(
      key: _formKey,
      child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormContent(),
                if (!widget.readOnly) _buildFooter(),
                const SizedBox(height: 16),
                if (widget.readOnly || widget.attachedDocumentBase64 != null)
                  AttachedDocumentViewer(base64String: widget.attachedDocumentBase64),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );

    if (widget.asSubView) return formBody;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'Passport Application / राहदानी आवेदन',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: formBody,
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Container(height: 5, color: Colors.red.shade700, margin: const EdgeInsets.symmetric(horizontal: 16)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'अनुसूची-२\n(नियम ४ को उपनियम (५), नियम ६, नियम ९ को उपनियम (५), नियम १५ को उपनियम (५) र नियम १७ को उपनियम (२) सँग सम्बन्धित)\nराहदानी र यात्रा अनुमतिपत्रको विवरणको ढाँचा ख',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10, color: Colors.white70),
                ),
                SizedBox(height: 10),
                Text('GOVERNMENT OF NEPAL',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    'Ministry of Foreign Affairs, Department of Passports',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFFc0cfe8))),
                SizedBox(height: 8),
                Text('ePASSPORT APPLICATION FORM',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffd700))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 5, color: Colors.red.shade700, margin: const EdgeInsets.symmetric(horizontal: 16)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── DOB ROW ─────────────────────────────────────────────────────
  Widget _buildDOBRow() {
    return _buildPadded(
      Wrap(
        spacing: 20,
        runSpacing: 10,
        children: [
          PassportDateField(
            readOnly: widget.readOnly,
            label: 'Date of Birth (A.D.)\n(YEAR/MONTH/DAY)',
            width: 160,
            fieldKey: 'dob_ad',
            dataMap: _formData,
          ),
          PassportDateField(
            readOnly: widget.readOnly,
            label: 'Date of Birth (B.S.)\n(YEAR/MONTH/DAY)',
            width: 160,
            fieldKey: 'dob_bs',
            dataMap: _formData,
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
                onChanged: widget.readOnly ? null : (v) { setState(() => _sex = v!); _formData['sex'] = v; },
                activeColor: AppColors.teal,
              ),
              Text(e.$2,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87)),
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
        decoration: BoxDecoration(color: AppColors.navy.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'माथि उल्लेखित विवरण सत्यो हो । मैले प्रचलित कानूनअनुसार अपराध ठहरिने कुनै काम गरेको छैन । कानूनकमोजिम राहदानी प्रयोग गर्नेछु । यस फाराममा उल्लेखित मेरो विवरण नेपाल सरकारको अङ्ग, अप्रलत लक्ष्यपन्का कुनै सरकारी निकाय र राहदानीसँग सम्बन्धित कन्नसिदिए नियमनकारी निकासका प्रयोग गर्न मेरो मन्जुरी छ ।',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            if (!widget.readOnly) ...[
              const Text(
                "Applicant's Signature / Signature of Guardian (in case of minor)\nनिवेदकको सही / नाबालकको हकमा अभिभावकको सही *",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const SizedBox(height: 8),
              const SignaturePad(),
              const SizedBox(height: 16),
            ],
            PassportField(
              readOnly: true,
              label: 'Date / मिति *',
              width: 160,
              defaultValue: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              fieldKey: 'passportField31',
              dataMap: _formData,
            ),
          ],
        ),
      ),
    );
  }

  // ── OFFICE USE ONLY ─────────────────────────────────────────────
  Widget _buildOfficeUse() {
    return _buildPadded(
      Container(
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.05),
          border: Border.all(color: Colors.amber.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Please fill in the appropriate box with a tick mark ☑️.',
                style: TextStyle(
                    fontSize: 12, color: Colors.amber.shade700)),
            const SizedBox(height: 12),

            // Application type
            _officeRow('Application Type:', [
              _officeCheck('Regular', _appRegular,
                      (v) { setState(() => _appRegular = v!); _formData['appRegular'] = v; }),
              _officeCheck('Emergency', _appEmergency,
                      (v) { setState(() => _appEmergency = v!); _formData['appEmergency'] = v; }),
            ]),

            // Document status
            _officeRow('Document Status:', [
              _officeCheck('New', _docNew,
                      (v) { setState(() => _docNew = v!); _formData['docNew'] = v; }),
              _officeCheck('Renewal', _docRenewal,
                      (v) { setState(() => _docRenewal = v!); _formData['docRenewal'] = v; }),
              _officeCheck('Damaged', _docDamaged,
                      (v) { setState(() => _docDamaged = v!); _formData['docDamaged'] = v; }),
              _officeCheck('Lost', _docLost,
                      (v) { setState(() => _docLost = v!); _formData['docLost'] = v; }),
            ]),

            // Document type
            _officeRow('Document Type:', [
              _officeCheck('Ordinary (34 Pages)', _docOrd34,
                      (v) { setState(() => _docOrd34 = v!); _formData['docOrd34'] = v; }),
              _officeCheck('Ordinary (96 Pages)', _docOrd96,
                      (v) { setState(() => _docOrd96 = v!); _formData['docOrd96'] = v; }),
              _officeCheck('Temporary', _docTemp,
                      (v) { setState(() => _docTemp = v!); _formData['docTemp'] = v; }),
              _officeCheck('Travel Document', _docTravel,
                      (v) { setState(() => _docTravel = v!); _formData['docTravel'] = v; }),
              _officeCheck('Diplomatic', _docDiplomatic,
                      (v) { setState(() => _docDiplomatic = v!); _formData['docDiplomatic'] = v; }),
              _officeCheck('Official', _docOfficial,
                      (v) { setState(() => _docOfficial = v!); _formData['docOfficial'] = v; }),
            ]),
          ],
        ),
      ),
    );
  }

  // ── UPLOADS ─────────────────────────────────────────────────────
  Widget _buildUploads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Documents / कागजातहरू',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
        ),
        Base64UploadWidget(
          title: 'नेपाली नागरिकताको प्रमाणपत्रको सक्कल अथवा (for minor) जन्म खुलाउने प्रमाणपत्र',
          subtitle: 'अनिवार्य / compulsory',
          initialBase64: _formData['doc_citizenship'],
          icon: Icons.badge_outlined,
          onImageChanged: widget.readOnly ? (val) {} : (val) => setState(() => _formData['doc_citizenship'] = val),
        ),
        Base64UploadWidget(
          title: 'बाबुआमाको नागरिकताको प्रमाण',
          subtitle: 'ऐच्छिक / optional',
          initialBase64: _formData['doc_parents_citizenship'],
          icon: Icons.people_outline,
          onImageChanged: widget.readOnly ? (val) {} : (val) => setState(() => _formData['doc_parents_citizenship'] = val),
        ),
        Base64UploadWidget(
          title: 'बाबुआमाको विवाहदर्ताको प्रमाण',
          subtitle: 'ऐच्छिक / optional',
          initialBase64: _formData['doc_marriage_certificate'],
          icon: Icons.description_outlined,
          onImageChanged: widget.readOnly ? (val) {} : (val) => setState(() => _formData['doc_marriage_certificate'] = val),
        ),
      ],
    );
  }

  // ── FOOTER ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Please review your details by tapping "Preview" before submitting.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _showPreview,
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('Preview / पूर्वावलोकन',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Collect current bool values into formData before navigating
                  final data = Map<String, dynamic>.from(_formData);
                  data['sex'] = _sex;
                  data['appRegular'] = _appRegular;
                  data['appEmergency'] = _appEmergency;
                  data['docNew'] = _docNew;
                  data['docRenewal'] = _docRenewal;
                  data['docDamaged'] = _docDamaged;
                  data['docLost'] = _docLost;
                  data['docOrd34'] = _docOrd34;
                  data['docOrd96'] = _docOrd96;
                  data['docTemp'] = _docTemp;
                  data['docTravel'] = _docTravel;
                  data['docDiplomatic'] = _docDiplomatic;
                  data['docOfficial'] = _docOfficial;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassportPaymentScreen(
                        formData: data,
                        attachedDocumentBase64: widget.attachedDocumentBase64,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Submit Application',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset Form',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '* Required fields  |  Ministry of Foreign Affairs, Nepal  |  ePassport Division',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    _formKey.currentState?.save();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.97,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 2),
                width: 44, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.navy,
                child: Row(
                  children: [
                    const Icon(Icons.preview_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Passport Application Preview', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    IgnorePointer(
                      child: _buildFormContent(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _submit();
                      },
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Submit Application / पेश गर्नुहोस्', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 2),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.navy)),
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
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
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
          onChanged: widget.readOnly ? null : onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: AppColors.teal,
        ),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade800)),
      ],
    );
  }
}