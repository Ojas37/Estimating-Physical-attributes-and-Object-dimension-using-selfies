import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../models/face_analysis_result.dart';
import '../../../../core/config/app_config.dart';

class FaceAnalysisService {
  final String baseUrl;
  final Duration timeout;

  FaceAnalysisService({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? AppConfig.baseUrl,
        timeout = timeout ?? AppConfig.defaultTimeout;

  void _log(String message) {
    debugPrint('FaceAnalysisService: $message');
  }

  Future<FaceAnalysisResult> analyzeFace(String imagePath) async {
    try {
      _log('Starting analysis: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        _log('File not found');
        return _getDefaultResult();
      }

      final uri = Uri.parse('$baseUrl/analyze_face');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      _log('Sending request to $uri');
      final response = await request.send().timeout(timeout);
      final responseStr = await response.stream.bytesToString();

      _log('Response status: ${response.statusCode}');
      _log('Response body: $responseStr');

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseStr) as Map<String, dynamic>;
        if (jsonData.isEmpty) {
          _log('Empty response received');
          return _getDefaultResult();
        }
        return FaceAnalysisResult.fromJson(jsonData);
      }

      _log('Request failed with status: ${response.statusCode}');
      return _getDefaultResult();
    } catch (e, stack) {
      _log('Error: $e\nStack: $stack');
      return _getDefaultResult();
    }
  }

  FaceAnalysisResult _getDefaultResult() {
    return FaceAnalysisResult(
      estimatedAge: 0.0,
      ageConfidence: 0.0,
      gender: {'unknown': 1.0},
      race: {'unknown': 1.0},
      skinTone: 'Unknown',
      skinColor: [128, 128, 128],
    );
  }
}
