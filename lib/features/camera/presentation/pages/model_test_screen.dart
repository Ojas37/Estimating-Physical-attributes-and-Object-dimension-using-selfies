// lib/features/camera/presentation/pages/model_test_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/services/ai_service.dart';
import '../../../../core/theme/app_theme.dart';

class ModelTestScreen extends StatefulWidget {
  const ModelTestScreen({Key? key}) : super(key: key);

  @override
  _ModelTestScreenState createState() => _ModelTestScreenState();
}

class _ModelTestScreenState extends State<ModelTestScreen> {
  final AIService _aiService = AIService();
  final String _currentDateTime = '2025-02-06 12:05:42';
  final String _username = 'surajgore-007';
  bool _isTesting = false;
  String _status = 'Not tested';
  List<String> _logs = [];
  bool _isServerConnected = false;
  bool _isModelLoaded = false;
  bool _canProcessImages = false;

  @override
  void initState() {
    super.initState();
    _initialCheck();
  }

  Future<void> _initialCheck() async {
    _addLog('Starting initial system check...');
    _addLog('Current user: $_username');
    _addLog('System time: $_currentDateTime');
    await _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing System...';
      _logs = [];
      _addLog('Initiating comprehensive model diagnostics...');
    });

    try {
      // 1. Server Connection Test
      _addLog('Testing server connection...');
      final isServerUp = await _aiService.checkServer();
      _isServerConnected = isServerUp;
      _addLog(isServerUp
          ? '✓ Server connection established successfully'
          : '✗ Failed to connect to server');

      if (!isServerUp) {
        throw Exception('Server connection failed');
      }

      // 2. Model Loading Test
      _addLog('Verifying model status...');
      final modelInfo = await _aiService.getModelInfo();
      _isModelLoaded = modelInfo['error'] == null;
      _addLog(_isModelLoaded
          ? '✓ AI model loaded successfully'
          : '✗ Model initialization failed');

      // 3. Model Functionality Test
      _addLog('Validating model functionality...');
      final isModelWorking = await _aiService.testModel();
      _canProcessImages = isModelWorking;
      _addLog(isModelWorking
          ? '✓ Model operational check passed'
          : '✗ Model functionality test failed');

      // 4. Image Processing Test
      _addLog('Testing image processing capability...');
      await _testImageProcessing();

      setState(() {
        _status = _isModelLoaded && _canProcessImages
            ? 'System Fully Operational'
            : 'System Check Failed';
      });
    } catch (e) {
      _addLog('✗ Critical Error: ${e.toString()}');
      setState(() {
        _status = 'Diagnostic Test Failed';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testImageProcessing() async {
    try {
      final directory = await getTemporaryDirectory();
      final testImagePath = '${directory.path}/test_image.jpg';

      _addLog('Preparing test image...');
      await _createTestImage(testImagePath);

      _addLog('Testing image processing pipeline...');
      final result = await _aiService.processMeasurement(
        testImagePath,
        onProgress: (progress) {
          _addLog(
              'Processing progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      _addLog('✓ Image processing test completed successfully');
      _addLog('Objects detected: ${result.length}');
    } catch (e) {
      _addLog('✗ Image processing test failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _createTestImage(String path) async {
    try {
      if (!File(path).existsSync()) {
        _addLog('Generating test image...');
        // Add test image creation logic here
      }
    } catch (e) {
      _addLog('✗ Test image generation failed: $e');
      rethrow;
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('$_currentDateTime - $message');
    });
  }

  Color _getStatusColor() {
    if (_status.contains('Operational')) return Colors.green;
    if (_status.contains('Testing')) return AppTheme.accent;
    if (_status.contains('Failed')) return Colors.red;
    return AppTheme.textMedium;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'AI Model Diagnostics',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.white,
          ),
        ),
        backgroundColor: AppTheme.accent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isTesting ? null : _testConnection,
            color: AppTheme.white,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildSystemStatus(),
            const SizedBox(height: 16),
            _buildLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'System Status',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            _status,
            style: AppTheme.titleLarge.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_circle_outline),
              label: Text(
                _isTesting ? 'Running Tests...' : 'Run Diagnostics',
                style: AppTheme.buttonText,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Component Status',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildStatusItem('Server Connection', _isServerConnected),
          _buildStatusItem('Model Loaded', _isModelLoaded),
          _buildStatusItem('Image Processing', _canProcessImages),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status ? Icons.check_circle : Icons.error,
              color: status ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogs() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.terminal,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Diagnostic Logs',
                    style: AppTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Text(
                      log,
                      style: AppTheme.bodyMedium.copyWith(
                        color: log.contains('✓')
                            ? Colors.green
                            : log.contains('✗')
                                ? Colors.red
                                : AppTheme.textDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
