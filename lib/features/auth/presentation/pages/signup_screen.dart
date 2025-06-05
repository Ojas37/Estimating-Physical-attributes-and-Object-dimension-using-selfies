// lib/features/auth/presentation/pages/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  static const String currentDateTime = '2025-02-06 18:05:29';
  static const String currentUser = 'surajgore-007';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passwords do not match'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Create Account',
                  style: AppTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppTheme.textMedium,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: AppTheme.textMedium,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Password',
                        isVisible: _isPasswordVisible,
                        onVisibilityChanged: (value) {
                          setState(() => _isPasswordVisible = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        isVisible: _isConfirmPasswordVisible,
                        onVisibilityChanged: (value) {
                          setState(() => _isConfirmPasswordVisible = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSignupButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Privacy Policy
                Center(
                  child: Text(
                    'By signing up, you agree to our Terms \nand Privacy Policy',
                    style: AppTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Sign In Link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Widget prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTheme.bodyLarge,
      decoration: AppTheme.getInputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.inputBg,
        hintText: hintText,
        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: AppTheme.textMedium,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppTheme.textMedium,
          ),
          onPressed: () => onVisibilityChanged(!isVisible),
        ),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSignup,
      style: AppTheme.primaryButton,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Create Account',
              style: AppTheme.buttonText,
            ),
    );
  }
}
