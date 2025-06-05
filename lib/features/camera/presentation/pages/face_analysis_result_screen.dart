import 'dart:io';
import 'dart:convert'; // Add this import
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/face_analysis_result.dart';

class FaceAnalysisResultScreen extends StatelessWidget {
  final String imagePath;
  final FaceAnalysisResult analysisResult;

  const FaceAnalysisResultScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Analysis Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildRawDataSection(),
            const SizedBox(height: 16),
            if (analysisResult.rawData['result'] != null) ...[
              _buildResultSection('Age Analysis', _buildAgeContent()),
              const SizedBox(height: 16),
              _buildResultSection('Gender Analysis', _buildGenderContent()),
              const SizedBox(height: 16),
              _buildResultSection('Ethnicity Analysis', _buildRaceContent()),
              const SizedBox(height: 16),
              _buildResultSection(
                  'Skin Tone Analysis', _buildSkinToneContent()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(imagePath),
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildResultSection(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raw Server Response', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                JsonEncoder.withIndent('  ').convert(analysisResult.rawData),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Age: ${analysisResult.estimatedAge.toStringAsFixed(1)} years',
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Confidence: ${analysisResult.ageConfidence.toStringAsFixed(1)}%',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildGenderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...analysisResult.gender.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${_formatLabel(entry.key)}: ${(entry.value * 100).toStringAsFixed(1)}%',
              style: AppTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRaceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...analysisResult.race.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${_formatLabel(entry.key)}: ${(entry.value * 100).toStringAsFixed(1)}%',
              style: AppTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinToneContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Tone: ${analysisResult.skinTone}',
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              analysisResult.skinColor[0],
              analysisResult.skinColor[1],
              analysisResult.skinColor[2],
              1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.softShadow,
          ),
        ),
      ],
    );
  }

  String _formatLabel(String label) {
    return label
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
