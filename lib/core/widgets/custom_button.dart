// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: isPrimary ? AppTheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: !isPrimary
                  ? Border.all(color: AppTheme.accent, width: 1.5)
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: isPrimary ? AppTheme.white : AppTheme.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon!,
                            color: isPrimary ? AppTheme.white : AppTheme.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: AppTheme.buttonText.copyWith(
                            color: isPrimary ? AppTheme.white : AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
