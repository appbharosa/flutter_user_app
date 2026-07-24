import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../domain/entities/hospital_doctor_booking_item.dart';

class PrescriptionScreen extends StatefulWidget {
  final HospitalDoctorBookingItem booking;

  const PrescriptionScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  bool _isLoading = false;
  Uint8List? _logoBytes;
  bool _logoCaptured = false;
  final Completer<void> _captureCompleter = Completer<void>();

  final GlobalKey _logoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, _captureLogo);
    });
  }

  // ─── Capture the SVG logo ──────────────────────────────────────────
  Future<void> _captureLogo() async {
    try {
      final boundary = _logoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Logo boundary not found – using fallback');
        _logoBytes = await _createFallbackLogo();
        _logoCaptured = true;
        _captureCompleter.complete();
        if (mounted) setState(() {});
        return;
      }
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to capture logo');
      _logoBytes = byteData.buffer.asUint8List();
      _logoCaptured = true;
      _captureCompleter.complete();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error capturing logo: $e');
      _logoBytes = await _createFallbackLogo();
      _logoCaptured = true;
      _captureCompleter.complete();
      if (mounted) setState(() {});
    }
  }

  // ─── Fallback logo ──────────────────────────────────────────────────
  Future<Uint8List> _createFallbackLogo() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = const Color(0xFF1F52A5);
    canvas.drawCircle(const Offset(60, 60), 60, paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Dr.',
        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(60 - textPainter.width / 2, 60 - textPainter.height / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(120, 120);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('Failed to create fallback logo');
    return byteData.buffer.asUint8List();
  }

  // ─── Get logo bytes (waits for capture if needed) ──────────────────
  Future<Uint8List> _getLogoBytes() async {
    if (_logoCaptured && _logoBytes != null) {
      return _logoBytes!;
    }
    if (!_captureCompleter.isCompleted) {
      await _captureCompleter.future;
    }
    if (_logoBytes == null) {
      return await _createFallbackLogo();
    }
    return _logoBytes!;
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1F52A5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.picture_as_pdf),
            onPressed: _isLoading ? null : _downloadPDF,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Logo + Doctor Info ──────────────────────────
            Row(
              children: [
                RepaintBoundary(
                  key: _logoKey,
                  child: svg.SvgPicture.asset(
                    'assets/med.svg',
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(booking.qualification, style: TextStyle(color: Colors.grey[600])),
                      if (booking.specialization != null)
                        Text(booking.specialization!, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // ─── Patient Details ─────────────────────────────────────
            _sectionTitle('Patient Details'),
            _infoRow('Name', booking.patientName),
            _infoRow('Gender', booking.gender),
            _infoRow('DOB', booking.dob),
            _infoRow('Booking ID', booking.bookingId),
            _infoRow('Date', booking.date),
            _infoRow('Time', booking.time),
            const SizedBox(height: 16),

            // ─── Medicines ────────────────────────────────────────────
            if (booking.medicines.isNotEmpty) ...[
              _sectionTitle('Medicines'),
              ...booking.medicines.map((med) => _listTile(med.medicine, med.medicineTime)),
            ],
            const SizedBox(height: 16),

            // ─── Tests ────────────────────────────────────────────────
            if (booking.tests.isNotEmpty) ...[
              _sectionTitle('Tests'),
              ...booking.tests.map((test) => _listTile(test.test, test.testInstruction)),
            ],
            const SizedBox(height: 16),

            // ─── Notes ────────────────────────────────────────────────
            if (booking.notes.isNotEmpty) ...[
              _sectionTitle('Notes'),
              ...booking.notes.map((note) => _bulletTile(note)),
            ],
            const SizedBox(height: 30),

            // ─── Footer: Doctor Signature ─────────────────────────────
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dr. Signature'),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 2, color: Colors.black),
                    const SizedBox(height: 4),
                    Text(booking.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Date'),
                    const SizedBox(height: 8),
                    Text(DateTime.now().toString().split(' ')[0]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F52A5))),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
  );

  Widget _listTile(String title, String subtitle) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF1F52A5)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
        Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  );

  Widget _bulletTile(String note) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.arrow_right, size: 18, color: Color(0xFF1F52A5)),
        const SizedBox(width: 4),
        Expanded(child: Text(note)),
      ],
    ),
  );

  // ─── PDF Download ──────────────────────────────────────────────────────
  Future<void> _downloadPDF() async {
    // Prevent multiple simultaneous downloads
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Ensure logo is captured
      final logoBytes = await _getLogoBytes();
      debugPrint('Logo bytes size: ${logoBytes.length}');

      // Generate PDF
      final pdfBytes = await _generatePDF(logoBytes);
      debugPrint('PDF size: ${pdfBytes.length}');

      // Write to a unique temporary file
      final output = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'prescription_${widget.booking.bookingId}_$timestamp.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      debugPrint('File written: ${file.path}');

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Prescription for ${widget.booking.patientName}',
      );
      debugPrint('Share completed');

      // Optionally, delete the file after sharing (not required, but clean)
      // await file.delete();
    } catch (e, stack) {
      debugPrint('Error in _downloadPDF: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Uint8List> _generatePDF(Uint8List logoBytes) async {
    final pdf = pw.Document();
    final booking = widget.booking;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────────
              pw.Row(
                children: [
                  pw.Image(pw.MemoryImage(logoBytes), width: 60, height: 60),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(booking.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text(booking.qualification, style: pw.TextStyle(color: PdfColors.grey700)),
                        if (booking.specialization != null)
                          pw.Text(booking.specialization!, style: pw.TextStyle(color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // ─── Patient Details ────────────────────────────────────
              pw.Text('Patient Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _pdfInfoRow('Name', booking.patientName),
              _pdfInfoRow('Gender', booking.gender),
              _pdfInfoRow('DOB', booking.dob),
              _pdfInfoRow('Booking ID', booking.bookingId),
              _pdfInfoRow('Date', booking.date),
              _pdfInfoRow('Time', booking.time),
              pw.SizedBox(height: 16),

              // ─── Medicines ──────────────────────────────────────────
              if (booking.medicines.isNotEmpty) ...[
                pw.Text('Medicines', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...booking.medicines.map((med) => pw.Row(
                  children: [pw.Text('• '), pw.Text('${med.medicine}  (${med.medicineTime})')],
                )).toList(),
                pw.SizedBox(height: 8),
              ],

              // ─── Tests ──────────────────────────────────────────────
              if (booking.tests.isNotEmpty) ...[
                pw.Text('Tests', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...booking.tests.map((test) => pw.Row(
                  children: [pw.Text('• '), pw.Text('${test.test}  (${test.testInstruction})')],
                )).toList(),
                pw.SizedBox(height: 8),
              ],

              // ─── Notes ──────────────────────────────────────────────
              if (booking.notes.isNotEmpty) ...[
                pw.Text('Notes', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...booking.notes.map((note) => pw.Row(
                  children: [pw.Text('→ '), pw.Text(note)],
                )).toList(),
                pw.SizedBox(height: 16),
              ],

              // ─── Footer ─────────────────────────────────────────────
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Dr. Signature'),
                      pw.SizedBox(height: 8),
                      pw.Container(width: 120, height: 2, color: PdfColors.black),
                      pw.Text(booking.name),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date'),
                      pw.SizedBox(height: 8),
                      pw.Text(DateTime.now().toString().split(' ')[0]),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}