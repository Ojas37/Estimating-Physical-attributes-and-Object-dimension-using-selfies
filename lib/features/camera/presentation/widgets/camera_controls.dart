// lib/features/camera/presentation/widgets/camera_controls.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CameraControls extends StatelessWidget {
  // Change from VoidCallback? to VoidCallback
  final VoidCallback onCapture;
  final VoidCallback onClose;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onClose,
    required this.onFlashToggle,
    required this.isFlashOn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            onTap: onClose,
          ),
          _buildCaptureButton(),
          _buildActionButton(
            icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
            onTap: onFlashToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: AppTheme.textDark,
      iconSize: 28,
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: onCapture,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.accent,
          boxShadow: AppTheme.softShadow,
        ),
        child: const Icon(
          Icons.camera_alt,
          color: AppTheme.white,
          size: 32,
        ),
      ),
    );
  }
}
