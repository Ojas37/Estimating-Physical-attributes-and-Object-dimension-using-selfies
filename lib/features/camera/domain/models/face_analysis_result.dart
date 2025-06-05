import 'package:flutter/foundation.dart';

class FaceAnalysisResult {
  final double estimatedAge;
  final double ageConfidence;
  final Map<String, double> gender;
  final Map<String, double> race;
  final String skinTone;
  final List<int> skinColor;
  final Map<String, dynamic> rawData; // Add this field

  const FaceAnalysisResult({
    required this.estimatedAge,
    required this.ageConfidence,
    required this.gender,
    required this.race,
    required this.skinTone,
    required this.skinColor,
    this.rawData = const {}, // Add this parameter
  });

  factory FaceAnalysisResult.fromJson(Map<String, dynamic> json) {
    debugPrint('Raw JSON received: ${json.toString()}');

    try {
      final result = json['result'] as Map<String, dynamic>?;
      if (result == null) {
        debugPrint('No result field in JSON');
        return FaceAnalysisResult(
          estimatedAge: 0.0,
          ageConfidence: 0.0,
          gender: {'unknown': 1.0},
          race: {'unknown': 1.0},
          skinTone: 'Unknown',
          skinColor: [128, 128, 128],
          rawData: json,
        );
      }

      final age = result['age'] as Map<String, dynamic>? ??
          {'estimated_age': 0.0, 'confidence': 0.0};
      final skinTone = result['skin_tone'] as Map<String, dynamic>? ??
          {
            'name': 'Unknown',
            'rgb_values': [128, 128, 128]
          };

      // Convert number types to ensure proper casting
      Map<String, double> convertToDoubleMap(Map<dynamic, dynamic>? map) {
        if (map == null) return {'unknown': 1.0};
        return map.map((key, value) => MapEntry(key.toString().toLowerCase(),
            (value is num) ? value.toDouble() : 1.0));
      }

      return FaceAnalysisResult(
        estimatedAge: (age['estimated_age'] as num?)?.toDouble() ?? 0.0,
        ageConfidence: (age['confidence'] as num?)?.toDouble() ?? 0.0,
        gender: convertToDoubleMap(result['gender'] as Map?),
        race: convertToDoubleMap(result['race'] as Map?),
        skinTone: skinTone['name']?.toString() ?? 'Unknown',
        skinColor: (skinTone['rgb_values'] as List?)
                ?.map((e) => (e is num) ? e.toInt() : 128)
                .toList() ??
            [128, 128, 128],
        rawData: json,
      );
    } catch (e, stack) {
      debugPrint('Error parsing result: $e\nStack: $stack');
      return FaceAnalysisResult(
        estimatedAge: 0.0,
        ageConfidence: 0.0,
        gender: {'unknown': 1.0},
        race: {'unknown': 1.0},
        skinTone: 'Unknown',
        skinColor: [128, 128, 128],
        rawData: json, // Store the raw JSON
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'result': {
          'age': {
            'estimated_age': estimatedAge,
            'confidence': ageConfidence,
          },
          'gender': gender,
          'race': race,
          'skin_tone': {
            'name': skinTone,
            'rgb_values': skinColor,
          },
        },
      };
}
