import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';
import 'package:smartsewa/screens/citizen/section_parent.dart';
import 'package:smartsewa/screens/citizen/section_spouse.dart';
import 'package:smartsewa/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsewa/widgets/attached_document_viewer.dart';
import 'package:smartsewa/widgets/base64_upload_widget.dart';
import 'package:smartsewa/services/form_draft_service.dart';
class NIDFormScreen extends StatefulWidget {
  final bool readOnly;
  final Map<String, dynamic>? initialData;
  final bool asSubView;
  final String? attachedDocumentBase64;

  const NIDFormScreen({
    super.key,
    this.readOnly = false,
    this.initialData,
    this.asSubView = false,
    this.attachedDocumentBase64,
  });

  @override
  State<NIDFormScreen> createState() => _NIDFormScreenState();
}

class _NIDFormScreenState extends State<NIDFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Radio selections ──
  String? _natType;
  String? _gender;
  String? _marital;

  // ── Radio validation error flags ──
  bool _natTypeError = false;
  bool _maritalError = false;

  // ── JSON Form Data Map ──
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
      _natType = _formData['natType'];
      _gender = _formData['gender'];
      _marital = _formData['maritalStatus'];
    } else if (!widget.readOnly) {
      final draft = FormDraftService.getDraft('nid');
      if (draft != null) {
        _formData.addAll(draft);
        _natType = _formData['natType'];
        _gender = _formData['gender'];
        _marital = _formData['maritalStatus'];
      }
    }
  }

  @override
  void dispose() {
    if (!widget.readOnly && widget.initialData == null) {
      FormDraftService.saveDraft('nid', _formData);
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate everything, then show the confirm dialog
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    // 1. Validate Form and Documents
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया सबै अनिवार्य विवरण भर्नुहोस्।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formData['doc_citizenship'] == null ||
        _formData['doc_parentCitizenship'] == null ||
        _formData['doc_birthCertificate'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया सबै अनिवार्य कागजातहरू अपलोड गर्नुहोस्।'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. All valid — confirm dialog
    final confirmed = await _showConfirmDialog();
    if (confirmed == true && mounted) {
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

        final appData = {
          'type': 'NID Registration',
          'userId': user.uid,
          'citizenId': user.uid,
          'applicantName': '${_formData['firstName_eng'] ?? ''} ${_formData['lastName_eng'] ?? ''}'.trim(),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
          'formData': _formData,
          'isHidden': false,
          if (widget.attachedDocumentBase64 != null)
            'attachedDocumentBase64': widget.attachedDocumentBase64,
        };

        // Save uploaded documents to user's global documents collection
        final docTypes = {
          'doc_citizenship': 'NID: Citizenship',
          'doc_parentCitizenship': 'NID: Parent Citizenship',
          'doc_birthCertificate': 'NID: Birth Certificate',
          'doc_passport': 'NID: Passport',
          'doc_migration': 'NID: Migration Certificate',
          'doc_marriage': 'NID: Marriage Certificate',
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

        FormDraftService.clearDraft('nid');

        if (mounted) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ फाराम पेश गरिएको छ (Form Submitted)'),
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Confirmation dialog
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: const [
            Icon(Icons.help_outline_rounded, color: AppColors.navy, size: 24),
            SizedBox(width: 8),
            Text(
              'फाराम पेश गर्ने?',
              style: TextStyle(fontSize: 16, color: AppColors.navy),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'के तपाईं यो राष्ट्रिय परिचयपत्र फाराम पेश गर्न निश्चित हुनुहुन्छ?',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade700, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'एकपटक पेश गरिसकेपछि फाराम संशोधन गर्न सकिँदैन।\n'
                      'कृपया सबै विवरण जाँच गर्नुहोस्।',
                      style:
                          TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'फिर्ता जानुहोस्',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('पेश गर्नुहोस्',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear / reset the whole form
  // ─────────────────────────────────────────────────────────────────────────
  void _clear() {
    FormDraftService.clearDraft('nid');
    _formKey.currentState?.reset();

    setState(() {
      _natType = null;
      _gender = null;
      _marital = null;
      _natTypeError = false;
      _maritalError = false;
      _formData.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✗ फाराम मेटाइएको छ (Form Cleared)'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormContent({bool isPdfCapture = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildHeader(),
        ),
        const SizedBox(height: 8),

        // ── Document Uploads ─────────────────────────────────────────
        RepaintBoundary(child: _buildDocumentUploads(isPdfCapture: isPdfCapture)),

        // ── Section 1 ────────────────────────────────────────────────
        RepaintBoundary(child: _buildSection2(isPdfCapture: isPdfCapture)),

        // ── Section 3 ────────────────────────────────────────────────
        RepaintBoundary(child: _buildSection3()),

        // ── Section 4 ────────────────────────────────────────────────
        RepaintBoundary(child: _buildSection4()),

        // ── Parent / Mother ──────────────────────────────────────────
        RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormDivider(),
              const SectionHeader(' ४. बाबु/पिताको विवरण'),
              const ParentSection(
                foreignLabel:
                    'बाबु विदेशी भए बाबु नागरिक रहेको मुलुकको नाम :',
              ),
              const FormDivider(),
              const SectionHeader(' ५. आमाको विवरण'),
              const ParentSection(
                foreignLabel:
                    'आमा विदेशी भए आमा नागरिक रहेको मुलुकको नाम :',
              ),
            ],
          ),
        ),

        // ── Grandparents / Spouse ────────────────────────────────────
        RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormDivider(),
              _buildSimpleNameBlock(' ६. हजुरबुबाको विवरण'),
              _buildSimpleNameBlock(' ७. हजुरआमाको विवरण'),
              const SectionHeader(' ८. पति/पत्नीको विवरण'),
              const SpouseSection(),
            ],
          ),
        ),

        // ── Oath + Signature + Buttons ───────────────────────────────
        RepaintBoundary(
          child: Column(
            children: [
              const FormDivider(),
              _buildOath(),
              _buildSignatureSection(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget formBody = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]
            ),
            child: Column(
              children: [
                _buildFormContent(isPdfCapture: widget.readOnly),
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
    );

    if (widget.asSubView) return formBody;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          'राष्ट्रिय परिचयपत्र फाराम',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: formBody,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Document uploads section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDocumentUploads({bool isPdfCapture = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(' आवश्यक कागजातहरू अपलोड गर्नुहोस्'),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accepted format info banner
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: AppColors.teal),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'स्वीकृत फाइल: PDF, DOC, DOCX, JPG, PNG, '
                        'GIF, BMP, WEBP, XLS, XLSX, TXT',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Required uploads (keyed for validation + clear) ──
              Base64UploadWidget(
                icon: Icons.badge_outlined,
                title: 'नेपाली नागरिकताको प्रमाणपत्रको सक्कल',
                subtitle: 'अनिवार्य / compulsory',
                initialBase64: _formData['doc_citizenship'],
                onImageChanged: (val) => _formData['doc_citizenship'] = val,
              ),
              const SizedBox(height: 12),
              Base64UploadWidget(
                icon: Icons.people_outline,
                title: 'बाबु/आमाको नागरिकताको प्रमाणपत्र',
                subtitle: 'अनिवार्य / compulsory',
                initialBase64: _formData['doc_parentCitizenship'],
                onImageChanged: (val) => _formData['doc_parentCitizenship'] = val,
              ),
              const SizedBox(height: 12),
              Base64UploadWidget(
                icon: Icons.calendar_today_outlined,
                title: 'जन्ममिति खुल्ने प्रमाण / गाउँपालिका सिफारिस',
                subtitle: 'अनिवार्य / compulsory',
                initialBase64: _formData['doc_birthCertificate'],
                onImageChanged: (val) => _formData['doc_birthCertificate'] = val,
              ),
              const SizedBox(height: 12),

              // ── Optional uploads ──
              Base64UploadWidget(
                icon: Icons.flight_outlined,
                title: 'राहदानीको सक्कल वा प्रतिलिपि (भएमा)',
                subtitle: 'ऐच्छिक / optional',
                initialBase64: _formData['doc_passport'],
                onImageChanged: (val) => _formData['doc_passport'] = val,
              ),
              const SizedBox(height: 12),
              Base64UploadWidget(
                icon: Icons.transfer_within_a_station_outlined,
                title: 'बसाइसराई प्रमाणपत्र (लागु भएमा)',
                subtitle: 'ऐच्छिक / optional',
                initialBase64: _formData['doc_migration'],
                onImageChanged: (val) => _formData['doc_migration'] = val,
              ),
              const SizedBox(height: 12),
              Base64UploadWidget(
                icon: Icons.favorite_border_outlined,
                title: 'विवाह दर्ता प्रमाणपत्र (विवाहितको हकमा)',
                subtitle: 'ऐच्छिक / optional',
                initialBase64: _formData['doc_marriage'],
                onImageChanged: (val) => _formData['doc_marriage'] = val,
              ),

              const SizedBox(height: 4),

              // ── Legend ──
              Row(
                children: [
                  _legendDot(Colors.red.shade300),
                  const SizedBox(width: 6),
                  const Text(
                    'अनिवार्य — बिना यी फाराम पेश हुँदैन',
                    style:
                        TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(width: 16),
                  _legendDot(Colors.grey.shade400),
                  const SizedBox(width: 6),
                  const Text(
                    'ऐच्छिक',
                    style:
                        TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Center(
          child: Text(
            'राष्ट्रिय परिचयपत्रको लागि निवेदन फाराम',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
        ),
        Center(
          child: Text(
            '(नेपाली नागरिकता प्राप्त व्यक्तिको लागि मात्र)',
            style: TextStyle(fontSize: 12),
          ),
        ),
        SizedBox(height: 6),
        Text('श्रीमान् महानिर्देशकज्यू,',
            style: TextStyle(fontSize: 12)),
        Text(
          'राष्ट्रिय परिचयपत्र तथा पञ्जीकरण विभाग,\nसिंहदरबार, काठमाडौँ।',
          style: TextStyle(fontSize: 11),
        ),
        SizedBox(height: 6),
        ColoredBox(
          color: Color(0xFFC8C8C8),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Text(
                'विषय :- नेपाली राष्ट्रिय परिचयपत्र पाऊँ।',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'महोदय,\n     म नेपाली नागरिक भएकोले देहायको विवरण खोली '
          'राष्ट्रिय परिचयपत्र पाउनको लागि यो निवेदन पेश गरेको छु । '
          'मैले यसअघि राष्ट्रिय परिचयपत्र लिएको छैन ।',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section 1 — Personal details
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSection2({bool isPdfCapture = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(' १. आवेदकको व्यक्तिगत विवरण'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'नाम (देवनागरीमा):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(spacing: 12, runSpacing: 8, children: [
                LabeledField(
                    label: 'पहिलो नाम:', width: 120, required: true, fieldKey: 'firstName_nep', dataMap: _formData, readOnly: isPdfCapture),
                LabeledField(label: 'बीचको नाम:', width: 120, fieldKey: 'middleName_nep', dataMap: _formData, readOnly: isPdfCapture, required: false),
                LabeledField(label: 'थर:', width: 120, required: true, fieldKey: 'lastName_nep', dataMap: _formData, readOnly: isPdfCapture),
              ]),
              const SizedBox(height: 8),
              const Text(
                'Name (English):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(spacing: 12, runSpacing: 8, children: [
                LabeledField(
                    label: 'First Name:', width: 120, required: true, fieldKey: 'firstName_eng', dataMap: _formData, readOnly: isPdfCapture),
                LabeledField(label: 'Middle Name:', width: 120, fieldKey: 'middleName_eng', dataMap: _formData, readOnly: isPdfCapture, required: false),
                LabeledField(
                    label: 'Last Name:', width: 120, required: true, fieldKey: 'lastName_eng', dataMap: _formData, readOnly: isPdfCapture),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 16, runSpacing: 8, children: [
                DateEntryWidget(label: 'जन्म मिति (वि.सं.) :', fieldKey: 'dob_bs', dataMap: _formData, readOnly: isPdfCapture),
                DateEntryWidget(label: 'Date of Birth (AD) :', fieldKey: 'dob_ad', dataMap: _formData, readOnly: isPdfCapture),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: [
                LabeledField(
                  label: 'नागरिकता प्रमाणपत्र नं.:',
                  width: 130,
                  required: true,
                  fieldKey: 'citizenship_no',
                  dataMap: _formData,
                  readOnly: isPdfCapture,
                ),
                DistrictDropdown(
                  label: 'जारी जिल्ला:',
                  width: 150,
                  required: true,
                  fieldKey: 'citizenship_district',
                  dataMap: _formData,
                  readOnly: isPdfCapture,
                ),
              ]),
              const SizedBox(height: 4),
              DateEntryWidget(label: 'जारी मिति:', fieldKey: 'citizenship_date', dataMap: _formData, readOnly: isPdfCapture),
              const SizedBox(height: 8),

              // ── नागरिकताको किसिम (required radio) ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'नागरिकताको किसिम:',
                      style:
                          TextStyle(fontSize: 12, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final k in [
                        'जन्मसिद्ध',
                        'जन्मको आधारमा',
                        'वंशज',
                        'सम्मानार्थ',
                        'अंगीकृत',
                        'वैवाहिक अंगीकृत',
                      ])
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: k,
                              groupValue: _natType,
                              onChanged: (v) => setState(() {
                                _natType = v;
                                _natTypeError = false;
                              }),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              activeColor: AppColors.teal,
                            ),
                            Text(k,
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                    ],
                  ),
                  if (_natTypeError)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 4),
                      child: Text(
                        'कृपया नागरिकताको किसिम छान्नुहोस्',
                        style:
                            TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              const DistrictDropdown(
                  label: 'जन्म स्थान (जिल्ला):', width: 240),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  Text(
                    '(पहिले अन्य देशको नागरिक भएमा) अघिल्लो नागरिकता त्याग मिति:',
                    style: TextStyle(fontSize: 12),
                  ),
                  DateEntryWidget(label: ''),
                  LabeledField(
                    label: 'अघिल्लो राष्ट्रियता (देशको नाम):',
                    width: 140,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section 3 — Address
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSection3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(' २. ठेगाना विवरण'),
        Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              if (constraints.maxWidth > 500) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: AddressBlock(title: 'स्थायी ठेगाना')),
                    SizedBox(width: 12),
                    Expanded(
                        child: AddressBlock(
                            title: 'अस्थायी ठेगाना (हाल बसोबास)')),
                  ],
                );
              }
              return const Column(
                children: [
                  AddressBlock(title: 'स्थायी ठेगाना'),
                  SizedBox(height: 12),
                  AddressBlock(
                      title: 'अस्थायी ठेगाना (हाल बसोबास)'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section 4 — Other details
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSection4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(' ३. अन्य विवरण'),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(spacing: 16, runSpacing: 8, children: [
                LabeledField(label: 'जात:', width: 120),
                LabeledField(label: 'धर्म:', width: 120),
              ]),
              const SizedBox(height: 8),

              // ── Gender (required radio) ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'लिङ्ग (Gender):',
                      style:
                          TextStyle(fontSize: 12, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final e in [
                        ('पुरुष', 'M'),
                        ('महिला', 'F'),
                        ('अन्य', 'O'),
                      ])
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Radio<String>(
                            value: e.$2,
                            groupValue: _gender,
                            onChanged: (v) => setState(() {
                              _gender = v;
                            }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: AppColors.teal,
                          ),
                          Text(e.$1,
                              style: const TextStyle(fontSize: 13)),
                        ]),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Marital status (required radio) ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'वैवाहिक अवस्था:',
                      style:
                          TextStyle(fontSize: 12, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final e in [
                        ('अविवाहित', 'S'),
                        ('विवाहित', 'M'),
                        ('अन्य', 'D'),
                      ])
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Radio<String>(
                            value: e.$2,
                            groupValue: _marital,
                            onChanged: (v) => setState(() {
                              _marital = v;
                              _maritalError = false;
                            }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: AppColors.teal,
                          ),
                          Text(e.$1,
                              style: const TextStyle(fontSize: 13)),
                        ]),
                    ],
                  ),
                  if (_maritalError)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 4),
                      child: Text(
                        'कृपया वैवाहिक अवस्था छान्नुहोस्',
                        style:
                            TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              const LabeledField(
                  label: 'शैक्षिक योग्यता :', width: 220),
              const SizedBox(height: 8),
              const LabeledField(label: 'पेशा :', width: 220),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Simple 3-name block (grandparents)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSimpleNameBlock(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            children: const [
              NameRow(nepLabel: 'पहिलो नाम', engLabel: 'First Name'),
              NameRow(nepLabel: 'बीचको नाम', engLabel: 'Middle Name'),
              NameRow(nepLabel: 'थर', engLabel: 'Last Name'),
            ],
          ),
        ),
        const FormDivider(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Oath text
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOath() {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        'मैले माथि उल्लेख गरेको व्यहोरा साँचो हो । '
        'झुट्टा ठहरे कानून बमोजिम सहुँला बुझाउँला ।',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Signature + fingerprint section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSignatureSection() {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Applicant signature ──
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('भवदीय,', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text('निवेदकको दस्तखत:',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                const SignaturePad(),
                const SizedBox(height: 8),
                Text(
                  'मिति: $dateString',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ─────────────────────────────────────────────────────────────────────────
  // Submit / Clear / Preview buttons
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Column(
      children: [
        // Info banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'पेश गर्नुअघि “पूर्वावलोकन” मा थिचेर विवरण जाँच गर्नुहोस्।',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _showPreview,
              icon: const Icon(Icons.preview_rounded, size: 16),
              label: const Text('पूर्वावलोकन (Preview)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('पेश गर्नुहोस् (Submit)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('मेटाउनुहोस् (Clear)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Preview bottom sheet
  // ─────────────────────────────────────────────────────────────────────────
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 2),
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Top bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.navy,
                child: Row(
                  children: [
                    const Icon(Icons.preview_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'फाराम पूर्वावलोकन',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Warning banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'कृपया सबै विवरण राम्ररी जाँच गर्नुहोस्। एकपटक पेश गरिसकेपछि फाराम संशोधन गर्न सकिँदैन।',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _previewSection('१. आवेदकको व्यक्तिगत विवरण', [
                      _previewRow('पहिलो नाम (नेपाली)', _formData['firstName_nep']),
                      _previewRow('बीचको नाम (नेपाली)', _formData['middleName_nep']),
                      _previewRow('थर (नेपाली)', _formData['lastName_nep']),
                      _previewRow('First Name', _formData['firstName_eng']),
                      _previewRow('Middle Name', _formData['middleName_eng']),
                      _previewRow('Last Name', _formData['lastName_eng']),
                      _previewRow('जन्म मिति (वि.सं.)', _formData['dob_bs']),
                      _previewRow('Date of Birth (AD)', _formData['dob_ad']),
                      _previewRow('नागरिकताको किसिम', _natType),
                      _previewRow('लिङ्ग', _gender),
                      _previewRow('नागरिकता नं.', _formData['citizenship_no']),
                      _previewRow('जारी मिति', _formData['citizenship_date']),
                    ]),
                    const SizedBox(height: 12),
                    _previewSection('२. ठेगाना विवरण', [
                      _previewRow('स्थायी प्रदेश', _formData['perm_province']),
                      _previewRow('स्थायी जिल्ला', _formData['perm_district']),
                      _previewRow('स्थायी गाउँपालिका', _formData['perm_municipality']),
                      _previewRow('स्थायी वडा नं.', _formData['perm_ward']),
                      _previewRow('स्थायी टोल', _formData['perm_tole']),
                      _previewRow('स्थायी घर नं.', _formData['perm_house']),
                      _previewRow('अस्थायी प्रदेश', _formData['temp_province']),
                      _previewRow('अस्थायी जिल्ला', _formData['temp_district']),
                      _previewRow('अस्थायी गाउँपालिका', _formData['temp_municipality']),
                      _previewRow('अस्थायी वडा नं.', _formData['temp_ward']),
                      _previewRow('अस्थायी टोल', _formData['temp_tole']),
                      _previewRow('अस्थायी घर नं.', _formData['temp_house']),
                    ]),
                    const SizedBox(height: 12),
                    _previewSection('३. अन्य विवरण', [
                      _previewRow('वैवाहिक अवस्था', _marital),
                      _previewRow('शैक्षिक योग्यता', _formData['education']),
                      _previewRow('पेशा', _formData['profession']),
                    ]),
                    const SizedBox(height: 12),
                    _previewSection('आवश्यक कागजातहरू', [
                      _previewDoc('नेपाली नागरिकताको प्रमाणपत्र (अनिवार्य)', _formData['doc_citizenship']),
                      _previewDoc('बाबु/आमाको नागरिकताको प्रतिलिपि (अनिवार्य)', _formData['doc_parentCitizenship']),
                      _previewDoc('जन्ममिति खुल्ने प्रमाण (अनिवार्य)', _formData['doc_birthCertificate']),
                      _previewDoc('राहदानी (ऐच्छिक)', _formData['doc_passport']),
                      _previewDoc('बसाइसराई प्रमाणपत्र (ऐच्छिक)', _formData['doc_migration']),
                      _previewDoc('विवाह दर्ता प्रमाणपत्र (ऐच्छिक)', _formData['doc_marriage']),
                    ]),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('फिर्ता जानुहोस्'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.navy),
                              foregroundColor: AppColors.navy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _submit();
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('पेश गर्नुहोस्'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewSection(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(String label, dynamic value) {
    final String display = (value == null || value.toString().trim().isEmpty)
        ? '—'
        : value.toString();
    final bool isEmpty = display == '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
                color: isEmpty ? Colors.grey.shade400 : Colors.black87,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewDoc(String label, dynamic base64Val) {
    final bool hasDoc = base64Val != null && base64Val.toString().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            hasDoc ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: hasDoc ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: hasDoc ? Colors.black87 : Colors.grey.shade500,
                fontWeight: hasDoc ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: hasDoc ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasDoc ? Colors.green.shade300 : Colors.grey.shade300,
              ),
            ),
            child: Text(
              hasDoc ? '✓ अपलोड' : 'खाली',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: hasDoc ? Colors.green.shade700 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
