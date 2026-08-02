import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:smartsewa/widgets/citizenship_widgets.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsewa/widgets/attached_document_viewer.dart';
import 'package:smartsewa/widgets/base64_upload_widget.dart';
import 'citizenship_apply_screen.dart';
import 'package:smartsewa/services/form_draft_service.dart';
class CitizenshipFormScreen extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? initialData;
  final bool asSubView;
  final CitizenshipFormType formType;
  final String? attachedDocumentBase64;

  const CitizenshipFormScreen({
    super.key,
    this.readOnly = false,
    this.initialData,
    this.asSubView = false,
    this.formType = CitizenshipFormType.citizenship,
    this.attachedDocumentBase64,
  });

  @override
  State<CitizenshipFormScreen> createState() =>
      _CitizenshipFormScreenState();
}

class _CitizenshipFormScreenState extends State<CitizenshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  String? _sex;


  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
      _sex = _formData['sex'];
    } else if (!widget.readOnly) {
      final draft = FormDraftService.getDraft('citizenship_${widget.formType.name}');
      if (draft != null) {
        _formData.addAll(draft);
        _sex = _formData['sex'];
      }
    }
  }

  @override
  void dispose() {
    if (!widget.readOnly && widget.initialData == null) {
      FormDraftService.saveDraft('citizenship_${widget.formType.name}', _formData);
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

      // Validate mandatory uploads for migration form
      if (widget.formType == CitizenshipFormType.migration) {
        if (_formData['doc_migration_cert'] == null) {
          throw Exception('कृपया बसाईसराई प्रमाणपत्र अपलोड गर्नुहोस् (Upload migration certificate)');
        }
        if (_formData['doc_old_citizenship'] == null) {
          throw Exception('कृपया पुरानो नागरिकताको प्रमाण अपलोड गर्नुहोस् (Upload old citizenship)');
        }
        if (_formData['doc_new_address_recommendation'] == null) {
          throw Exception('कृपया नयाँ ठेगानाको सिफारिस अपलोड गर्नुहोस् (Upload new address recommendation)');
        }
      }

      // Validate mandatory uploads for surname change form
      if (widget.formType == CitizenshipFormType.surnameChange) {
        if (_formData['doc_marriage_cert'] == null) {
          throw Exception('कृपया विवाह दर्ता प्रमाणपत्र अपलोड गर्नुहोस् (Upload marriage certificate)');
        }
        if (_formData['doc_old_citizenship'] == null) {
          throw Exception('कृपया पुरानो नागरिकताको प्रमाण अपलोड गर्नुहोस् (Upload old citizenship)');
        }
        if (_formData['doc_spouse_citizenship'] == null) {
          throw Exception('कृपया पतिको नागरिकता अपलोड गर्नुहोस् (Upload spouse citizenship)');
        }
      }

      // Validate mandatory uploads for citizenship form
      if (widget.formType == CitizenshipFormType.citizenship) {
        if (_formData['doc_photo'] == null) {
          throw Exception('कृपया पासपोर्ट साइजको फोटो अपलोड गर्नुहोस् (Upload passport size photo)');
        }
        if (_formData['doc_sifarish'] == null) {
          throw Exception('कृपया सिफारिस अपलोड गर्नुहोस् (Upload sifarish document)');
        }
        if (_formData['doc_birth_cert'] == null) {
          throw Exception('कृपया जन्मदर्ता प्रमाण अपलोड गर्नुहोस् (Upload birth certificate)');
        }
        if (_formData['doc_parent_citizenship'] == null) {
          throw Exception('कृपया बाबुआमाको नागरिकता अपलोड गर्नुहोस् (Upload parent citizenship)');
        }
      }


      final appData = {
        'applicant': '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}'.trim().isNotEmpty ? '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}' : 'Applicant',
        'citizenId': user.uid,
        'userId': user.uid,
        'applicantName': '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}'.trim().isNotEmpty ? '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}' : 'Applicant',
        'title': widget.formType.appBarTitle + ' Application',
        'type': widget.formType.englishLabel,
        'status': 'Pending',
        'formData': _formData,
        'createdAt': FieldValue.serverTimestamp(),
        'isHidden': false,
        if (widget.attachedDocumentBase64 != null)
          'attachedDocumentBase64': widget.attachedDocumentBase64,
      };

      await FirebaseFirestore.instance.collection('applications').add(appData);

      // Save all uploaded documents to user's global documents collection
      final docTypes = {
        'doc_photo': 'Citizenship: Passport Photo',
        'doc_sifarish': 'Citizenship: Sifarish',
        'doc_birth_cert': 'Citizenship: Birth Certificate',
        'doc_parent_citizenship': 'Citizenship: Parent Citizenship',
        'doc_migration_cert': 'Citizenship: Migration Certificate',
        'doc_old_citizenship': 'Citizenship: Old Citizenship',
        'doc_new_address_recommendation': 'Citizenship: New Address Rec.',
        'doc_marriage_cert': 'Citizenship: Marriage Certificate',
        'doc_spouse_citizenship': 'Citizenship: Spouse Citizenship',
        'doc_school_cert': 'Citizenship: School Certificate',
        'doc_other': 'Citizenship: Other Document',
      };
      
      final batch = FirebaseFirestore.instance.batch();
      final userDocsRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('documents');
      
      for (final entry in docTypes.entries) {
        if (_formData[entry.key] != null) {
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

      FormDraftService.clearDraft('citizenship_${widget.formType.name}');

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
    _formKey.currentState?.save();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.preview, color: AppColors.navy, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Preview / पूर्वावलोकन',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  child: CitizenshipFormScreen(
                    readOnly: true,
                    initialData: Map<String, dynamic>.from(_formData),
                    asSubView: true,
                    formType: widget.formType,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    if (widget.formType == CitizenshipFormType.surnameChange) {
      return _buildSurnameChangeContent();
    } else if (widget.formType == CitizenshipFormType.migration) {
      return _buildMigrationContent();
    }
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
    Widget formBody = Form(
      key: _formKey,
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
                  const SizedBox(height: 16),
                  if (widget.readOnly || widget.attachedDocumentBase64 != null)
                    AttachedDocumentViewer(base64String: widget.attachedDocumentBase64),
                  if (!widget.readOnly) _buildButtons(),
                  const SizedBox(height: 32),
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
        title: const Text(
          'नागरिकताको प्रमाण-पत्र (अनुसूची-१)',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: formBody,
    );
  }

  // ── TITLE ──────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    final ro = widget.readOnly;
    return Column(
      children: [
        const Text(
          'अनुसूची-१',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('निवेदकको दुवै कान देखिने पासपोर्ट साइजको फोटो',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: AppColors.navy, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Base64UploadWidget(
                    title: 'फोटो',
                    subtitle: 'अनिवार्य / compulsory',
                    icon: Icons.camera_alt_outlined,
                    readOnly: ro,
                    initialBase64: _formData['doc_photo'],
                    onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_photo'] = val),
                  ),
                ],
              ),
            ),
          ],
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
          children: [
            CitField(readOnly: widget.readOnly, hint: 'ठाउँ', width: 160),
            Text(',', style: TextStyle(fontSize: 14)),
            _buildDistrictDropdown(),
            Text('जिल्ला', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    final districts = [
      'Achham','Arghakhanchi','Baglung','Baitadi','Bajhang','Bajura','Banke','Bara','Bardiya',
      'Bhaktapur','Bhojpur','Chitwan','Dadeldhura','Dailekh','Dang','Darchula','Dhading',
      'Dhankuta','Dhanusha','Dolakha','Dolpa','Doti','Eastern Rukum','Gorkha','Gulmi','Humla',
      'Ilam','Jajarkot','Jhapa','Jumla','Kailali','Kalikot','Kanchanpur','Kapilvastu','Kaski',
      'Kathmandu','Kavrepalanchok','Khotang','Lalitpur','Lamjung','Mahottari','Makwanpur',
      'Manang','Morang','Mugu','Mustang','Myagdi','Nawalpur','Nuwakot','Okhaldhunga','Palpa',
      'Panchthar','Parbat','Parsa','Pyuthan','Ramechhap','Rasuwa','Rautahat','Rolpa',
      'Rupandehi','Salyan','Sankhuwasabha','Saptari','Sarlahi','Sindhuli','Sindhupalchok',
      'Siraha','Solukhumbu','Sunsari','Surkhet','Syangja','Tanahun','Taplejung','Terhathum',
      'Udayapur','Western Rukum'
    ];
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: _formData['addressDistrict'],
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          filled: true,
          fillColor: Colors.white,
          hintText: 'जिल्ला चयन गर्नुहोस्',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: widget.readOnly ? null : (v) => setState(() => _formData['addressDistrict'] = v),
      ),
    );
  }

  // ── SUBJECT LINE ───────────────────────────────────────────────────────────

  // ── Surname Change Content ───────────────────────────────────────────────
  Widget _buildSurnameChangeContent() {
    final ro = widget.readOnly;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Applicant Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Old Name / पुरानो नाम', width: double.infinity, fieldKey: 'oldName', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'New Name / नयाँ नाम', width: double.infinity, fieldKey: 'newName', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Citizenship No. / नागरिकता प्रमाणपत्र नं.', width: double.infinity, fieldKey: 'citNo', dataMap: _formData),
          const SizedBox(height: 12),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('Issue Date: ', style: TextStyle(fontSize: 13)), const SizedBox(width: 8), CitDateEntry(readOnly: ro, fieldKey: 'issueDate', dataMap: _formData)]),
          const SizedBox(height: 24),
          const Text('Marriage Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Spouse Name / पति-पत्नीको नाम', width: double.infinity, fieldKey: 'spouseName', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Spouse Citizenship No. / पतिको नागरिकता नं.', width: double.infinity, fieldKey: 'spouseCitNo', dataMap: _formData),
          const SizedBox(height: 12),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('Marriage Date: ', style: TextStyle(fontSize: 13)), const SizedBox(width: 8), CitDateEntry(readOnly: ro, fieldKey: 'marriageDate', dataMap: _formData)]),
          const SizedBox(height: 24),
          const Text('संलग्न कागजातहरू / Required Documents',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
          const SizedBox(height: 8),
          Base64UploadWidget(
            title: 'विवाह दर्ता प्रमाणपत्र',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.description_outlined,
            readOnly: ro,
            initialBase64: _formData['doc_marriage_cert'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_marriage_cert'] = val),
          ),
          Base64UploadWidget(
            title: 'पुरानो नागरिकताको प्रमाण',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.badge_outlined,
            readOnly: ro,
            initialBase64: _formData['doc_old_citizenship'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_old_citizenship'] = val),
          ),
          Base64UploadWidget(
            title: 'पतिको नागरिकता',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.people_outline,
            readOnly: ro,
            initialBase64: _formData['doc_spouse_citizenship'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_spouse_citizenship'] = val),
          ),
        ],
      ),
    );
  }

  // ── Migration Content ──────────────────────────────────────────────────
  Widget _buildMigrationContent() {
    final ro = widget.readOnly;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Applicant Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Full Name / पूरा नाम', width: double.infinity, fieldKey: 'fullName', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Citizenship No. / नागरिकता प्रमाणपत्र नं.', width: double.infinity, fieldKey: 'citNo', dataMap: _formData),
          const SizedBox(height: 24),
          const Text('Migration Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Old Address (Prov, Dist, Mun, Ward)', width: double.infinity, fieldKey: 'oldAddress', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'New Address (Prov, Dist, Mun, Ward)', width: double.infinity, fieldKey: 'newAddress', dataMap: _formData),
          const SizedBox(height: 12),
          CitField(readOnly: ro, label: 'Migration Cert No. / बसाइसराई दर्ता नं.', width: double.infinity, fieldKey: 'migCertNo', dataMap: _formData),
          const SizedBox(height: 12),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [const Text('Migration Date: ', style: TextStyle(fontSize: 13)), const SizedBox(width: 8), CitDateEntry(readOnly: ro, fieldKey: 'migDate', dataMap: _formData)]),
          const SizedBox(height: 24),
          const Text('संलग्न कागजातहरू / Required Documents',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
          const SizedBox(height: 8),
          Base64UploadWidget(
            title: 'बसाईसराई प्रमाणपत्र',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.swap_horiz,
            readOnly: ro,
            initialBase64: _formData['doc_migration_cert'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_migration_cert'] = val),
          ),
          Base64UploadWidget(
            title: 'पुरानो नागरिकताको प्रमाण',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.badge_outlined,
            readOnly: ro,
            initialBase64: _formData['doc_old_citizenship'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_old_citizenship'] = val),
          ),
          Base64UploadWidget(
            title: 'नयाँ ठेगानाको सिफारिस',
            subtitle: 'अनिवार्य / compulsory',
            icon: Icons.location_on_outlined,
            readOnly: ro,
            initialBase64: _formData['doc_new_address_recommendation'],
            onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_new_address_recommendation'] = val),
          ),
        ],
      ),
    );
  }

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
      children: [
        Text(
          'महोदय,\n\n    म बंशजको नाताले जन्मका आधारले नेपाली नागरिकता भएकोले देहायको विवरण खोली नेपाली नागरिकताको प्रमाण-पत्र पाउनको लागि सिफारिस साथ यो निवेदन पत्र पेश गरेको छु । मैले यस अघि नेपाली नागरिकताको प्रमाण-पत्र लिएको छैन ।',
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
        CitSectionHeader('  व्यक्तिगत विवरण / Personal Details'),
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
    final ro = widget.readOnly;
    final d = _formData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitLabeledRow(
          label: '१. नाम, घर (Full Name in block):',
          field: CitField(readOnly: ro, fieldKey: 'fullName', dataMap: d),
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
                      onChanged: ro ? null : (v) => setState(() { _sex = v; _formData['sex'] = v; }),
                      activeColor: AppColors.teal,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(s, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
                    const SizedBox(width: 12),
                  ],
                ),
            ],
          ),
        ),

        CitLabeledRow(label: '३. जन्म स्थान / Place of Birth:', field: CitField(readOnly: ro, fieldKey: 'birthPlace', dataMap: d)),
        CitLabeledRow(label: '४. स्थायी वास स्थान – जिल्ला:', field: CitField(readOnly: ro, fieldKey: 'permanentDistrict', dataMap: d)),
        CitLabeledRow(label: '    गा.वि.स. / VDC/Municipality:', field: CitField(readOnly: ro, fieldKey: 'permanentMunicipality', dataMap: d)),
        CitLabeledRow(label: '    वडा नं.:', field: CitField(readOnly: ro, fieldKey: 'permanentWard', dataMap: d, width: 100, keyboardType: TextInputType.number)),

        // DOB
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              const SizedBox(
                width: 240,
                child: Text('५. जन्म मिति (Date of Birth AD):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
              ),
              CitDateEntry(readOnly: ro, fieldKey: 'dob', dataMap: d),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    final ro = widget.readOnly;
    final d = _formData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitLabeledRow(label: '६. बाबुको नाम, घर:', field: CitField(readOnly: ro, fieldKey: 'fatherName', dataMap: d)),
        CitLabeledRow(label: '    ठेगाना:', field: CitField(readOnly: ro, fieldKey: 'fatherAddress', dataMap: d)),
        CitLabeledRow(label: '    नागरिकता नं.:', field: CitField(readOnly: ro, fieldKey: 'fatherCitNo', dataMap: d)),
        CitLabeledRow(label: '७. आमाको नाम, घर:', field: CitField(readOnly: ro, fieldKey: 'motherName', dataMap: d)),
        CitLabeledRow(label: '    ठेगाना:', field: CitField(readOnly: ro, fieldKey: 'motherAddress', dataMap: d)),
        CitLabeledRow(label: '    नागरिकता नं.:', field: CitField(readOnly: ro, fieldKey: 'motherCitNo', dataMap: d)),
        const SizedBox(height: 4),
        const Text('८. पति/पत्नीको नाम, घर: (Optional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
        CitField(readOnly: ro, fieldKey: 'spouseName', dataMap: d, hint: 'नाम, घर'),
        CitField(readOnly: ro, fieldKey: 'spouseAddress', dataMap: d, hint: 'ठेगाना'),
        CitField(readOnly: ro, fieldKey: 'spouseCitNo', dataMap: d, hint: 'नागरिकता नं.'),
        const SizedBox(height: 4),
        const Text('९. संरक्षकको नाम, घर: (Optional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
        CitField(readOnly: ro, fieldKey: 'guardianName', dataMap: d, hint: 'नाम, घर'),
      ],
    );
  }

  // ── SECTION B: Thumbprint + Signature ─────────────────────────────────────
  Widget _buildSectionB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitSectionHeader(
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
    final today = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('निवेदकको डिजिटल दस्तखत / Digital Signature:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
        SizedBox(height: 8),
        CitSignaturePad(width: double.infinity, height: 80),
        SizedBox(height: 12),
        Text('मिति / Date: $today',
            style: TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── SECTION C: VDC Recommendation ─────────────────────────────────────────
  Widget _buildSectionC() {
    final ro = widget.readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitSectionHeader('  गाउँ विकास समिति / उप/मह/नगरपालिकाको सिफारिस'),
        const SizedBox(height: 12),
        Base64UploadWidget(
          title: 'सिफारिस',
          subtitle: 'अनिवार्य / compulsory',
          icon: Icons.recommend_outlined,
          readOnly: ro,
          initialBase64: _formData['doc_sifarish'],
          onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_sifarish'] = val),
        ),
      ],
    );
  }
  // ── SECTION D: निर्णय / Decision ──────────────────────────────────────────
  Widget _buildSectionD() {
    // निर्णय section removed as requested
    return const SizedBox.shrink();
  }

  // ── SECTION E: Optional Documents ─────────────────────────────────────────
  Widget _buildSectionE() {
    final ro = widget.readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitSectionHeader('  संलग्न कागजातहरू / Supporting Documents'),
        const SizedBox(height: 12),
        Base64UploadWidget(
          title: 'जन्मदर्ता प्रमाण',
          subtitle: 'अनिवार्य / compulsory',
          icon: Icons.child_care_outlined,
          readOnly: ro,
          initialBase64: _formData['doc_birth_cert'],
          onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_birth_cert'] = val),
        ),
        const SizedBox(height: 8),
        Base64UploadWidget(
          title: 'बाबुआमाको नागरिकता',
          subtitle: 'अनिवार्य / compulsory',
          icon: Icons.people_outline,
          readOnly: ro,
          initialBase64: _formData['doc_parent_citizenship'],
          onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_parent_citizenship'] = val),
        ),
        const SizedBox(height: 8),
        Base64UploadWidget(
          title: 'विद्यालय प्रमाण',
          subtitle: 'ऐच्छिक / optional',
          icon: Icons.school_outlined,
          readOnly: ro,
          initialBase64: _formData['doc_school_cert'],
          onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_school_cert'] = val),
        ),
        const SizedBox(height: 8),
        Base64UploadWidget(
          title: 'अन्य कागजातहरू',
          subtitle: 'ऐच्छिक / optional',
          icon: Icons.attach_file_outlined,
          readOnly: ro,
          initialBase64: _formData['doc_other'],
          onImageChanged: ro ? (_) {} : (val) => setState(() => _formData['doc_other'] = val),
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
                ? Column(
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
                : Column(
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