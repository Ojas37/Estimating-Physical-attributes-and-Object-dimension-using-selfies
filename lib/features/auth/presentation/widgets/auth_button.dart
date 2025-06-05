// lib/features/auth/presentation/widgets/auth_button.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppTheme.accent,
        borderRadius: BorderRadius.circular(12),
        border:
            isOutlined ? Border.all(color: AppTheme.accent, width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: isOutlined ? AppTheme.accent : AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color:
                                isOutlined ? AppTheme.accent : AppTheme.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: AppTheme.buttonText.copyWith(
                            color:
                                isOutlined ? AppTheme.accent : AppTheme.white,
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
