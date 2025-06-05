import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../camera/domain/models/measurement.dart';
import '../../../results/data/repositories/measurement_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_indicator.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final Measurement measurement;

  const ImagePreviewScreen({
    Key? key,
    required this.imagePath,
    required this.measurement,
  }) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final MeasurementRepository _measurementRepository = MeasurementRepository();
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _saveMeasurement() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _measurementRepository.initialize();
      await _measurementRepository.saveMeasurementWithImage(
          widget.measurement, widget.imagePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Measurement saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save measurement: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: _isSaving ? Colors.grey : Colors.white,
            ),
            onPressed: _isSaving ? null : _saveMeasurement,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: Center(
                child: LoadingIndicator(
                  message: 'Saving measurement...',
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Width: ${widget.measurement.width} cm',
                  style:
                      AppTheme.bodyLarge.copyWith(color: AppTheme.textMedium),
                ),
                Text(
                  'Height: ${widget.measurement.height} cm',
                  style:
                      AppTheme.bodyLarge.copyWith(color: AppTheme.textMedium),
                ),
                Text(
                  'Depth: ${widget.measurement.depth} cm',
                  style:
                      AppTheme.bodyLarge.copyWith(color: AppTheme.textMedium),
                ),
                Text(
                  'Object Type: ${widget.measurement.objectType}',
                  style:
                      AppTheme.bodyLarge.copyWith(color: AppTheme.textMedium),
                ),
                Text(
                  'Confidence: ${widget.measurement.confidence * 100}%',
                  style:
                      AppTheme.bodyLarge.copyWith(color: AppTheme.textMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
