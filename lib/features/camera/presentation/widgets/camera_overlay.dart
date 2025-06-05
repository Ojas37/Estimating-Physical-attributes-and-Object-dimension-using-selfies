// lib/features/camera/presentation/widgets/camera_overlay.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Measurement Guidelines
        CustomPaint(
          size: Size.infinite,
          painter: MeasurementGuidePainter(),
        ),
        // Top Instructions
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    'Position object in frame',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure the object is well-lit and centered',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MeasurementGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw outer rectangle
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.6,
      ),
      paint,
    );

    // Draw crosshair
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const crosshairSize = 20.0;

    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY),
      Offset(centerX + crosshairSize, centerY),
      paint,
    );

    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize),
      Offset(centerX, centerY + crosshairSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
