// lib/widgets/nid_widgets.dart
import 'package:flutter/material.dart';


const Color kDarkBlue = Color(0xFF0D2B6E);
const Color kBg = Color(0xFFF0F4FF);

const List<String> kNepalProvinces = [
  'कोशी प्रदेश (प्रदेश नं. १)',
  'मधेश प्रदेश (प्रदेश नं. २)',
  'बागमती प्रदेश (प्रदेश नं. ३)',
  'गण्डकी प्रदेश (प्रदेश नं. ४)',
  'लुम्बिनी प्रदेश (प्रदेश नं. ५)',
  'कर्णाली प्रदेश (प्रदेश नं. ६)',
  'सुदूरपश्चिम प्रदेश (प्रदेश नं. ७)',
];

const List<String> kNepalDistricts = [
  'अछाम', 'अर्घाखाँची', 'आरु', 'बाग्लुङ', 'बाँके', 'बर्दिया', 'भक्तपुर',
  'भोजपुर', 'चितवन', 'दाङ', 'डडेलधुरा', 'दैलेख', 'डोल्पा', 'डोटी',
  'गोरखा', 'गुल्मी', 'हुम्ला', 'इलाम', 'जाजरकोट', 'झापा', 'जुम्ला',
  'काभ्रेपलाञ्चोक', 'काँचनपुर', 'काठमाडौं', 'काभ्रे', 'खोटाङ',
  'किराँत', 'कोशी', 'ललितपुर', 'लमजुङ', 'लिम्बु', 'मकवानपुर',
  'मनाङ', 'मुगु', 'मुस्ताङ', 'म्याग्दी', 'नवलपरासी', 'नुवाकोट',
  'ओखलढुङ्गा', 'पर्वत', 'पाँचथर', 'पर्सा', 'प्युठान', 'रामेछाप',
  'रसुवा', 'रौतहट', 'रोल्पा', 'रुकुम पश्चिम', 'रुकुम पूर्व',
  'रुपन्देही', 'सल्यान', 'सङ्खुवासभा', 'सप्तरी', 'सर्लाही',
  'सिन्धुपाल्चोक', 'सिन्धुली', 'सिराहा', 'सोलुखुम्बु', 'सुनसरी',
  'सुर्खेत', 'सिन्धु', 'तनहुँ', 'तेह्रथुम', 'ताप्लेजुङ', 'थानकोट',
  'उदयपुर', 'बाँकेकट्टन', 'बारा', 'कपिलवस्तु', 'नवलपुर',
  'पाल्पा', 'धनुषा', 'महोत्तरी', 'सिरहा', 'धादिङ',
  'भोटकोशी', 'दोलखा', 'बझाङ', 'बाजुरा', 'दार्चुला',
];

const List<String> kAllowedExtensions = [
  'pdf', 'doc', 'docx',
  'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
  'xls', 'xlsx', 'txt',
];

// ── Helper: truncate long filenames for display ──
String _truncateFileName(String name, {int max = 28}) {
  if (name.length <= max) return name;
  final ext = name.contains('.') ? '.${name.split('.').last}' : '';
  return '${name.substring(0, max - ext.length - 3)}...$ext';
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Section header bar ──
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kDarkBlue.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: kDarkBlue,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Thin divider ──
// ─────────────────────────────────────────────────────────────────────────────
class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: Colors.grey.shade300);
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Label + underline field ──
// ─────────────────────────────────────────────────────────────────────────────
class LabeledField extends StatelessWidget {
  final String label;
  final double width;
  final bool required;
  final TextEditingController? controller;

  const LabeledField({
    super.key,
    required this.label,
    this.width = 160,
    this.required = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 2),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              border: UnderlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 12),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty) ? 'आवश्यक छ' : null
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── District dropdown ──
// ─────────────────────────────────────────────────────────────────────────────
class DistrictDropdown extends StatefulWidget {
  final String label;
  final double width;
  final bool required;

