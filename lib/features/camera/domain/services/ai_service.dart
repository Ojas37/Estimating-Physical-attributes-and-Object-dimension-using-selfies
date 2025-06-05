import 'dart:io';
import 'dart:math' show pow;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/config/app_config.dart';

class AIMeasurementResult {
  final double width;
  final double height;
  final double depth;
  final int classId;
  final String className;
  final double confidence;
  final Map<String, dynamic>? rawData;
  final Map<String, dynamic>? bbox;

  // Constants for measurement calculations
  static const double DPI = 96.0; // Standard screen DPI
  static const double INCH_TO_CM = 2.54; // 1 inch = 2.54 centimeters
  static const double PIXEL_TO_CM = INCH_TO_CM / DPI; // Conversion factor
  static final DateTime currentDateTime = DateTime.parse('2025-03-06 17:46:39');
  static const String currentUser = 'surajgore-007';

  AIMeasurementResult({
    required this.width,
    required this.height,
    required this.depth,
    required this.classId,
    this.className = '',
    this.confidence = 0.0,
    this.rawData,
    this.bbox,
  });

  factory AIMeasurementResult.fromJson(Map<String, dynamic> json) {
    final bbox = json['bbox'] as Map<String, dynamic>?;
    double width = 0.0;
    double height = 0.0;
    double depth = 0.0;

    if (bbox != null) {
      try {
        // Get raw pixel values and ensure they're valid doubles
        final x1 = (bbox['x1'] as num?)?.toDouble() ?? 0.0;
        final x2 = (bbox['x2'] as num?)?.toDouble() ?? 0.0;
        final y1 = (bbox['y1'] as num?)?.toDouble() ?? 0.0;
        final y2 = (bbox['y2'] as num?)?.toDouble() ?? 0.0;

        // Calculate pixel dimensions with absolute values
        final pixelWidth = (x2 - x1).abs();
        final pixelHeight = (y2 - y1).abs();

        // Convert to centimeters with enhanced safety checks
        if (pixelWidth > 0 && pixelHeight > 0) {
          width = (pixelWidth * PIXEL_TO_CM).roundToDouble();
          height = (pixelHeight * PIXEL_TO_CM).roundToDouble();
          depth = ((width + height) / 2 * 0.3).roundToDouble();

          debugPrint('Raw bbox values: x1=$x1, x2=$x2, y1=$y1, y2=$y2');
          debugPrint(
              'Pixel dimensions: width=$pixelWidth, height=$pixelHeight');
          debugPrint(
              'Final dimensions (cm): width=$width, height=$height, depth=$depth');
        }
      } catch (e) {
        debugPrint('Error calculating dimensions: $e');
      }
    }

    // Create result with strict type checking
    return AIMeasurementResult(
      width: width,
      height: height,
      depth: depth,
      classId: json['class_id']?.toInt() ?? 0,
      className: json['class']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      rawData: json,
      bbox: bbox,
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'depth': depth,
        'class_id': classId,
        'class': className,
        'confidence': confidence,
        'bbox': bbox,
        'timestamp': currentDateTime.toIso8601String(),
        'user': currentUser,
      };
}

class AIServiceConfig {
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final int imageQuality;
  final int maxWidth;
  final int maxHeight;

  const AIServiceConfig({
    String? baseUrl,
    Duration? timeout,
    this.maxRetries = 3,
    this.imageQuality = 85,
    this.maxWidth = 1024,
    this.maxHeight = 1024,
  })  : baseUrl = baseUrl ?? AppConfig.baseUrl,
        timeout = timeout ?? AppConfig.defaultTimeout;
}

class AIServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AIServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'AIServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

typedef ProgressCallback = void Function(double progress);

class AIService {
  final AIServiceConfig config;
  bool _enableDebug = true;
  static final DateTime currentDateTime = DateTime.parse('2025-03-04 17:43:27');
  static const String currentUser = 'surajgore-007';
  static const String serverIp = '172.20.10.3'; // Updated IP
  static const int serverPort = 8000;

  AIService({AIServiceConfig? config})
      : config = config ?? const AIServiceConfig();

  void _log(String message) {
    if (_enableDebug) {
      debugPrint('AIService: $message');
    }
  }

  // API endpoints
  String get apiUrl => '${config.baseUrl}${AppConfig.processImageEndpoint}';
  String get healthUrl => '${config.baseUrl}${AppConfig.healthEndpoint}';
  String get modelInfoUrl => '${config.baseUrl}${AppConfig.modelInfoEndpoint}';
  String get skinAnalysisUrl =>
      '${config.baseUrl}${AppConfig.analyzeSkinEndpoint}';
  String get cameraStreamUrl =>
      '${config.baseUrl}${AppConfig.cameraStreamEndpoint}';
  String get depthEstimationUrl => '${config.baseUrl}process_depth';

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < config.maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == config.maxRetries) rethrow;

