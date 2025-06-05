// lib/features/auth/presentation/widgets/auth_text_field.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.inputBg,
        hintText: widget.hintText,
        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppTheme.textMedium,
          size: 20,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textMedium,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accent.withOpacity(0.5)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (widget.keyboardType == TextInputType.emailAddress &&
                !value.contains('@')) {
              return 'Please enter a valid email';
            }
            if (widget.isPassword && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }
}