  const DistrictDropdown({
    super.key,
    required this.label,
    this.width = 160,
    this.required = false,
  });

  @override
  State<DistrictDropdown> createState() => _DistrictDropdownState();
}

class _DistrictDropdownState extends State<DistrictDropdown> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              children: widget.required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 2),
          DropdownButtonFormField<String>(
            value: _selected,
            isDense: true,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              border: UnderlineInputBorder(),
            ),
            hint: const Text(
              'छान्नुहोस्',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            items: kNepalDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => _selected = v),
            validator: widget.required
                ? (v) => (v == null || v.isEmpty) ? 'आवश्यक छ' : null
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Province dropdown ──
// ─────────────────────────────────────────────────────────────────────────────
class ProvinceDropdown extends StatefulWidget {
  final String label;
  final bool required;

  const ProvinceDropdown({
    super.key,
    required this.label,
    this.required = false,
  });

  @override
  State<ProvinceDropdown> createState() => _ProvinceDropdownState();
}

class _ProvinceDropdownState extends State<ProvinceDropdown> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
            children: widget.required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 2),
        DropdownButtonFormField<String>(
          value: _selected,
          isDense: true,
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            border: UnderlineInputBorder(),
          ),
          hint: const Text(
            'प्रदेश छान्नुहोस्',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          items: kNepalProvinces
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() => _selected = v),
          validator: widget.required
              ? (v) => (v == null || v.isEmpty) ? 'आवश्यक छ' : null
              : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Date entry DD/MM/YYYY ──
// ─────────────────────────────────────────────────────────────────────────────
class DateEntryWidget extends StatelessWidget {
  final String label;

  const DateEntryWidget({super.key, required this.label});

