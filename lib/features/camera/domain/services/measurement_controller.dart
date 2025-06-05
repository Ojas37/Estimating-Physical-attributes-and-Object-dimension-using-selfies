// lib/features/camera/domain/measurement_controller.dart

import 'package:flutter/foundation.dart';
import 'ai_service.dart';

class MeasurementController extends ChangeNotifier {
  final AIService _aiService = AIService();
  bool _isProcessing = false;
  String? _error;
  List<AIMeasurementResult> _measurements = [];

  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<AIMeasurementResult> get measurements => _measurements;

  Future<void> processMeasurement(String imagePath) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      _measurements = await _aiService.processMeasurement(imagePath);
    } catch (e) {
      _error = e.toString();
      _measurements = [];
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> checkServerConnection() async {
    return _aiService.checkServer();
  }
}
