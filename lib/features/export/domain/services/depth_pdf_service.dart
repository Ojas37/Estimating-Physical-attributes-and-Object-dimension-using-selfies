import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class DepthPDFService {
  Future<File> generateAndSavePDF(
      String imagePath, Map<String, dynamic> analysisResult) async {
    final pdf = pw.Document();
    final originalImage = File(imagePath).readAsBytesSync();

    // Decode base64 visualizations
    final visualizations =
        analysisResult['visualizations'] as Map<String, dynamic>;
    final stats = analysisResult['statistics'] as Map<String, dynamic>;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(),
          _buildOriginalImage(pw.MemoryImage(originalImage)),
          _buildDepthMaps(visualizations),
          _buildStatistics(stats),
          _buildFooter(),
        ],
      ),
    );

    return await _savePDF(
        pdf, DateTime.now().millisecondsSinceEpoch.toString());
  }

  pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Depth Analysis Report',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text(DateTime.now().toString().split('.')[0]),
        ],
      ),
    );
  }

  pw.Widget _buildOriginalImage(pw.ImageProvider image) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Original Image',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Image(image, height: 200),
        ],
      ),
    );
  }

  pw.Widget _buildDepthMaps(Map<String, dynamic> visualizations) {
    final depthMaps = [
      'depth_inferno',
      'depth_plasma',
      'depth_magma',
      'depth_viridis'
    ].where((key) => visualizations.containsKey(key)).map((key) {
      final bytes = base64Decode(visualizations[key]);
      return pw.Column(children: [
        pw.Text(key
            .split('_')
            .map((e) => e[0].toUpperCase() + e.substring(1))
            .join(' ')),
        pw.Image(pw.MemoryImage(bytes), height: 150),
      ]);
    }).toList();

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Depth Visualizations',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Wrap(spacing: 10, runSpacing: 10, children: depthMaps),
        ],
      ),
    );
  }

  pw.Widget _buildStatistics(Map<String, dynamic> stats) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Depth Statistics',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...stats.entries.map((entry) => pw.Text(
              '${entry.key.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ')}: ${entry.value.toStringAsFixed(2)}')),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Generated on ${DateTime.now().toString().split('.')[0]}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
    );
  }

  Future<File> _savePDF(pw.Document pdf, String reportId) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/depth_analysis_$reportId.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sharePDF(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)],
          text: 'Depth Analysis Report');
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }
}
