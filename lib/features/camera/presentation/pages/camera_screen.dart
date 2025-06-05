import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:http/http.dart' as http; // Add this
import 'dart:convert';
import '../widgets/camera_controls.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/model_selection_dialog.dart';
import '../../domain/services/camera_controller.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/services/dermatology_service.dart';
import 'image_preview_screen.dart';
import 'dermatology_result_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../results/data/repositories/measurement_repository.dart';
import '../../../camera/domain/models/measurement.dart';
import '../../../face_analysis/presentation/pages/face_analysis_result_screen.dart';
import '../../../face_analysis/domain/services/face_analysis_service.dart';
import '../pages/depth_estimation_result_screen.dart'; // Add this back

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // Update timestamp
  static final DateTime currentDateTime = DateTime.parse('2025-03-04 06:33:03');
  static const String currentUser = 'surajgore-007';
  static const String serverIp = '172.20.10.3'; // Updated IP
  static const int serverPort = 8000;

  final CustomCameraController _cameraController = CustomCameraController();
  final AIService _aiService = AIService(
    config: AIServiceConfig(
      baseUrl: 'http://$serverIp:$serverPort/',
      timeout: const Duration(seconds: 30),
    ),
  );
  final MeasurementRepository _measurementRepository = MeasurementRepository();
  final FaceAnalysisService _faceAnalysisService = FaceAnalysisService();
  bool _isPermissionGranted = false;
  bool _isServerConnected = false;
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _errorMessage;
  double _processingProgress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Initialize measurement repository first
      await _measurementRepository.initialize();
      await _requestCameraPermission();
      await _checkServerConnection();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _checkServerConnection() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = 'Checking server connection...';
      });

      // Step 1: Network check
      try {
        final result = await InternetAddress.lookup(serverIp);
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw AIServiceException(
            'Cannot reach server IP: $serverIp\n'
            'Please check network connection',
            code: 'NETWORK_ERROR',
          );
        }
      } catch (e) {
        throw AIServiceException(
          'Network error: Cannot reach $serverIp\n'
          'Please check WiFi connection',
          code: 'NETWORK_ERROR',
          originalError: e,
        );
      }

      // Step 2: Port check
      try {
        final socket = await Socket.connect(
          serverIp,
          serverPort,
          timeout: const Duration(seconds: 5),
        );
        await socket.close();
      } catch (e) {
        throw AIServiceException(
          'Cannot connect to server port $serverPort\n'
          'Please verify:\n'
          '1. Server is running\n'
          '2. Correct port number\n'
          '3. No firewall blocking',
          code: 'PORT_ERROR',
          originalError: e,
        );
      }

      // Step 3: Server health check
      final isConnected = await _aiService.checkServer();

      setState(() {
        _isServerConnected = isConnected;
        _errorMessage = _isServerConnected ? null : 'Server not responding';
      });
    } catch (e) {
      setState(() {
        _isServerConnected = false;
        if (e is AIServiceException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = 'Connection failed: ${e.toString()}';
        }
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      setState(() {
        _isPermissionGranted = status.isGranted;
      });
      if (_isPermissionGranted) {
        await _cameraController.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      _showError('Failed to initialize camera');
    }
  }

  Future<void> _captureImage() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      if (!_isServerConnected) {
        _showError('AI Server not connected. Please try again.');
        return;
      }

      final image = await _cameraController.takePicture();
      if (image == null || !mounted) return;

      // Save image to measurements directory
      final appDir = await getApplicationDocumentsDirectory();
      final measurementsDir = Directory('${appDir.path}/measurements');
      if (!await measurementsDir.exists()) {
        await measurementsDir.create(recursive: true);
      }

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${measurementsDir.path}/IMG_$timestamp.jpg';
      await File(image.path).copy(newPath);

      // Show model selection dialog
      if (!mounted) return;
      final modelType = await showDialog<ModelType>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ModelSelectionDialog(),
      );

      if (modelType == null) return;

      switch (modelType) {
        case ModelType.measurement:
          // First try camera stream
          try {
            final streamResult = await _aiService.processCameraStream(newPath);
            if (streamResult['status'] == 'success' &&
                streamResult['detections'] != null) {
              final detections = streamResult['detections'] as List;
              if (detections.isNotEmpty) {
                final measurement = Measurement(
                  width: (detections.first['bbox']['x2'] -
                              detections.first['bbox']['x1'])
                          .abs() *
                      AIMeasurementResult.PIXEL_TO_CM,
                  height: (detections.first['bbox']['y2'] -
                              detections.first['bbox']['y1'])
                          .abs() *
                      AIMeasurementResult.PIXEL_TO_CM,
                  depth: ((detections.first['bbox']['x2'] -
                                  detections.first['bbox']['x1'])
                              .abs() *
                          (detections.first['bbox']['y2'] -
                                  detections.first['bbox']['y1'])
                              .abs() *
                          AIMeasurementResult.PIXEL_TO_CM *
                          0.3)
                      .roundToDouble(),
                  objectType: detections.first['class'] ?? '',
                  confidence: detections.first['confidence']?.toDouble() ?? 0.0,
                  timestamp: DateTime.now(),
                );
                await _saveMeasurement(measurement, newPath);

                if (!mounted) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      imagePath: newPath,
                      measurement: measurement,
                    ),
                  ),
                );

                // Refresh if measurement was successful
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Measurement saved successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context, true);
                }
                return;
              }
            }
          } catch (e) {
            // Fallback to regular processing if stream fails
            final results = await _aiService.processMeasurement(newPath);
            final measurement = Measurement(
              width: results.first.width,
              height: results.first.height,
              depth: results.first.depth,
              objectType: results.first.className,
              confidence: results.first.confidence,
              timestamp: DateTime.now(),
            );
            await _saveMeasurement(measurement, newPath);

            if (!mounted) return;
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePreviewScreen(
                  imagePath: newPath,
                  measurement: measurement,
                ),
              ),
            );

            // Refresh if measurement was successful
            if (result == true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Measurement saved successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            }
          }
          break;

        case ModelType.dermatology:
          // Process with dermatology model
          final dermatologyService = DermatologyService();
          final results = await dermatologyService.analyzeSkin(
            newPath,
            onProgress: (progress) {
              // You can add a progress indicator here if needed
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DermatologyResultScreen(
                imagePath: newPath,
                analysisResult: results,
              ),
            ),
          );
          Navigator.pop(context, true);
          break;

        case ModelType.faceAnalysis:
          final result = await _faceAnalysisService.analyzeFace(
            newPath,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _processingProgress = progress);
              }
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceAnalysisResultScreen(
                imagePath: newPath,
                analysisResult:
                    result, // result is now already FaceAnalysisResult
              ),
            ),
          );
          Navigator.pop(context, true);
          break;

        case ModelType.depthEstimation:
          final result = await _aiService.processDepthEstimation(
            newPath,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _processingProgress = progress);
              }
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepthEstimationResultScreen(
                imagePath: newPath,
                analysisResult: result,
              ),
            ),
          );
          Navigator.pop(context, true);
          break;
      }
    } catch (e) {
      _showError('Failed to capture image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveMeasurement(
      Measurement measurement, String imagePath) async {
    try {
      await _measurementRepository.initialize();

      // Save measurement and get the ID
      final measurementId =
          await _measurementRepository.saveMeasurementWithImage(
        measurement,
        imagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurement saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving measurement: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _viewReport(String pdfPath) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening report: ${pdfPath.split('/').last}'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: AppTheme.white,
          onPressed: _initialize,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController.controller == null) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Camera Permission Required',
                style: AppTheme.headlineLarge.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please grant camera permission to use the measurement feature.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Grant Permission',
                onPressed: _requestCameraPermission,
                icon: Icons.settings,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = 'Running diagnostics...';
    });

    try {
      // Test network connectivity
      String diagnosticResult = 'Diagnostic Results:\n';

      try {
        final result = await InternetAddress.lookup(serverIp);
        diagnosticResult += '✅ Network: Connected (${result.first.address})\n';
      } catch (e) {
        diagnosticResult += '❌ Network: Failed - ${e.toString()}\n';
      }

      // Test port connectivity
      try {
        final socket = await Socket.connect(serverIp, serverPort,
            timeout: const Duration(seconds: 3));
        socket.destroy();
        diagnosticResult += '✅ Port $serverPort: Open\n';
      } catch (e) {
        diagnosticResult += '❌ Port $serverPort: Closed - ${e.toString()}\n';
      }

      // Test HTTP connection
      try {
        final response = await http.get(
          Uri.parse('http://$serverIp:$serverPort/health'),
          headers: {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final isHealthy = data['status'] == 'healthy';
          diagnosticResult +=
              '✅ Server Health: ${isHealthy ? "Healthy" : "Unhealthy"}\n';
          diagnosticResult += '📋 Server Response: ${response.body}\n';
        } else {
          diagnosticResult += '❌ Server Health: Error ${response.statusCode}\n';
        }
      } catch (e) {
        diagnosticResult += '❌ Server Health: Failed - ${e.toString()}\n';
      }

      setState(() {
        _errorMessage = diagnosticResult;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Diagnostic failed: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Initializing Camera...',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textDark,
              ),
            ),
            // Update in _buildLoading method
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      text: 'Run Diagnostics',
                      onPressed: _runDiagnostics,
                      icon: Icons.bug_report,
                      isPrimary: true,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Retry Connection',
                      onPressed: _initialize,
                      icon: Icons.refresh,
                      isPrimary: false,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _processImage(String imagePath, ModelType modelType) async {
    try {
      setState(() => _isProcessing = true);

      switch (modelType) {
        case ModelType.measurement:
          // First try camera stream
          try {
            final streamResult =
                await _aiService.processCameraStream(imagePath);
            if (streamResult['status'] == 'success' &&
                streamResult['detections'] != null) {
              final detections = streamResult['detections'] as List;
              if (detections.isNotEmpty) {
                final measurement = Measurement(
                  width: (detections.first['bbox']['x2'] -
                              detections.first['bbox']['x1'])
                          .abs() *
                      AIMeasurementResult.PIXEL_TO_CM,
                  height: (detections.first['bbox']['y2'] -
                              detections.first['bbox']['y1'])
                          .abs() *
                      AIMeasurementResult.PIXEL_TO_CM,
                  depth: ((detections.first['bbox']['x2'] -
                                  detections.first['bbox']['x1'])
                              .abs() *
                          (detections.first['bbox']['y2'] -
                                  detections.first['bbox']['y1'])
                              .abs() *
                          AIMeasurementResult.PIXEL_TO_CM *
                          0.3)
                      .roundToDouble(),
                  objectType: detections.first['class'] ?? '',
                  confidence: detections.first['confidence']?.toDouble() ?? 0.0,
                  timestamp: DateTime.now(),
                );
                await _saveMeasurement(measurement, imagePath);

                if (!mounted) return;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreviewScreen(
                      imagePath: imagePath,
                      measurement: measurement,
                    ),
                  ),
                );

                // Refresh if measurement was successful
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Measurement saved successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context, true);
                }
                return;
              }
            }
          } catch (e) {
            // Fallback to regular processing if stream fails
            final results = await _aiService.processMeasurement(imagePath);
            final measurement = Measurement(
              width: results.first.width,
              height: results.first.height,
              depth: results.first.depth,
              objectType: results.first.className,
              confidence: results.first.confidence,
              timestamp: DateTime.now(),
            );
            await _saveMeasurement(measurement, imagePath);

            if (!mounted) return;
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImagePreviewScreen(
                  imagePath: imagePath,
                  measurement: measurement,
                ),
              ),
            );

            // Refresh if measurement was successful
            if (result == true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Measurement saved successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context, true);
            }
          }
          break;

        case ModelType.dermatology:
          // Process with dermatology model
          final dermatologyService = DermatologyService();
          final results = await dermatologyService.analyzeSkin(
            imagePath,
            onProgress: (progress) {
              // You can add a progress indicator here if needed
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DermatologyResultScreen(
                imagePath: imagePath,
                analysisResult: results,
              ),
            ),
          );
          Navigator.pop(context, true);
          break;

        case ModelType.faceAnalysis:
          final result = await _faceAnalysisService.analyzeFace(
            imagePath,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _processingProgress = progress);
              }
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceAnalysisResultScreen(
                imagePath: imagePath,
                analysisResult:
                    result, // result is now already FaceAnalysisResult
              ),
            ),
          );
          Navigator.pop(context, true);
          break;

        case ModelType.depthEstimation: // Add back depth estimation case
          final result = await _aiService.processDepthEstimation(
            imagePath,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _processingProgress = progress);
              }
            },
          );

          if (!mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepthEstimationResultScreen(
                imagePath: imagePath,
                analysisResult: result,
              ),
            ),
          );
          Navigator.pop(context, true);
          break;
      }
    } catch (e) {
      _showError('Failed to process image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoading();
    }

    if (!_isPermissionGranted) {
      return _buildPermissionDenied();
    }

    if (!_cameraController.isInitialized) {
      return _buildLoading();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_cameraController.controller?.value.isInitialized ?? false)
              CameraPreview(_cameraController.controller!),
            const CameraOverlay(),
            if (!_isServerConnected)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI Server Disconnected',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: _runDiagnostics,
                            icon: const Icon(Icons.bug_report,
                                color: AppTheme.white),
                            label: Text(
                              'Diagnose',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _checkServerConnection,
                            icon: const Icon(Icons.refresh,
                                color: AppTheme.white),
                            label: Text(
                              'Retry',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accent,
                  ),
                ),
              ),
            if (_cameraController.cameras.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: AppTheme.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      await _cameraController.switchCamera();
                      setState(() {});
                    },
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CameraControls(
                // Provide a non-null callback that checks _isProcessing internally
                onCapture: () {
                  if (!_isProcessing) {
                    _captureImage().catchError((error) {
                      _showError('Failed to capture image: $error');
                    });
                  }
                },
                onClose: () => Navigator.pop(context),
                onFlashToggle: () {
                  _cameraController.toggleFlash().then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  }).catchError((error) {
                    _showError('Failed to toggle flash: $error');
                  });
                },
                isFlashOn: _cameraController.isFlashOn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Constants for reference
/*
Current Configuration:
----------------------
DateTime: 2025-03-04 06:35:10
User: surajgore-007
Server: 10.0.10.98:8000
Camera Stream Endpoint: /camera_stream
Process Image Endpoint: /process_image
Health Check Endpoint: /health
Model Info Endpoint: /model_info
Skin Analysis Endpoint: /analyze_skin
*/
