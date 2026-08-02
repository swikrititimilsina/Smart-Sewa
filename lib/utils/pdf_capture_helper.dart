import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Captures the full scrollable form as a multi-page A4 PDF and returns
/// the PDF bytes as a Base64-encoded string ready for Firestore storage.
///
/// [controller] – the ScreenshotController attached to the form.
/// [context]    – BuildContext from the form screen (used for theme/media).
/// [formWidget] – the full form widget tree to render off-screen.
Future<String> captureFormAsPdfBase64({
  required ScreenshotController controller,
  required BuildContext context,
  required Widget formWidget,
  double pixelRatio = 1.5,
}) async {
  // 1. Render the ENTIRE form off-screen as one tall image.
  // We wrap it in a MaterialApp to provide Directionality, Localizations, etc.,
  // which prevents the "No Directionality widget found" red screen error.
  // We use SingleChildScrollView so captureFromLongWidget can stitch it together.
  final Uint8List imageBytes = await controller.captureFromLongWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: formWidget,
          ),
        ),
      ),
    ),
    pixelRatio: pixelRatio,
    delay: const Duration(milliseconds: 300),
    context: context,
  );

  // 2. Decode image dimensions.
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(imageBytes, completer.complete);
  final decodedImage = await completer.future;
  final imgWidth = decodedImage.width.toDouble();
  final imgHeight = decodedImage.height.toDouble();

  // 3. A4 usable area (10pt margins on each side).
  final usableWidth = PdfPageFormat.a4.width - 20;
  final usableHeight = PdfPageFormat.a4.height - 20;

  // 4. Scale so the image fills the page width.
  final scale = usableWidth / imgWidth;
  final scaledFullHeight = imgHeight * scale;

  // 5. Number of pages needed.
  final pageCount = (scaledFullHeight / usableHeight).ceil();

  // 6. Build multi-page PDF.
  final pdf = pw.Document();
  final pdfImage = pw.MemoryImage(imageBytes);

  for (var i = 0; i < pageCount; i++) {
    // Vertical offset into the image for this page (in image-pixel space).
    final cropTop = i * (usableHeight / scale);
    // Remaining image height from cropTop.
    final remaining = imgHeight - cropTop;
    // How much of the image this page covers (in image pixels).
    final sliceH = remaining < (usableHeight / scale)
        ? remaining
        : (usableHeight / scale);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        build: (_) {
          return pw.ClipRect(
            child: pw.Container(
              width: usableWidth,
              height: sliceH * scale,
              child: pw.OverflowBox(
                maxWidth: usableWidth,
                maxHeight: scaledFullHeight,
                alignment: pw.Alignment.topLeft,
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(top: -cropTop * scale),
                  child: pw.Image(
                    pdfImage,
                    width: usableWidth,
                    height: scaledFullHeight,
                    fit: pw.BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  final pdfBytes = await pdf.save();
  return base64Encode(pdfBytes);
}
