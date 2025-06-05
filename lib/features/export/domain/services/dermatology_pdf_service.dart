import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../results/data/models/dermatology_report.dart';

class DermatologyPDFService {
  Future<File> generateAndSavePDF(DermatologyReport report) async {
    final pdf = pw.Document();

    final image = File(report.imagePath).readAsBytesSync();
    final pdfImage = pw.MemoryImage(image);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildReportHeader(),
          _buildDermatologyInfo(report),
          _buildDiagnosisSection(report),
          _buildImageSection(pdfImage),
          _buildAnalysisSection(report),
          _buildPredictionsTable(report),
          _buildFooterSection(report),
        ],
      ),
    );

    return await _saveReportPDF(pdf, report.id);
  }

  pw.Widget _buildReportHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Dermatology Analysis Report',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(DateTime.now().toString().split('.')[0]),
        ],
      ),
    );
  }

  pw.Widget _buildDermatologyInfo(DermatologyReport report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Analysis Details',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Date: ${report.timestamp.toString().split('.')[0]}'),
          pw.Text('Report ID: ${report.id}'),
          pw.Text('User ID: ${report.userId}'),
        ],
      ),
    );
  }

  pw.Widget _buildDiagnosisSection(DermatologyReport report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Primary Diagnosis',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Condition: ${report.primaryDiagnosis}'),
          pw.Text(
              'Confidence: ${(report.confidence * 100).toStringAsFixed(1)}%'),
          pw.Text('Confidence Level: ${report.confidenceLevel}'),
        ],
      ),
    );
  }

  pw.Widget _buildImageSection(pw.MemoryImage image) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Analysis Image',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Image(image, height: 200),
        ],
      ),
    );
  }

  pw.Widget _buildAnalysisSection(DermatologyReport report) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Detailed Analysis',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(report.enhancedAnalysis),
        ],
      ),
    );
  }

  pw.Widget _buildPredictionsTable(DermatologyReport report) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Text('Condition',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Probability',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Confidence Level',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
        ...report.predictions.map((prediction) => pw.TableRow(
              children: [
                pw.Text(prediction['class'] as String),
                pw.Text(
                    '${((prediction['probability'] as double) * 100).toStringAsFixed(1)}%'),
                pw.Text(prediction['confidence_level'] as String),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildFooterSection(DermatologyReport report) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Generated on ${DateTime.now().toString().split('.')[0]}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  Future<File> _saveReportPDF(pw.Document pdf, String reportId) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/dermatology_report_$reportId.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePDF(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)],
          text: 'Dermatology Analysis Report');
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }
}
