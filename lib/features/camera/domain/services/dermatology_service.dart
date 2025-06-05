import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/app_config.dart';

class DermatologyService {
  static final DateTime currentDateTime = AppConfig.currentDateTime;
  static const String currentUser = AppConfig.currentUser;

  final String baseUrl;
  final Duration timeout;

  DermatologyService({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? AppConfig.baseUrl,
        timeout = timeout ?? AppConfig.defaultTimeout;

  bool _enableDebug = true;

  void _log(String message) {
    if (_enableDebug) {
      debugPrint('DermatologyService: $message');
    }
  }

  Future<Map<String, dynamic>> analyzeSkin(
    String imagePath, {
    Function(double)? onProgress,
  }) async {
    try {
      _log('Starting skin analysis for image: $imagePath');
      onProgress?.call(0.1);

      // Validate image file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      onProgress?.call(0.2);

      // Fix: Add forward slash before endpoint
      final uri = Uri.parse('$baseUrl${AppConfig.analyzeSkinEndpoint}');
      _log('Sending request to: $uri');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      });

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Add metadata
      request.fields['timestamp'] = currentDateTime.toIso8601String();
      request.fields['user'] = currentUser;

      onProgress?.call(0.4);
      _log('Uploading image...');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        timeout,
        onTimeout: () {
          _log('Request timed out');
          throw Exception(
              'Request timed out after ${timeout.inSeconds} seconds');
        },
      );

      onProgress?.call(0.6);
      _log('Response status: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        onProgress?.call(0.8);

        // Validate response data
        if (data['status'] == 'success') {
          _log('Analysis completed successfully');
          onProgress?.call(1.0);

          return {
            ...data,
            'timestamp': currentDateTime.toIso8601String(),
            'user': currentUser,
          };
        } else {
          throw Exception(
              'Invalid response format: ${data['error'] ?? 'Unknown error'}');
        }
      } else {
        _log('Server error: ${response.statusCode}');
        throw Exception(
            'Failed to analyze image: ${response.statusCode}\nResponse: ${response.body}');
      }
    } on SocketException catch (e) {
      _log('Network error: $e');
      throw Exception('Network error: Please check your connection');
    } catch (e) {
      _log('Error: $e');
      throw Exception('Error analyzing skin: $e');
    }
  }

  Future<bool> checkConnection() async {
    try {
      _log('Checking service connection...');
      final response = await http
          .get(
        Uri.parse('${baseUrl}health'),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Connection check timed out');
          throw Exception('Connection timed out');
        },
      );

      final isConnected = response.statusCode == 200;
      _log('Service connection: ${isConnected ? 'connected' : 'disconnected'}');
      return isConnected;
    } catch (e) {
      _log('Connection check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      _log('Getting service information...');
      final response = await http
          .get(
            Uri.parse('${baseUrl}info'),
          )
          .timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _log('Service info received');
        return {
          ...data,
          'timestamp': currentDateTime.toIso8601String(),
          'user': currentUser,
        };
      }
      throw Exception('Failed to get service information');
    } catch (e) {
      _log('Failed to get service info: $e');
      return {
        'error': e.toString(),
        'timestamp': currentDateTime.toIso8601String(),
        'user': currentUser,
      };
    }
  }

  Future<Map<String, dynamic>> getAnalysisHistory() async {
    try {
      _log('Fetching analysis history...');
      final response = await http.get(
        Uri.parse('${baseUrl}history'),
        headers: {
          'Accept': 'application/json',
          'User': currentUser,
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _log('History fetched successfully');
        return {
          ...data,
          'timestamp': currentDateTime.toIso8601String(),
          'user': currentUser,
        };
      }
      throw Exception('Failed to fetch analysis history');
    } catch (e) {
      _log('Failed to fetch history: $e');
      return {
        'error': e.toString(),
        'timestamp': currentDateTime.toIso8601String(),
        'user': currentUser,
      };
    }
  }
}
