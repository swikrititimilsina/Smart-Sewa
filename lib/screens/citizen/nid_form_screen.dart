// lib/screens/citizen/nid_form_screen.dart
import 'package:flutter/material.dart';
import 'package:smartsewa/widgets/nid_widgets.dart';
import 'package:smartsewa/screens/citizen/section_parent.dart';
import 'package:smartsewa/screens/citizen/section_spouse.dart';

class NIDFormScreen extends StatefulWidget {
  const NIDFormScreen({super.key});

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
  bool _genderError = false;
  bool _maritalError = false;

  // ── Keys to access required upload tile states for validation ──
  final _citizenshipKey = GlobalKey<DocUploadTileState>();
  final _parentCitizenshipKey = GlobalKey<DocUploadTileState>();

  // ─────────────────────────────────────────────────────────────────────────
  // Validate everything, then show the confirm dialog
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    // 1. Validate TextFormField / dropdown validators
    final formValid = _formKey.currentState?.validate() ?? false;

    // 2. Validate radio groups
    setState(() {
      _natTypeError = _natType == null;
      _genderError = _gender == null;
      _maritalError = _marital == null;
    });

    // 3. Validate required uploads
    final citizenshipUploaded =
        _citizenshipKey.currentState?.uploaded ?? false;
    final parentUploaded =
        _parentCitizenshipKey.currentState?.uploaded ?? false;

