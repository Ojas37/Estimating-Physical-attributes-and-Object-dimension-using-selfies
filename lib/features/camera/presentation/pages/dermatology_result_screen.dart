import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import '../../../results/data/repositories/dermatology_repository.dart';

class DermatologyResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> analysisResult;

  static final DateTime currentDateTime = DateTime.parse('2025-03-05 04:48:13');
  static const String currentUser = 'surajgore-007';

  const DermatologyResultScreen({
    Key? key,
    required this.imagePath,
    required this.analysisResult,
  }) : super(key: key);

  @override
  State<DermatologyResultScreen> createState() =>
      _DermatologyResultScreenState();
}

class _DermatologyResultScreenState extends State<DermatologyResultScreen> {
  Future<void> _shareResults() async {
    try {
      final predictions = widget.analysisResult['predictions'] as List<dynamic>;
      final topPrediction = predictions.first;

      final text = '''
Dermatology Analysis Results:
Date: ${DermatologyResultScreen.currentDateTime}
Patient ID: ${DermatologyResultScreen.currentUser}

Primary Diagnosis: ${topPrediction['class']}
Confidence: ${(topPrediction['probability'] * 100).toStringAsFixed(2)}%
Confidence Level: ${topPrediction['confidence_level']}

Additional Findings:
${predictions.skip(1).map((p) => '- ${p['class']}: ${(p['probability'] * 100).toStringAsFixed(2)}%').join('\n')}
''';

      await Share.shareFiles(
        [widget.imagePath],
        text: text,
        subject: 'Dermatology Analysis Results',
      );
    } catch (e) {
      debugPrint('Error sharing results: $e');
    }
  }

  Future<void> _saveResult() async {
    try {
      final repository = DermatologyRepository();
      await repository.saveDermatologyReport(
          widget.analysisResult, widget.imagePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving analysis: $e')),
        );
      }
    }
  }

  String _getConfidenceLevel(double probability) {
    if (probability >= 0.9) return 'Very High';
    if (probability >= 0.7) return 'High';
    if (probability >= 0.5) return 'Moderate';
    return 'Low';
  }

  Color _getConfidenceColor(double probability) {
    if (probability >= 0.9) return Colors.green;
    if (probability >= 0.7) return Colors.lightGreen;
    if (probability >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final predictions = widget.analysisResult['predictions'] as List<dynamic>;
      if (predictions.isEmpty) {
        throw Exception('No predictions available');
      }

      final topPrediction = predictions.first;
      final probability = (topPrediction['probability'] as num).toDouble();
      final confidenceLevel = _getConfidenceLevel(probability);
      final confidenceColor = _getConfidenceColor(probability);
      final className = topPrediction['class'] as String;

      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            'Analysis Results',
            style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveResult,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResults,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildResultsSection(
                  className, confidenceLevel, confidenceColor, probability),
              const SizedBox(height: 24),
              _buildAnalysisSection(predictions),
              const SizedBox(height: 24),
              _buildRecommendationsSection(className),
            ],
          ),
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Error',
            style: AppTheme.headlineMedium.copyWith(color: AppTheme.accent),
          ),
        ),
        body: Center(
          child: Text(
            'Failed to load analysis results: ${e.toString()}',
            style: AppTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildResultsSection(String className, String confidenceLevel,
      Color confidenceColor, double probability) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnosis',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.accent),
          ),
          const SizedBox(height: 12),
          Text(
            className,
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Confidence: ${(probability * 100).toStringAsFixed(1)}%',
                  style: AppTheme.labelMedium.copyWith(color: confidenceColor),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confidenceLevel,
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(List<dynamic> predictions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.accent),
          ),
          const SizedBox(height: 12),
          ...predictions
              .skip(1)
              .map((prediction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prediction['class'] as String,
                          style: AppTheme.bodyLarge,
                        ),
                        Text(
                          '${((prediction['probability'] as num).toDouble() * 100).toStringAsFixed(1)}%',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.accent),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(String diagnosis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.accent),
          ),
          const SizedBox(height: 12),
          Text(
            'Please consult a healthcare professional for a thorough evaluation of your $diagnosis condition. This analysis is for reference only and should not be used as a definitive diagnosis.',
            style: AppTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
