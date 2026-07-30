
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/birth_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsewa/widgets/attached_document_viewer.dart';
import 'package:smartsewa/services/form_draft_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BirthFormScreen extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? initialData;
  final bool asSubView;
  final String? attachedDocumentBase64;

  const BirthFormScreen({
    super.key,
    this.readOnly = false,
    this.initialData,
    this.asSubView = false,
    this.attachedDocumentBase64,
  });

  @override
  State<BirthFormScreen> createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

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

  // ID type selection for father/mother: 'nid' or 'citizenship'
  String? _fatherIdType;
  String? _motherIdType;

  // Upload docs
  String? _docParentCitizenship;
  String? _docBirthProof;
  String? _docForeignPassport;
  String? _docResidenceProof;
  String? _docPoliceReport;
  String? _docInformantSignature;

  static const List<String> _provinces = [
    'कोशी प्रदेश (प्रदेश नं. १)',
    'मधेश प्रदेश (प्रदेश नं. २)',
    'बागमती प्रदेश (प्रदेश नं. ३)',
    'गण्डकी प्रदेश (प्रदेश नं. ४)',
    'लुम्बिनी प्रदेश (प्रदेश नं. ५)',
    'कर्णाली प्रदेश (प्रदेश नं. ६)',
    'सुदूरपश्चिम प्रदेश (प्रदेश नं. ७)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
      _birthType = _formData['birthType'];
      _gender = _formData['gender'];
      _attendant = _formData['attendant'];
      _process = _formData['process'];
      _fatherIdType = _formData['fatherIdType'];
      _motherIdType = _formData['motherIdType'];
      _docParentCitizenship = _formData['doc_parentCitizenship'];
      _docBirthProof = _formData['doc_birthProof'];
      _docForeignPassport = _formData['doc_foreignPassport'];
      _docResidenceProof = _formData['doc_residenceProof'];
      _docPoliceReport = _formData['doc_policeReport'];
      _docInformantSignature = _formData['doc_informantSignature'];
    } else if (!widget.readOnly) {
      final draft = FormDraftService.getDraft('birth');
      if (draft != null) {
        _formData.addAll(draft);
        _birthType = _formData['birthType'];
        _gender = _formData['gender'];
        _attendant = _formData['attendant'];
        _process = _formData['process'];
        _fatherIdType = _formData['fatherIdType'];
        _motherIdType = _formData['motherIdType'];
        _docParentCitizenship = _formData['doc_parentCitizenship'];
        _docBirthProof = _formData['doc_birthProof'];
        _docForeignPassport = _formData['doc_foreignPassport'];
        _docResidenceProof = _formData['doc_residenceProof'];
        _docPoliceReport = _formData['doc_policeReport'];
        _docInformantSignature = _formData['doc_informantSignature'];
      }
    }
    // Auto-fill form date
    if (_formData['formFillDate'] == null || (_formData['formFillDate'] as String?)?.isEmpty == true) {
      _formData['formFillDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    if (!widget.readOnly && widget.initialData == null) {
      _formData['gender'] = _gender;
      _formData['birthType'] = _birthType;
      _formData['attendant'] = _attendant;
      _formData['process'] = _process;
      _formData['fatherIdType'] = _fatherIdType;
      _formData['motherIdType'] = _motherIdType;
      _formData['doc_parentCitizenship'] = _docParentCitizenship;
      _formData['doc_birthProof'] = _docBirthProof;
      _formData['doc_foreignPassport'] = _docForeignPassport;
      _formData['doc_residenceProof'] = _docResidenceProof;
      _formData['doc_policeReport'] = _docPoliceReport;
      _formData['doc_informantSignature'] = _docInformantSignature;
      FormDraftService.saveDraft('birth', _formData);
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

      _formData['gender'] = _gender;
      _formData['birthType'] = _birthType;
      _formData['attendant'] = _attendant;
      _formData['process'] = _process;
      _formData['fatherIdType'] = _fatherIdType;
      _formData['motherIdType'] = _motherIdType;
      _formData['doc_parentCitizenship'] = _docParentCitizenship;
      _formData['doc_birthProof'] = _docBirthProof;
      _formData['doc_foreignPassport'] = _docForeignPassport;
      _formData['doc_residenceProof'] = _docResidenceProof;
      _formData['doc_policeReport'] = _docPoliceReport;
      _formData['doc_informantSignature'] = _docInformantSignature;

      final appData = {
        'type': 'Birth Registration',
        'title': 'Birth Registration',
        'applicant': '${_formData['childName_firstName'] ?? ''} ${_formData['childName_lastName'] ?? ''}'.trim(),
        'userId': user.uid,
        'citizenId': user.uid,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'formData': _formData,
        'isHidden': false,
        if (widget.attachedDocumentBase64 != null)
          'attachedDocumentBase64': widget.attachedDocumentBase64,
      };

      // Save uploaded docs to global documents
      final batch = FirebaseFirestore.instance.batch();
      final userDocsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('documents');

      final docTypes = {
        'doc_parentCitizenship': 'Birth Reg: Parent Citizenship',
        'doc_birthProof': 'Birth Reg: Birth Proof',
        'doc_foreignPassport': 'Birth Reg: Foreign Passport',
        'doc_residenceProof': 'Birth Reg: Residence Proof',
        'doc_policeReport': 'Birth Reg: Police Report',
        'doc_informantSignature': 'Birth Reg: Informant Signature',
      };
      for (final entry in docTypes.entries) {
        final val = _formData[entry.key];
        if (val != null && val.toString().isNotEmpty) {
          batch.set(userDocsRef.doc(entry.key), {
            'title': entry.value,
            'base64': val,
            'uploadedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();

      await FirebaseFirestore.instance.collection('applications').add(appData);
      FormDraftService.clearDraft('birth');

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

  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BirthFormScreen(
          readOnly: true,
          initialData: Map<String, dynamic>.from(_formData)
            ..['gender'] = _gender
            ..['birthType'] = _birthType
            ..['attendant'] = _attendant
            ..['process'] = _process
            ..['doc_parentCitizenship'] = _docParentCitizenship
            ..['doc_birthProof'] = _docBirthProof
            ..['doc_foreignPassport'] = _docForeignPassport
            ..['doc_residenceProof'] = _docResidenceProof
            ..['doc_policeReport'] = _docPoliceReport
            ..['doc_informantSignature'] = _docInformantSignature,
          asSubView: false,
        ),
      ),
    );
  }

  void _clear() {
    FormDraftService.clearDraft('birth');
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
      _fatherIdType = null;
      _motherIdType = null;
      _docParentCitizenship = null;
      _docBirthProof = null;
      _docForeignPassport = null;
      _docResidenceProof = null;
      _docPoliceReport = null;
      _docInformantSignature = null;
      _formData.clear();
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
    Widget formBody = Form(
      key: _formKey,
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
                    const SizedBox(height: 16),
                    if (widget.readOnly || widget.attachedDocumentBase64 != null)
                      AttachedDocumentViewer(base64String: widget.attachedDocumentBase64),
                    if (!widget.readOnly) _buildButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.asSubView) return formBody;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('जन्म दर्ता / Birth Registration',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: formBody,
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
                Row(
                  children: [
                    BirthLabeledField(readOnly: widget.readOnly, label: 'वडा नं.', width: 80, fieldKey: 'wardNo', dataMap: _formData),
                    const SizedBox(width: 16),
                    BirthLabeledField(readOnly: widget.readOnly, label: 'ग.वि.स./न.पा.', width: 160, isExpanded: true, fieldKey: 'municipality', dataMap: _formData),
                  ],
                ),
                const SizedBox(height: 10),
                BirthLabeledField(readOnly: widget.readOnly, label: 'जिल्ला:', width: 200, fieldKey: 'district', dataMap: _formData),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text('निम्न लिखित विवरण खुलाई मेरो',
                        style: TextStyle(fontSize: 13)),
                    BirthLabeledField(readOnly: widget.readOnly, label: '', width: 180, hint: 'सम्बन्ध', fieldKey: 'informantRelation', dataMap: _formData),
                    const Text('को जन्मको सूचना दिन आएको छु ।',
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
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'childName', dataMap: _formData),
          const SizedBox(height: 12),
          // English name
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'childNameEn', dataMap: _formData),
          const SizedBox(height: 16),

          // DOB
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BirthDateEntry(readOnly: widget.readOnly, label: 'जन्म मिति वि.सं.:', fieldKey: 'dobBS', dataMap: _formData),
              BirthDateEntry(readOnly: widget.readOnly, label: 'ई.सं.:', fieldKey: 'dobAD', dataMap: _formData),
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
              _checkItem('घर', _placeHome, (v) => setState(() => _placeHome = v!)),
              _checkItem('स्वास्थ्य', _placeHealth, (v) => setState(() => _placeHealth = v!)),
              _checkItem('संस्था', _placeSanstha, (v) => setState(() => _placeSanstha = v!)),
              _checkItem('अस्पताल', _placeHospital, (v) => setState(() => _placeHospital = v!)),
              _checkItem('अन्य', _placeOther, (v) => setState(() => _placeOther = v!)),
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
              for (final e in [('पुरुष', 'M'), ('महिला', 'F'), ('अन्य', 'O')])
                _radioItem(e.$1, e.$2, _gender, (v) => setState(() => _gender = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Birth address
          const Text('बच्चा जन्मेको ठेगाना / Child\'s Birth Address:',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Province dropdown
          _provinceDropdown('birthProvince', 'प्रदेश:'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            BirthLabeledField(readOnly: widget.readOnly, label: 'ग.पा./न.पा.:', width: 140, isExpanded: true, fieldKey: 'birthMunicipality', dataMap: _formData),
            const SizedBox(width: 12),
            BirthLabeledField(readOnly: widget.readOnly, label: 'वडा नं.:', width: 60, fieldKey: 'birthWard', dataMap: _formData),
          ]),
          const SizedBox(height: 16),

          // Born abroad
          const Text('विदेशमा जन्मेको भए / If born abroad:',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            BirthLabeledField(readOnly: widget.readOnly, label: 'देश/Country: (ऐच्छिक)', width: 120, isExpanded: true, fieldKey: 'abroadCountry', dataMap: _formData, isOptional: true),
            const SizedBox(width: 12),
            BirthLabeledField(readOnly: widget.readOnly, label: 'Province/State: (ऐच्छिक)', width: 120, isExpanded: true, fieldKey: 'abroadState', dataMap: _formData, isOptional: true),
            const SizedBox(width: 12),
            BirthLabeledField(readOnly: widget.readOnly, label: 'Local Address: (ऐच्छिक)', width: 150, isExpanded: true, fieldKey: 'abroadLocalAddr', dataMap: _formData, isOptional: true),
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
              for (final e in ['एकल', 'जुम्ल्याहा', 'तिम्ल्याहा', 'सो भन्दा बढी'])
                _radioItem(e, e, _birthType, (v) => setState(() => _birthType = v)),
            ],
          ),
          const SizedBox(height: 16),

          // Birth weight — OPTIONAL
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              BirthLabeledField(
                readOnly: widget.readOnly,
                label: 'बच्चा जन्मेको तौल (ग्राम): (ऐच्छिक)',
                width: 100,
                fieldKey: 'birthWeight',
                dataMap: _formData,
              ),
              const Text('ग्राम', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _weightUnknown,
                    activeColor: AppColors.teal,
                    onChanged: widget.readOnly ? null : (v) => setState(() => _weightUnknown = v!),
                  ),
                  const Text('थाहा नभएको / Unknown',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Birth attendant — OPTIONAL
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('मद्दत गर्ने व्यक्ति / Birth Attendant: (ऐच्छिक)',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in ['डाक्टर', 'नर्स/अनमी', 'परम्परागत सुडिनी', 'तालिम प्राप्त सुडिनी', 'घर परिवारका सदस्य'])
                _radioItem(e, e, _attendant, (v) => setState(() => _attendant = v)),
            ],
          ),
          const SizedBox(height: 8),
          BirthLabeledField(readOnly: widget.readOnly, label: '☐ अन्य/Other:', width: 200, fieldKey: 'otherAttendant', dataMap: _formData),
          const SizedBox(height: 16),

          // Birth process
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('जन्म प्रक्रिया / Birth Process:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
              for (final e in ['सामान्य', 'औजार', 'शल्यक्रिया', 'भ्याकुम', 'फर्सेप'])
                _radioItem(e, e, _process, (v) => setState(() => _process = v)),
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
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'grandfatherName', dataMap: _formData),
          const SizedBox(height: 8),
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'grandfatherNameEn', dataMap: _formData),
          const BirthFormDivider(),
          const Text('ख) बज्यैको नाम:-',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'grandmotherName', dataMap: _formData),
          const SizedBox(height: 8),
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'grandmotherNameEn', dataMap: _formData),
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
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'fatherName', dataMap: _formData),
          const SizedBox(height: 8),
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'fatherNameEn', dataMap: _formData),
          const BirthFormDivider(),

          // Mother
          const Text('ख) आमाको नाम:-',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'motherName', dataMap: _formData),
          const SizedBox(height: 8),
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'motherNameEn', dataMap: _formData),
          const BirthFormDivider(),

          // Details table
          const Text('स्थायी ठेगाना तथा अन्य विवरण:',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildParentsTable(),
        ],
      ),
    );
  }

  Widget _buildParentsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.navy.withOpacity(0.06),
            child: Row(
              children: [
                Expanded(flex: 3, child: _tableHeader('स्थायी ठेगाना')),
                Container(width: 1, height: 42, color: Colors.grey.shade300),
                Expanded(flex: 2, child: _tableHeader('बाबुको विवरण')),
                Container(width: 1, height: 42, color: Colors.grey.shade300),
                Expanded(flex: 2, child: _tableHeader('आमाको विवरण')),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),

          // Province — dropdown row
          _tableRowCustom(
            'प्रदेश',
            _provinceDropdownCell('fatherProvince'),
            _provinceDropdownCell('motherProvince'),
          ),

          _tableTextRow('गा.पा./न.पा.', 'fatherMunicipality', 'motherMunicipality'),
          _tableTextRow('वडा नं.', 'fatherWard', 'motherWard'),
          _tableTextRow('सडक/मार्ग', 'fatherRoad', 'motherRoad'),
          // गाउँ/टोल — optional
          _tableTextRowOptional('गाउँ/टोल (ऐच्छिक)', 'fatherVillage', 'motherVillage'),
          // घर नं — optional
          _tableTextRowOptional('घर नं. (ऐच्छिक)', 'fatherHouseNo', 'motherHouseNo'),

          // ID type selector
          _tableRowCustom(
            'राष्ट्रिय परिचय नं. / नागरिकता प्र.प.नं.',
            _idTypeColumn('father', _fatherIdType, (v) => setState(() => _fatherIdType = v)),
            _idTypeColumn('mother', _motherIdType, (v) => setState(() => _motherIdType = v)),
          ),

          // Foreign passport — optional
          _tableTextRowOptional('विदेशी भएमा पासपोर्ट नं. र देशको नाम (ऐच्छिक)', 'fatherForeignPassport', 'motherForeignPassport'),

          // Marriage details — shared single row for both
          _tableSharedRow('विवाह दर्ता नं.', 'marriageRegNo'),
          _tableSharedRow('विवाह भएको मिति (वि.सं.)', 'marriageDateBS'),
          _tableSharedRow('विवाह भएको मिति (ई.सं.)', 'marriageDateAD'),

          _tableTextRow('जन्म मिति (वि.सं.)', 'fatherDobBS', 'motherDobBS'),
          _tableTextRow('जन्म मिति (ई.सं.)', 'fatherDobAD', 'motherDobAD'),
          // Education — optional
          _tableTextRowOptional('शैक्षिक स्तर (ऐच्छिक)', 'fatherEducation', 'motherEducation'),
          _tableTextRow('पेशा', 'fatherOccupation', 'motherOccupation'),
          _tableTextRow('धर्म', 'fatherReligion', 'motherReligion'),
          _tableTextRow('जात', 'fatherCaste', 'motherCaste'),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
  );

  Widget _tableTextRow(String label, String fKey, String mKey) {
    return _tableRowCustom(
      label,
      _tableFieldCell(fKey),
      _tableFieldCell(mKey),
    );
  }

  Widget _tableTextRowOptional(String label, String fKey, String mKey) {
    return _tableRowCustom(
      label,
      _tableFieldCell(fKey, optional: true),
      _tableFieldCell(mKey, optional: true),
    );
  }

  Widget _tableSharedRow(String label, String sharedKey) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade200),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: TextFormField(
                readOnly: widget.readOnly,
                initialValue: _formData[sharedKey],
                onChanged: (v) => _formData[sharedKey] = v,
                decoration: _cellDecor(),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRowCustom(String label, Widget fatherCell, Widget motherCell) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade200),
          Expanded(flex: 2, child: fatherCell),
          Container(width: 1, color: Colors.grey.shade200),
          Expanded(flex: 2, child: motherCell),
        ],
      ),
    );
  }

  Widget _tableFieldCell(String fieldKey, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextFormField(
        readOnly: widget.readOnly,
        initialValue: _formData[fieldKey],
        onChanged: (v) => _formData[fieldKey] = v,
        decoration: _cellDecor(),
        style: const TextStyle(fontSize: 13),
        validator: optional ? null : null,
      ),
    );
  }

  Widget _provinceDropdownCell(String fieldKey) {
    if (widget.readOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(_formData[fieldKey] ?? '', style: const TextStyle(fontSize: 12)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _formData[fieldKey],
        decoration: _cellDecor(),
        style: const TextStyle(fontSize: 12, color: Colors.black87),
        isExpanded: true,
        hint: const Text('छान्नुस्', style: TextStyle(fontSize: 11)),
        items: _provinces
            .map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11))))
            .toList(),
        onChanged: (v) => setState(() => _formData[fieldKey] = v),
      ),
    );
  }

  Widget _idTypeColumn(String prefix, String? selectedType, void Function(String?) onChanged) {
    if (widget.readOnly) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(_formData['${prefix}IdValue'] ?? '', style: const TextStyle(fontSize: 12)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Radio<String>(
                value: 'nid',
                groupValue: selectedType,
                onChanged: onChanged,
                activeColor: AppColors.teal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Flexible(child: Text('रा.प.नं.', style: TextStyle(fontSize: 11))),
            ],
          ),
          Row(
            children: [
              Radio<String>(
                value: 'citizenship',
                groupValue: selectedType,
                onChanged: onChanged,
                activeColor: AppColors.teal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Flexible(child: Text('नागरिकता नं.', style: TextStyle(fontSize: 11))),
            ],
          ),
          if (selectedType != null)
            TextFormField(
              initialValue: _formData['${prefix}IdValue'],
              onChanged: (v) => _formData['${prefix}IdValue'] = v,
              decoration: _cellDecor().copyWith(hintText: 'नम्बर टाइप गर्नुस्'),
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  InputDecoration _cellDecor() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.teal)),
    filled: true,
    fillColor: Colors.grey.shade50,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  );

  // ── Province dropdown for birth address ─────────────────────────────────
  Widget _provinceDropdown(String fieldKey, String label) {
    if (widget.readOnly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Text('$label ', style: const TextStyle(fontSize: 13, color: AppColors.navy)),
          Text(_formData[fieldKey] ?? '', style: const TextStyle(fontSize: 13)),
        ]),
      );
    }
    return DropdownButtonFormField<String>(
      value: _formData[fieldKey],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.navy),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.teal)),
        filled: true,
        fillColor: Colors.grey.shade50,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      isExpanded: true,
      hint: const Text('प्रदेश छान्नुस्', style: TextStyle(fontSize: 13)),
      items: _provinces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (v) => setState(() => _formData[fieldKey] = v),
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
          NameRowBirth(readOnly: widget.readOnly, nepLabel: '', prefixKey: 'informantName', dataMap: _formData),
          const SizedBox(height: 8),
          NameRowBirthEn(readOnly: widget.readOnly, prefixKey: 'informantNameEn', dataMap: _formData),
          const SizedBox(height: 16),

          // Relationship
          BirthLabeledField(readOnly: widget.readOnly,
              label: 'बच्चासँगको नाता / Relationship:',
              width: 200, fieldKey: 'informantRelationDetail', dataMap: _formData),
          const SizedBox(height: 12),

          // Contact + Email (email optional)
          Wrap(spacing: 8, runSpacing: 8, children: [
            BirthLabeledField(readOnly: widget.readOnly,
                label: 'सम्पर्क नम्बर / Contact:', width: 130, isExpanded: true, fieldKey: 'informantContact', dataMap: _formData),
            const SizedBox(width: 16),
            BirthLabeledField(readOnly: widget.readOnly,
                label: 'ई-मेल / Email: (ऐच्छिक)', width: 180, isExpanded: true, fieldKey: 'informantEmail', dataMap: _formData),
          ]),
          const SizedBox(height: 16),

          // Nepali citizen — optional
          const Text('सूचक नेपाली नागरिक भएमा: (ऐच्छिक)',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          BirthLabeledField(readOnly: widget.readOnly,
              label: 'नागरिकता प्र.प.नं./राष्ट्रिय परिचय नं.:',
              width: 220, fieldKey: 'informantCitNo', dataMap: _formData),
          const SizedBox(height: 16),

          // Foreign citizen — optional
          const Text('सूचक विदेशी नागरिक भएमा: (ऐच्छिक)',
              style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            BirthLabeledField(readOnly: widget.readOnly,
                label: 'राहदानी नं./Passport No.:', width: 160, isExpanded: true, fieldKey: 'informantPassportNo', dataMap: _formData),
            const SizedBox(width: 16),
            BirthLabeledField(readOnly: widget.readOnly,
                label: 'जारी गर्ने देश/Issuing Country: (ऐच्छिक)', width: 160, isExpanded: true, fieldKey: 'informantPassportCountry', dataMap: _formData),
          ]),
          const SizedBox(height: 16),

          // Date filled — auto-filled, read-only display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('फारम भरेको मिति:',
                  style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal.withOpacity(0.4)),
                ),
                child: Text(
                  _formData['formFillDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: const TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Signature upload
          if (!widget.readOnly) ...[
            _uploadField(
              label: 'सूचकको दस्तखत / Informant Signature',
              isRequired: true,
              base64Value: _docInformantSignature,
              onPick: () => _pickImage((v) => setState(() {
                _docInformantSignature = v;
                _formData['doc_informantSignature'] = v;
              })),
              onRemove: () => setState(() {
                _docInformantSignature = null;
                _formData['doc_informantSignature'] = null;
              }),
            ),
          ] else if (_formData['doc_informantSignature'] != null && _formData['doc_informantSignature'].toString().isNotEmpty) ...[
            const Text('सूचकको दस्तखत:', style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(_formData['doc_informantSignature']),
                height: 80,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const BirthFormDivider(),

          // Required documents — upload section
          const Text('संलग्न गर्नुपर्ने कागजात:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
          const SizedBox(height: 12),

          if (!widget.readOnly) ...[
            _uploadField(
              label: '१) बाबुआमाको नागरिकताको प्रमाणपत्र',
              isRequired: true,
              base64Value: _docParentCitizenship,
              onPick: () => _pickImage((v) => setState(() {
                _docParentCitizenship = v;
                _formData['doc_parentCitizenship'] = v;
              })),
              onRemove: () => setState(() {
                _docParentCitizenship = null;
                _formData['doc_parentCitizenship'] = null;
              }),
            ),
            const SizedBox(height: 10),
            _uploadField(
              label: '२) जन्म प्रमाण',
              isRequired: true,
              base64Value: _docBirthProof,
              onPick: () => _pickImage((v) => setState(() {
                _docBirthProof = v;
                _formData['doc_birthProof'] = v;
              })),
              onRemove: () => setState(() {
                _docBirthProof = null;
                _formData['doc_birthProof'] = null;
              }),
            ),
            const SizedBox(height: 10),
            _uploadField(
              label: '३) विदेशी भएमा बाबुआमाको राहधानीको प्रमाणपत्र',
              isRequired: false,
              base64Value: _docForeignPassport,
              onPick: () => _pickImage((v) => setState(() {
                _docForeignPassport = v;
                _formData['doc_foreignPassport'] = v;
              })),
              onRemove: () => setState(() {
                _docForeignPassport = null;
                _formData['doc_foreignPassport'] = null;
              }),
            ),
            const SizedBox(height: 10),
            _uploadField(
              label: '४) स्थानीय तहको वडामा बसोबास रहेको प्रमाण',
              isRequired: false,
              base64Value: _docResidenceProof,
              onPick: () => _pickImage((v) => setState(() {
                _docResidenceProof = v;
                _formData['doc_residenceProof'] = v;
              })),
              onRemove: () => setState(() {
                _docResidenceProof = null;
                _formData['doc_residenceProof'] = null;
              }),
            ),
            const SizedBox(height: 10),
            _uploadField(
              label: '५) बाबु बेपत्ता भए सो प्रहरी प्रतिवेदन',
              isRequired: false,
              base64Value: _docPoliceReport,
              onPick: () => _pickImage((v) => setState(() {
                _docPoliceReport = v;
                _formData['doc_policeReport'] = v;
              })),
              onRemove: () => setState(() {
                _docPoliceReport = null;
                _formData['doc_policeReport'] = null;
              }),
            ),
          ] else ...[
            for (final entry in {
              'बाबुआमाको नागरिकताको प्रमाणपत्र': _formData['doc_parentCitizenship'],
              'जन्म प्रमाण': _formData['doc_birthProof'],
              'विदेशी भएमा राहधानी': _formData['doc_foreignPassport'],
              'बसोबास प्रमाण': _formData['doc_residenceProof'],
              'प्रहरी प्रतिवेदन': _formData['doc_policeReport'],
            }.entries)
              if (entry.value != null && entry.value.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.image, color: AppColors.teal, size: 18),
                      const SizedBox(width: 8),
                      Text(entry.key, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white),
                              title: Text(entry.key, style: const TextStyle(color: Colors.white))),
                          body: Center(child: InteractiveViewer(child: Image.memory(base64Decode(entry.value)))),
                        ))),
                        child: const Text('View', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _uploadField({
    required String label,
    required bool isRequired,
    required String? base64Value,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRequired ? AppColors.navy.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isRequired ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isRequired ? 'अनिवार्य' : 'ऐच्छिक',
                  style: TextStyle(
                    fontSize: 11,
                    color: isRequired ? Colors.red.shade700 : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (base64Value != null && base64Value.isNotEmpty) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(base64Value),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.teal),
              label: const Text('बदल्नुस्', style: TextStyle(color: AppColors.teal, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.teal),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: onPick,
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.teal, size: 28),
                    SizedBox(height: 4),
                    Text('Upload Document', style: TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImage(void Function(String) onDone) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60, maxWidth: 1200);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    onDone(base64Encode(bytes));
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
          ElevatedButton.icon(
            onPressed: _showPreview,
            icon: const Icon(Icons.preview_rounded, size: 18),
            label: const Text('Preview / पूर्वावलोकन',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Submit / पेश गर्नुहोस्',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Clear / मेटाउनुहोस्',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Widget _radioItem(String label, String value, String? groupValue, void Function(String?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: widget.readOnly ? null : onChanged,
          activeColor: AppColors.teal,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
      ],
    );
  }

  Widget _checkItem(String label, bool value, void Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.teal,
          onChanged: widget.readOnly ? null : onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
      ],
    );
  }
}


