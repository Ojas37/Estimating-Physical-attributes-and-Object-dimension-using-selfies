import 'dart:convert';

class SkinAnalysisReport {
  final String id;
  final String imagePath;
  final String primaryDiagnosis;
  final double confidence;
  final String confidenceLevel;
  final List<Map<String, dynamic>> predictions;
  final DateTime timestamp;
  final String userId;

  static final DateTime currentDateTime = DateTime.parse('2025-03-05 05:08:36');
  static const String currentUser = 'surajgore-007';

  SkinAnalysisReport({
    required this.id,
    required this.imagePath,
    required this.primaryDiagnosis,
    required this.confidence,
    required this.confidenceLevel,
    required this.predictions,
    DateTime? timestamp,
    String? userId,
  })  : timestamp = timestamp ?? currentDateTime,
        userId = userId ?? currentUser;

  factory SkinAnalysisReport.fromAnalysis(
    String imagePath,
    Map<String, dynamic> analysisResult,
  ) {
    final predictions = (analysisResult['predictions'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final topPrediction = predictions.first;

    return SkinAnalysisReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      primaryDiagnosis: topPrediction['class'],
      confidence: (topPrediction['probability'] as num).toDouble(),
      confidenceLevel: topPrediction['confidence_level'] ?? 'Unknown',
      predictions: predictions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'primaryDiagnosis': primaryDiagnosis,
        'confidence': confidence,
        'confidenceLevel': confidenceLevel,
        'predictions': predictions,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
      };

  factory SkinAnalysisReport.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisReport(
      id: json['id'],
      imagePath: json['imagePath'],
      primaryDiagnosis: json['primaryDiagnosis'],
      confidence: json['confidence'],
      confidenceLevel: json['confidenceLevel'],
      predictions:
          (json['predictions'] as List<dynamic>).cast<Map<String, dynamic>>(),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
    );
  }
}