        _log(
            'Attempt $attempts failed, retrying in ${pow(2, attempts)} seconds...');
        await Future.delayed(Duration(seconds: pow(2, attempts).toInt()));
      }
    }
    throw AIServiceException('All retry attempts failed');
  }
  // Continuing AIService class...

  Future<Map<String, dynamic>> processCameraStream(
    String imagePath, {
    ProgressCallback? onProgress,
    bool compress = true,
  }) async {
    return _withRetry(() async {
      try {
        _log('Starting camera stream processing');
        _log('Image path: $imagePath');
        _log('Time: ${currentDateTime.toIso8601String()}');
        onProgress?.call(0.1);

        if (!await File(imagePath).exists()) {
          throw AIServiceException('Image not found', code: 'FILE_ERROR');
        }

        File imageFile = File(imagePath);
        if (compress) {
          imageFile = await _compressImage(imageFile);
        }
        onProgress?.call(0.3);

        final request =
            http.MultipartRequest('POST', Uri.parse(cameraStreamUrl))
              ..headers.addAll({
                'Accept': 'application/json',
                'Connection': 'keep-alive',
                'X-Client-Timestamp': currentDateTime.toIso8601String(),
                'X-Client-User': currentUser,
              })
              ..files.add(await http.MultipartFile.fromPath(
                'image',
                imageFile.path,
                contentType: MediaType('image', 'jpeg'),
              ));

        onProgress?.call(0.5);

        final response = await http.Response.fromStream(
          await request.send().timeout(config.timeout),
        );

        _log('Response status: ${response.statusCode}');
        _log('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          onProgress?.call(1.0);
          return data;
        }

        throw AIServiceException(
          'Server error: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      } catch (e) {
        _log('Camera stream processing failed: $e');
        rethrow;
      }
    });
  }

  Future<List<AIMeasurementResult>> processMeasurement(
    String imagePath, {
    ProgressCallback? onProgress,
    bool compress = true,
  }) async {
    return _withRetry(() async {
      try {
        _log('Starting measurement processing');
        _log('Image path: $imagePath');
        _log('Time: ${currentDateTime.toIso8601String()}');
        onProgress?.call(0.1);

        if (!await File(imagePath).exists()) {
          throw AIServiceException('Image not found', code: 'FILE_ERROR');
        }

        File imageFile = File(imagePath);
        if (compress) {
          imageFile = await _compressImage(imageFile);
          _log('Image compressed: ${imageFile.path}');
        }
        onProgress?.call(0.3);

        final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..headers.addAll({
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            'X-Client-Timestamp': currentDateTime.toIso8601String(),
            'X-Client-User': currentUser,
          })
          ..files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ));

        onProgress?.call(0.5);

        final response = await http.Response.fromStream(
          await request.send().timeout(config.timeout),
        );

        _log('Response status: ${response.statusCode}');
        _log('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _log('Response data: $data'); // Debug log

          if (data['detections'] != null) {
            onProgress?.call(0.8);
            final detections = data['detections'] as List;
            _log('Detections found: ${detections.length}'); // Debug log

            final results = detections.map((d) {
              final result = AIMeasurementResult.fromJson(d);
              _log(
                  'Processed detection: w=${result.width}, h=${result.height}, d=${result.depth}');
              return result;
            }).toList();

            onProgress?.call(1.0);
            return results;
          }
        }

        throw AIServiceException(
          'Invalid response format',
          code: 'RESPONSE_ERROR',
        );
      } catch (e) {
        _log('Measurement processing failed: $e');
        rethrow;
      }
    });
  }

  Future<bool> checkServer() async {
    try {
      _log('Starting server health check...');
      _log('Server: http://$serverIp:$serverPort');
      _log('Time: ${currentDateTime.toIso8601String()}');

      // Step 1: Network connectivity with timeout
      try {
        _log('Testing network connectivity...');
        final lookup = await InternetAddress.lookup(serverIp)
            .timeout(const Duration(seconds: 5));
        if (lookup.isEmpty) {
          throw AIServiceException('Cannot resolve server IP',
              code: 'DNS_ERROR');
        }
        _log('Network connected: ${lookup.first.address}');
      } catch (e) {
        _log('Network error: $e');
        throw AIServiceException(
          'Network error: Cannot reach server\nCheck WiFi connection',
          code: 'NETWORK_ERROR',
        );
      }

      // Step 2: Port check with timeout
      try {
        _log('Testing port connectivity...');
        final socket = await Socket.connect(
          serverIp,
          serverPort,
          timeout: const Duration(seconds: 5),
        );
        await socket.close();
        _log('Port $serverPort is open');
      } catch (e) {
        _log('Port error: $e');
        throw AIServiceException(
          'Cannot connect to server\nVerify server is running',
          code: 'PORT_ERROR',
        );
      }

      // Step 3: HTTP health check
      final response = await http.get(
        Uri.parse('http://$serverIp:$serverPort/health'),
        headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
      ).timeout(const Duration(seconds: 5));

      _log('Health check status: ${response.statusCode}');
      _log('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      _log('Server check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      _log('Getting model info...');
      _log('URL: $modelInfoUrl');
      _log('Time: ${currentDateTime.toIso8601String()}');

      final response = await http.get(
        Uri.parse(modelInfoUrl),
        headers: {
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          'X-Client-Timestamp': currentDateTime.toIso8601String(),
          'X-Client-User': currentUser,
        },
      ).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log('Model info received: $data');
        return data;
      }

      throw AIServiceException(
        'Failed to get model info: ${response.statusCode}',
        code: 'SERVER_ERROR',
      );
    } catch (e) {
      _log('Get model info failed: $e');
      return {
        'error': e.toString(),
        'timestamp': currentDateTime.toIso8601String(),
      };
    }
  }

  Future<bool> testModel() async {
    try {
      _log('Testing model...');
      _log('Time: ${currentDateTime.toIso8601String()}');

      if (!await checkServer()) {
        _log('Server health check failed');
        return false;
      }

      final modelInfo = await getModelInfo();
      if (modelInfo['error'] != null) {
        _log('Model info error: ${modelInfo['error']}');
        return false;
      }

      final models = modelInfo['models'] as Map<String, dynamic>?;
      if (models == null) {
        _log('No models information available');
        return false;
      }

      bool allModelsLoaded = true;
      models.forEach((key, value) {
        if (!(value['loaded'] ?? false)) {
          allModelsLoaded = false;
          _log('Model $key not loaded');
        }
      });

      _log('Model test ${allModelsLoaded ? 'successful' : 'failed'}');
      return allModelsLoaded;
    } catch (e) {
      _log('Model test failed: $e');
      return false;
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final targetPath = file.path.replaceAll('.jpg', '_compressed.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: config.imageQuality,
        minWidth: config.maxWidth,
        minHeight: config.maxHeight,
      );

      if (result == null) {
        throw AIServiceException('Compression failed');
      }

      return File(result.path);
    } catch (e) {
      _log('Image compression failed: $e');
      return file;
    }
  }

  Future<Map<String, dynamic>> processDepthEstimation(
    String imagePath, {
    ProgressCallback? onProgress,
  }) async {
    return _withRetry(() async {
      try {
        _log('Starting depth estimation processing');
        final endpoint = '${config.baseUrl}process_depth';
        _log('Using endpoint: $endpoint');

        // Validate file
        final file = File(imagePath);
        if (!await file.exists()) {
          throw AIServiceException('Image file not found', code: 'FILE_ERROR');
        }

        onProgress?.call(0.3);

        // Create multipart request
        final request = http.MultipartRequest('POST', Uri.parse(endpoint))
          ..headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
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

        onProgress?.call(0.4);

        // Send request with timeout
        final streamedResponse = await request.send().timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw AIServiceException(
                'Request timed out',
                code: 'TIMEOUT_ERROR',
              ),
            );

        final response = await http.Response.fromStream(streamedResponse);
        _log('Response status: ${response.statusCode}');
        _log('Response body: ${response.body}\n');

        if (response.statusCode != 200) {
          Map<String, dynamic> errorData = {};
          try {
            errorData = json.decode(response.body);
          } catch (e) {
            _log('Failed to parse error response: $e');
          }

          throw AIServiceException(
            'Server error: ${response.statusCode}\n${errorData['error'] ?? response.body}',
            code: 'SERVER_ERROR',
          );
        }

        final data = json.decode(response.body);
        if (data['status'] != 'success' ||
            !data.containsKey('visualizations')) {
          _log('Invalid response format: $data');
          throw AIServiceException(
            'Invalid response format',
            code: 'RESPONSE_ERROR',
          );
        }

        // Log available visualizations
        final visualizations = data['visualizations'] as Map<String, dynamic>;
        _log('Available visualizations: ${visualizations.keys.join(", ")}');

        if (!visualizations.containsKey('depth_inferno')) {
          _log('Missing required depth visualizations');
          throw AIServiceException(
            'Missing depth visualizations',
            code: 'VISUALIZATION_ERROR',
          );
        }

        onProgress?.call(1.0);
        return data;
      } catch (e) {
        _log('Depth estimation failed: $e');
        rethrow;
      }
    });
  }
}

// Constants for reference
/*
Current Configuration:
----------------------
DateTime: 2025-03-04 17:44:18
User: surajgore-007
Server: 192.168.1.101:8000
Endpoints:
- /process_image
- /health
- /model_info
- /analyze_skin
- /camera_stream
*/
