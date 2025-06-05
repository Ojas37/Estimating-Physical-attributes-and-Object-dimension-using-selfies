import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum ModelType { measurement, dermatology, faceAnalysis, depthEstimation }

class ModelSelectionDialog extends StatelessWidget {
  const ModelSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Analysis Type',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildModelOption(
              context,
              'Measurement Model',
              'Measure object dimensions',
              Icons.straighten,
              ModelType.measurement,
            ),
            const SizedBox(height: 16),
            _buildModelOption(
              context,
              'Dermatology Model',
              'Analyze skin conditions',
              Icons.healing,
              ModelType.dermatology,
            ),
            const SizedBox(height: 16),
            _buildModelOption(
              context,
              'Face Analysis',
              'Analyze facial features',
              Icons.face,
              ModelType.faceAnalysis,
            ),
            const SizedBox(height: 16),
            _buildModelOption(
              context,
              'Depth Estimation',
              'Analyze depth in images',
              Icons.landscape,
              ModelType.depthEstimation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    ModelType type,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
