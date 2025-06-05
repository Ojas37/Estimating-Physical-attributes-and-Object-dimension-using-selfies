// lib/features/camera/domain/services/measurement_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/measurement.dart';
import '../repositories/measurement_repository.dart';

class MeasurementService {
  final MeasurementRepository _repository;

  MeasurementService({
    MeasurementRepository? repository,
  }) : _repository = repository ?? MeasurementRepository();

  Future<void> initialize() async {
    await _repository.initialize();
  }

  Future<String> saveMeasurement(
    Measurement measurement,
    String imagePath,
  ) async {
    return await _repository.saveMeasurementWithImage(measurement, imagePath);
  }

  Future<List<MeasurementData>> getAllMeasurements() async {
    return await _repository.getAllMeasurements();
  }

  Future<void> deleteMeasurement(String id) async {
    await _repository.deleteMeasurement(id);
  }

  String formatMeasurement(Measurement measurement) {
    return '''
Width: ${measurement.width.toStringAsFixed(2)} cm
Height: ${measurement.height.toStringAsFixed(2)} cm
Depth: ${measurement.depth.toStringAsFixed(2)} cm
Object Type: ${measurement.objectType}
Confidence: ${(measurement.confidence * 100).toStringAsFixed(1)}%
''';
  }

  Future<File> exportMeasurementsToCsv(
      List<MeasurementData> measurements) async {
    final csv = StringBuffer();

    // Add header
    csv.writeln('ID,Timestamp,Object Type,Width,Height,Depth,Confidence');

    // Add data rows
    for (final data in measurements) {
      final m = data.measurement;
      csv.writeln(
        '${data.id},${m.timestamp.toIso8601String()},${m.objectType},'
        '${m.width},${m.height},${m.depth},${m.confidence}',
      );
    }

    // Save to file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/measurements.csv');
    await file.writeAsString(csv.toString());
    return file;
  }
}
