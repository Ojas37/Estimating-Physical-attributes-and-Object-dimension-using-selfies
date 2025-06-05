import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../export/domain/services/depth_pdf_service.dart';
import '../../../results/data/repositories/depth_repository.dart';

class DepthEstimationResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;
  final DepthPDFService _pdfService = DepthPDFService();
  final _depthRepository = DepthRepository();

  DepthEstimationResultScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final pdfFile =
          await _pdfService.generateAndSavePDF(imagePath, analysisResult);
      await _pdfService.sharePDF(pdfFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    }
  }

  Future<void> _saveReport(BuildContext context) async {
    try {
      final reportId = await _depthRepository.saveDepthReport(
        imagePath,
        analysisResult,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final String? analysisImage =
          analysisResult['visualizations']?['depth_inferno']?.toString();

      if (analysisImage == null) {
        throw Exception('No depth visualization found in response');
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Depth Analysis',
            style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveReport(context),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _exportToPDF(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main depth visualization
              Container(
                width: double.infinity,
                height:
                    MediaQuery.of(context).size.height * 0.4, // Reduced height
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: AppTheme.softShadow,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(analysisImage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Statistics Card
              if (analysisResult['statistics'] != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistics', style: AppTheme.titleMedium),
                          const SizedBox(height: 8),
                          ..._buildStatistics(),
                        ],
                      ),
                    ),
                  ),
                ),

              // Visualizations Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Different Views', style: AppTheme.headlineSmall),
                    const SizedBox(height: 16),
                    _buildVisualizationsGrid(),
                    const SizedBox(height: 24),
                    Text('Detailed Analysis', style: AppTheme.headlineSmall),
                    const SizedBox(height: 16),
                    _buildDetailedAnalysisSection(
                        analysisResult['visualizations']
                            as Map<String, dynamic>),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error in DepthEstimationResultScreen: $e');
      debugPrint('Stack trace: $stack');
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Failed to load depth analysis: $e'),
        ),
      );
    }
  }

  List<Widget> _buildStatistics() {
    final stats = analysisResult['statistics'] as Map<String, dynamic>? ?? {};
    return stats.entries.map((entry) {
      try {
        final value = entry.value is num ? entry.value.toDouble() : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key.split('_').map((e) => e.capitalize()).join(' '),
                style: AppTheme.bodyMedium,
              ),
              Text(
                value.toStringAsFixed(2),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error building statistic for ${entry.key}: $e');
        return const SizedBox.shrink();
      }
    }).toList();
  }

  Widget _buildVisualizationsGrid() {
    final visualizations =
        analysisResult['visualizations'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVisualizationSection(
            'Depth Maps',
            ['depth_inferno', 'depth_turbo', 'depth_magma', 'depth_plasma'],
            visualizations),
        const SizedBox(height: 16),
        _buildVisualizationSection(
            'Blended Views',
            [
              'blended_depth_inferno',
              'blended_depth_turbo',
              'blended_depth_magma',
              'blended_depth_plasma'
            ],
            visualizations),
        const SizedBox(height: 16),
        _buildAnalysisSection(visualizations),
      ],
    );
  }

  Widget _buildVisualizationSection(
      String title, List<String> keys, Map<String, dynamic> visualizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: AppTheme.headlineSmall),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(8),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: keys
              .map((key) => _buildVisualizationCard(
                    title: key.split('_').map((e) => e.capitalize()).join(' '),
                    base64Image: visualizations[key]?.toString() ?? '',
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(Map<String, dynamic> visualizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Detailed Analysis', style: AppTheme.headlineSmall),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              if (visualizations['3d_plot'] != null) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('3D Depth Map', style: AppTheme.titleMedium),
                ),
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(visualizations['3d_plot']!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading 3D plot: $error');
                      return const Center(
                        child: Text('Error loading 3D visualization'),
                      );
                    },
                  ),
                ),
              ],
              if (visualizations['histogram'] != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text('Depth Distribution', style: AppTheme.titleMedium),
                ),
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(visualizations['histogram']!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading histogram: $error');
                      return const Center(
                        child: Text('Error loading histogram'),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnalysisSection(Map<String, dynamic> visualizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visualizations['3d_plot'] != null) ...[
              Text('3D Depth Visualization', style: AppTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(visualizations['3d_plot']!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (visualizations['histogram'] != null) ...[
              Text('Depth Distribution', style: AppTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    base64Decode(visualizations['histogram']!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationCard(
      {required String title, required String base64Image}) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.memory(
              base64Decode(base64Image),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return const Center(
                  child: Text('Error loading image'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : this;
  }
}
