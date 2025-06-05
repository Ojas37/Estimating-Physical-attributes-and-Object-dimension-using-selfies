// lib/features/camera/presentation/pages/image_gallery_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/models/measurement.dart';
import '../../domain/services/ai_service.dart';
import 'image_preview_screen.dart';
import 'camera_screen.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  List<FileSystemEntity> _images = [];
  bool _isLoading = true;
  FileSystemEntity? _selectedImage;
  bool _isProcessing = false;
  final String _currentDateTime = '2025-02-06 16:00:04';
  final String _username = 'surajgore-007';
  final AIService _aiService = AIService();
  List<AIMeasurementResult>? _measurementResults;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _selectedImage = null;
    });

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/measurements');

      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final List<FileSystemEntity> files = await imageDir
          .list()
          .where((entity) =>
              entity.path.endsWith('.jpg') ||
              entity.path.endsWith('.jpeg') ||
              entity.path.endsWith('.png'))
          .toList();

      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      setState(() {
        _images = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Failed to load images', isError: true);
    }
  }

  Future<void> _deleteImage(FileSystemEntity image) async {
    try {
      await image.delete();
      await _loadImages();
      _showMessage('Image deleted successfully');
    } catch (e) {
      _showMessage('Failed to delete image', isError: true);
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImage == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final results = await _aiService.processMeasurement(_selectedImage!.path);
      setState(() {
        _measurementResults = results;
        _isProcessing = false;
      });
      _showMeasurementResults(results);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showMessage('Failed to process measurement: ${e.toString()}',
          isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        duration: const Duration(seconds: 3),
        action: isError
            ? SnackBarAction(
                label: 'Retry',
                textColor: AppTheme.white,
                onPressed: _loadImages,
              )
            : null,
      ),
    );
  }

  void _showMeasurementResults(List<AIMeasurementResult> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.architecture,
              color: AppTheme.accent,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Measurement Results',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var result in results)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Object: Class ${result.classId}',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMeasurementRow('Width', result.width),
                      _buildMeasurementRow('Height', result.height),
                      _buildMeasurementRow('Depth', result.depth),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'Close',
              style: AppTheme.buttonText.copyWith(
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textMedium,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} m',
            style: AppTheme.titleSmall.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(FileSystemEntity image) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Image',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.buttonText.copyWith(
                color: AppTheme.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(image);
            },
            child: Text(
              'Delete',
              style: AppTheme.buttonText.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withOpacity(0.1),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Measurements Yet',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the camera button to start measuring',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Take Photo',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
              if (result == true) {
                _loadImages();
              }
            },
            icon: Icons.camera_alt,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Measurements Gallery',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 3,
              ),
            )
          : _images.isEmpty
              ? _buildEmptyState()
              : _buildGalleryGrid(),
      bottomNavigationBar:
          _selectedImage != null ? _buildUploadBar() : const SizedBox.shrink(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ),
          );
          if (result == true) {
            _loadImages();
          }
        },
        backgroundColor: AppTheme.accent,
        child: const Icon(
          Icons.camera_alt,
          color: AppTheme.white,
        ),
      ),
    );
  }

  Widget _buildUploadBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: AppTheme.softShadow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _handleUpload,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.architecture,
                        color: AppTheme.white,
                      ),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Measure Object',
                  style: AppTheme.buttonText,
                ),
                style: AppTheme.primaryButton,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppTheme.textDark,
              ),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _measurementResults = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return RefreshIndicator(
      onRefresh: _loadImages,
      color: AppTheme.accent,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          final isSelected = _selectedImage?.path == image.path;
          return _buildImageCard(image, isSelected);
        },
      ),
    );
  }

  Widget _buildImageCard(FileSystemEntity image, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = isSelected ? null : image;
          _measurementResults = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.white,
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.background,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => _showDeleteDialog(image),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