  Widget _box(String hint) {
    return SizedBox(
      width: hint == 'YYYY' ? 52 : 32,
      child: TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: hint == 'YYYY' ? 4 : 2,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          isDense: true,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        if (label.isNotEmpty)
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
        _box('DD'),
        const Text('/', style: TextStyle(fontSize: 12)),
        _box('MM'),
        const Text('/', style: TextStyle(fontSize: 12)),
        _box('YYYY'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Address block with province + district dropdowns ──
// ─────────────────────────────────────────────────────────────────────────────
class AddressBlock extends StatelessWidget {
  final String title;

  const AddressBlock({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        const ProvinceDropdown(label: 'प्रदेश:'),
        const SizedBox(height: 8),
        const DistrictDropdown(label: 'जिल्ला:', width: double.infinity),
        const SizedBox(height: 8),
        const LabeledField(
            label: 'गाउँपालिका/नगरपालिका:', width: double.infinity),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
                child: LabeledField(label: 'वडा नं:', width: double.infinity)),
            const SizedBox(width: 8),
            const Expanded(
                child: LabeledField(label: 'टोल:', width: double.infinity)),
          ],
        ),
        const SizedBox(height: 8),
        const LabeledField(label: 'घर नं:', width: double.infinity),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Bilingual name row ──
// ─────────────────────────────────────────────────────────────────────────────
class NameRow extends StatelessWidget {
  final String nepLabel;
  final String engLabel;

  const NameRow({super.key, required this.nepLabel, required this.engLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          LabeledField(label: '$nepLabel (नेपाली):', width: 140),
          LabeledField(label: '$engLabel (English):', width: 140),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Document upload tile ──
// ─────────────────────────────────────────────────────────────────────────────
class DocUploadTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool required;

  const DocUploadTile({
    super.key,
    required this.icon,
    required this.title,
    this.required = false,
  });

  @override
  State<DocUploadTile> createState() => DocUploadTileState();
}

class DocUploadTileState extends State<DocUploadTile> {
  bool _loading = false;

  /// Publicly readable upload state
  String? uploadedFileName;
  int? uploadedFileSize; // bytes

  bool get uploaded => uploadedFileName != null;

  /// Public entry-point so parent widgets / keys can trigger the picker.
  /// e.g. _citizenshipKey.currentState?.upload()
  Future<void> upload() => _pickFile();

  // ── Internal file picker ──
  Future<void> _pickFile() async {
    if (_loading) return; // guard double-taps
    setState(() => _loading = true);

    try {
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: kAllowedExtensions,
      //   allowMultiple: false,
      //   withData: false,
      // );
      
      // Simulate file picking
      await Future.delayed(const Duration(seconds: 1));
      final result = null;

      if (result != null && result.files.single.path != null) {
        final file = result.files.first;
        setState(() {
          uploadedFileName = file.name;
          uploadedFileSize = file.size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('फाइल चयन गर्न सकिएन: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Clears the current upload so the user can re-pick.
  void clear() {
    setState(() {
      uploadedFileName = null;
      uploadedFileSize = null;
    });
  }

  // ── Helpers ──
  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData _fileTypeIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image_outlined;
    }
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(ext)) return Icons.description_outlined;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: uploaded
              ? Colors.green.shade300
              : widget.required
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Icon(
              uploaded ? _fileTypeIcon(uploadedFileName!) : widget.icon,
              color: uploaded ? Colors.green : kDarkBlue,
              size: 22,
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: uploaded ? Colors.green.shade700 : kDarkBlue,
              ),
            ),
            subtitle: uploaded
                ? Text(
                    _truncateFileName(uploadedFileName!),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    widget.required ? 'अनिवार्य' : 'ऐच्छिक',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.required
                          ? Colors.red.shade400
                          : Colors.grey,
                    ),
                  ),
            trailing: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : uploaded
                    ? GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.refresh,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'फेरि अपलोड',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kDarkBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.upload_file,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'अपलोड',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),

          // ── File info bar shown after upload ──
          if (uploaded)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      uploadedFileName!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (uploadedFileSize != null)
                    Text(
                      _formatSize(uploadedFileSize!),
                      style: TextStyle(
                          fontSize: 10, color: Colors.green.shade600),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Digital signature pad ──
// ─────────────────────────────────────────────────────────────────────────────
class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];

  bool get _hasSignature => _points.any((p) => p != null);

  void clear() => setState(() => _points.clear());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 180,
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: GestureDetector(
            onPanUpdate: (d) =>
                setState(() => _points.add(d.localPosition)),
            onPanEnd: (_) => setState(() => _points.add(null)),
            child: CustomPaint(
              painter: _SigPainter(_points),
              child: _hasSignature
                  ? const SizedBox()
                  : const Center(
                      child: Text(
                        'यहाँ दस्तखत गर्नुहोस्',
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ),
        if (_hasSignature)
          TextButton(
            onPressed: clear,
            child: const Text(
              'मेटाउनुहोस्',
              style: TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class _SigPainter extends CustomPainter {
  final List<Offset?> points;

  _SigPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kDarkBlue
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SigPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Fingerprint box ──
// ─────────────────────────────────────────────────────────────────────────────
class FingerprintBox extends StatefulWidget {
  final String label;

  const FingerprintBox({super.key, required this.label});

  @override
  State<FingerprintBox> createState() => _FingerprintBoxState();
}

class _FingerprintBoxState extends State<FingerprintBox> {
  bool _scanned = false;
  bool _scanning = false;

  Future<void> _scan() async {
    if (_scanning || _scanned) return;
    setState(() => _scanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _scanning = false;
        _scanned = true;
      });
    }
  }

  void reset() => setState(() {
        _scanned = false;
        _scanning = false;
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _scanned ? null : _scan,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 26,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Text(widget.label,
                style: const TextStyle(fontSize: 11)),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(
                  color: _scanned ? Colors.green : Colors.grey),
              color: _scanned
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
            ),
            child: _scanning
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _scanned
                    ? const Icon(Icons.fingerprint,
                        color: Colors.green, size: 36)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.fingerprint,
                              color: Colors.grey, size: 28),
                          Text(
                            'थिच्नुहोस्',
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}