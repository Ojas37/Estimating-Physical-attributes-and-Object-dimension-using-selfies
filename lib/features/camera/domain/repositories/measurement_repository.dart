import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/measurement.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MeasurementRepository {
  static const String _storageDir = 'measurements';
  static const String _imageDir = 'images';
  static const String _reportDir = 'reports';
  static final DateTime currentDateTime = DateTime.parse('2025-02-08 15:51:27');
  static const String currentUser = 'surajgore-007';

  Future<String> get _basePath async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  Future<void> initialize() async {
    final base = await _basePath;
    await Directory('$base/$_storageDir').create(recursive: true);
    await Directory('$base/$_imageDir').create(recursive: true);
    await Directory('$base/$_reportDir').create(recursive: true);
  }

  Future<String> saveMeasurementWithImage(
    Measurement measurement,
    String originalImagePath,
  ) async {
    try {
      final base = await _basePath;
      final timestamp = measurement.timestamp.millisecondsSinceEpoch;
      final measurementId = 'measurement_$timestamp';

      // Copy image to app storage
      final imageFile = File(originalImagePath);
      final newImagePath = '$base/$_imageDir/$measurementId.jpg';
      await imageFile.copy(newImagePath);

      // Save measurement data
      final measurementFile = File('$base/$_storageDir/$measurementId.json');
      final measurementData = {
        ...measurement.toJson(),
        'id': measurementId,
        'imagePath': newImagePath,
        'user': currentUser,
        'timestamp': currentDateTime.toIso8601String(),
      };
      await measurementFile.writeAsString(jsonEncode(measurementData));

      // Generate PDF report
      await _generatePdfReport(measurement, newImagePath, measurementId);

      return measurementId;
    } catch (e) {
      print('Error saving measurement: $e');
      rethrow;
    }
  }

  Future<String> _generatePdfReport(
    Measurement measurement,
    String imagePath,
    String measurementId,
  ) async {
    try {
      final pdf = pw.Document();
      final image = pw.MemoryImage(
        File(imagePath).readAsBytesSync(),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(),
            _buildMeasurementInfo(measurement),
            _buildImageSection(image),
            _buildFooter(),
          ],
        ),
      );

      final base = await _basePath;
      final reportPath = '$base/$_reportDir/$measurementId.pdf';
      final file = File(reportPath);
      await file.writeAsBytes(await pdf.save());
      return reportPath;
    } catch (e) {
      print('Error generating PDF report: $e');
      rethrow;
    }
  }

  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 2, color: PdfColors.black),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Measurement Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Date: ${currentDateTime.toString().substring(0, 10)}'),
              pw.Text('Time: ${currentDateTime.toString().substring(11, 19)}'),
              pw.Text('User: $currentUser'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMeasurementInfo(Measurement measurement) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Measurement Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildMeasurementRow('Object Type:', measurement.objectType),
          _buildMeasurementRow(
              'Width:', '${measurement.width.toStringAsFixed(2)} cm'),
          _buildMeasurementRow(
              'Height:', '${measurement.height.toStringAsFixed(2)} cm'),
          _buildMeasurementRow(
              'Depth:', '${measurement.depth.toStringAsFixed(2)} cm'),
          _buildMeasurementRow(
            'Confidence:',
            '${(measurement.confidence * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMeasurementRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  pw.Widget _buildImageSection(pw.MemoryImage image) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Captured Image',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 400,
            child: pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 1, color: PdfColors.grey),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by Measure Me App'),
          pw.Text('Page ${DateTime.now().toString()}'),
        ],
      ),
    );
  }

  Future<List<MeasurementData>> getAllMeasurements() async {
    try {
      final base = await _basePath;
      final dir = Directory('$base/$_storageDir');
      if (!await dir.exists()) return [];

      final files = await dir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();

      final measurements = <MeasurementData>[];
      for (final file in files) {
        try {
          final content = await File(file.path).readAsString();
          final json = jsonDecode(content);
          measurements.add(
            MeasurementData(
              measurement: Measurement.fromJson(json),
              id: json['id'],
              imagePath: json['imagePath'],
              reportPath: '$base/$_reportDir/${json['id']}.pdf',
            ),
          );
        } catch (e) {
          print('Error reading measurement file ${file.path}: $e');
        }
      }

      return measurements
        ..sort((a, b) =>
            b.measurement.timestamp.compareTo(a.measurement.timestamp));
    } catch (e) {
      print('Error getting measurements: $e');
      return [];
    }
  }

  Future<void> deleteMeasurement(String measurementId) async {
    try {
      final base = await _basePath;

      // Delete measurement file
      final measurementFile = File('$base/$_storageDir/$measurementId.json');
      if (await measurementFile.exists()) {
        await measurementFile.delete();
      }

      // Delete image file
      final imageFile = File('$base/$_imageDir/$measurementId.jpg');
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Delete PDF report
      final reportFile = File('$base/$_reportDir/$measurementId.pdf');
      if (await reportFile.exists()) {
        await reportFile.delete();
      }
    } catch (e) {
      print('Error deleting measurement: $e');
      rethrow;
    }
  }
}

class MeasurementData {
  final Measurement measurement;
  final String id;
  final String imagePath;
  final String reportPath;

  MeasurementData({
    required this.measurement,
    required this.id,
    required this.imagePath,
    required this.reportPath,
  });
}
