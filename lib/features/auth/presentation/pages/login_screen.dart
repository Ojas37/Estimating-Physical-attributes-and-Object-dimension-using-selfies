// lib/features/auth/presentation/pages/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/pages/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  static const String currentDateTime = '2025-02-06 18:03:32';
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 1));

      if (_emailController.text.toLowerCase() == "surajgore007@gmail.com" ||
          _emailController.text.toLowerCase() == "surajgore007") {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid credentials. Please try again.'),
              backgroundColor: AppTheme.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // App Logo
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: AppTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue measuring',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Or continue with
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppTheme.divider,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppTheme.divider,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Login Buttons

                const SizedBox(height: 24),

                // Demo Login Text
                Center(
                  child: Text(
                    'Demo Login: surajgore007@gmail.com',
                    style: AppTheme.bodySmall,
                  ),
                ),

                const SizedBox(height: 16),

                // Sign Up Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: AppTheme.bodyLarge,
      decoration: AppTheme.getInputDecoration(
        hintText: 'Email or Username',
        prefixIcon: const Icon(
          Icons.email_outlined,
          size: 20,
          color: AppTheme.textMedium,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or username';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.inputBg,
        hintText: 'Password',
        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: AppTheme.textMedium,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: AppTheme.textMedium,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
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
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
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
              'Sign In',
              style: AppTheme.buttonText,
            ),
    );
  }
}