    if (!citizenshipUploaded || !parentUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠ अनिवार्य कागजातहरू अपलोड गर्नुहोस् '
            '(नागरिकता र बाबु/आमाको नागरिकता)',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!formValid || _natTypeError || _genderError || _maritalError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ कृपया सबै अनिवार्य फिल्डहरू भर्नुहोस्'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 4. All valid — confirm dialog
    final confirmed = await _showConfirmDialog();
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ फाराम पेश गरिएको छ (Form Submitted)'),
          backgroundColor: kDarkBlue,
          duration: Duration(seconds: 3),
        ),
      );
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
            Icon(Icons.help_outline_rounded, color: kDarkBlue, size: 24),
            SizedBox(width: 8),
            Text(
              'फाराम पेश गर्ने?',
              style: TextStyle(fontSize: 16, color: kDarkBlue),
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
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('पेश गर्नुहोस्',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear / reset the whole form
  // ─────────────────────────────────────────────────────────────────────────
  void _clear() {
    _formKey.currentState?.reset();

    // Also clear upload tile states via their keys
    _citizenshipKey.currentState?.clear();
    _parentCitizenshipKey.currentState?.clear();

    setState(() {
      _natType = null;
      _gender = null;
      _marital = null;
      _natTypeError = false;
      _genderError = false;
      _maritalError = false;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kDarkBlue,
        title: const Text(
          'राष्ट्रिय परिचयपत्र फाराम',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildHeader(),
            const SizedBox(height: 10),

            // ── Document Uploads ─────────────────────────────────────────
            RepaintBoundary(child: _buildDocumentUploads()),

            // ── Section 1 ────────────────────────────────────────────────
            RepaintBoundary(child: _buildSection1()),

            // ── Section 2 ────────────────────────────────────────────────
            RepaintBoundary(child: _buildSection2()),

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
                  const SectionHeader(' ५. बाबु/पिताको विवरण'),
                  const ParentSection(
                    foreignLabel:
                        'बाबु विदेशी भए बाबु नागरिक रहेको मुलुकको नाम :',
                  ),
                  const FormDivider(),
                  const SectionHeader(' ६. आमाको विवरण'),
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
                  _buildSimpleNameBlock(' ७. हजुरबुबाको विवरण'),
                  _buildSimpleNameBlock(' ८. हजुरआमाको विवरण'),
                  const SectionHeader(' ९. पति/पत्नीको विवरण'),
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

            _buildButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Document uploads section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDocumentUploads() {
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
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kDarkBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: kDarkBlue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: kDarkBlue.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'स्वीकृत फाइल: PDF, DOC, DOCX, JPG, PNG, '
                        'GIF, BMP, WEBP, XLS, XLSX, TXT',
                        style:
                            TextStyle(fontSize: 10, color: kDarkBlue),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Required uploads (keyed for validation + clear) ──
              DocUploadTile(
                key: _citizenshipKey,
                icon: Icons.badge_outlined,
                title: 'नेपाली नागरिकताको प्रमाणपत्रको सक्कल',
                required: true,
              ),
              DocUploadTile(
                key: _parentCitizenshipKey,
                icon: Icons.people_outline,
                title: 'बाबु/आमाको नागरिकताको प्रतिलिपि',
                required: true,
              ),

              // ── Optional uploads ──
              const DocUploadTile(
                icon: Icons.calendar_today_outlined,
                title:
                    'जन्ममिति खुल्ने प्रमाण / गाउँपालिका सिफारिस',
              ),
              const DocUploadTile(
                icon: Icons.flight_outlined,
                title: 'राहदानीको सक्कल वा प्रतिलिपि (भएमा)',
              ),
              const DocUploadTile(
                icon: Icons.transfer_within_a_station_outlined,
                title: 'बसाइसराई प्रमाणपत्र (लागु भएमा)',
              ),
              const DocUploadTile(
                icon: Icons.favorite_border_outlined,
                title: 'विवाह दर्ता प्रमाणपत्र (विवाहितको हकमा)',
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kDarkBlue,
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
  // Section 1 — NIN (admin only)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          ' १. राष्ट्रिय परिचय नं. (National Identity Number - NIN):',
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: TextFormField(
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'प्रशासनद्वारा भरिनेछ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '* यो नम्बर प्रशासनले प्रदान गर्नेछ',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section 2 — Personal details
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(' २. आवेदकको व्यक्तिगत विवरण'),
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
              const Wrap(spacing: 12, runSpacing: 8, children: [
                LabeledField(
                    label: 'पहिलो नाम:', width: 120, required: true),
                LabeledField(label: 'बीचको नाम:', width: 120),
                LabeledField(label: 'थर:', width: 120, required: true),
              ]),
              const SizedBox(height: 8),
              const Text(
                'Name (English):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Wrap(spacing: 12, runSpacing: 8, children: [
                LabeledField(
                    label: 'First Name:', width: 120, required: true),
                LabeledField(label: 'Middle Name:', width: 120),
                LabeledField(
                    label: 'Last Name:', width: 120, required: true),
              ]),
              const SizedBox(height: 8),
              const Wrap(spacing: 16, runSpacing: 8, children: [
                DateEntryWidget(label: 'जन्म मिति (वि.सं.) :'),
                DateEntryWidget(label: 'Date of Birth (AD) :'),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: const [
                LabeledField(
                  label: 'नागरिकता प्रमाणपत्र नं.:',
                  width: 130,
                  required: true,
                ),
                DistrictDropdown(
                  label: 'जारी जिल्ला:',
                  width: 150,
                  required: true,
                ),
              ]),
              const SizedBox(height: 4),
              const DateEntryWidget(label: 'जारी मिति:'),
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
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text(k,
                                style: const TextStyle(fontSize: 12)),
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
        const SectionHeader(' ३. ठेगाना विवरण'),
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
        const SectionHeader(' ४. अन्य विवरण'),
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
                              _genderError = false;
                            }),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(e.$1,
                              style: const TextStyle(fontSize: 12)),
                        ]),
                    ],
                  ),
                  if (_genderError)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 4),
                      child: Text(
                        'कृपया लिङ्ग छान्नुहोस्',
                        style:
                            TextStyle(color: Colors.red, fontSize: 11),
                      ),
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
                          ),
                          Text(e.$1,
                              style: const TextStyle(fontSize: 11)),
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
              const SizedBox(height: 8),
              const LabeledField(
                label: 'पितृत्वको ठेगान नभएको हकमा संरक्षकको नाम :',
                width: 200,
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fingerprint ──
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'औठाको छाप',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'बाकस थिचेर औठा स्क्यान गर्नुहोस्',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FingerprintBox(label: 'दायाँ'),
                    SizedBox(width: 8),
                    FingerprintBox(label: 'बायाँ'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Signature + admin panel ──
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Applicant signature
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('भवदीय,', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 8),
                    Text('निवेदकको दस्तखत:',
                        style: TextStyle(fontSize: 12)),
                    SizedBox(height: 6),
                    SignaturePad(),
                    SizedBox(height: 8),
                    Text('मिति:......................................',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              // Admin section (read-only display)
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'रुजु गर्ने अधिकारी:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'प्रशासन मात्र',
                            style: TextStyle(
                                fontSize: 9, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'पद:................................................',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'दस्तखत:......................................',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'मिति:............................................',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Submit / Clear buttons
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('पेश गर्नुहोस् (Submit)',
              style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 14),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.clear_rounded, size: 16),
          label: const Text('मेटाउनुहोस् (Clear)',
              style: TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}