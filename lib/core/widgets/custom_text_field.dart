// lib/core/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? AppTheme.accent.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppTheme.textMedium,
                    size: 20,
                  )
                : null,
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
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
