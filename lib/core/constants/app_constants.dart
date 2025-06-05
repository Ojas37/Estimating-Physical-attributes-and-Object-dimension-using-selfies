class AppConstants {
  static const String appName = 'AI Measure';
  static const String version = '1.0.0';

  // Animation Durations
  static const int splashDuration = 2000;
  static const int animationDuration = 300;

  // User Messages
  static const String welcomeMessage = 'Welcome to AI Measure';
  static const String loadingMessage = 'Processing...';
  static const String errorMessage = 'Something went wrong';

  // Auth Messages
  static const String loginTitle = 'Login';
  static const String signupTitle = 'Sign Up';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String confirmPasswordHint = 'Confirm your password';

  // Home Screen
  static const String scanTitle = 'Scan Object';
  static const String resultsTitle = 'Measurement Results';
  static const String retryButton = 'Retry Scan';
  static const String saveButton = 'Save Results';

  // API Endpoints (Added but keeping original structure)
  static const String serverUrl = 'http://localhost:5000';
  static const String aiEndpoint = '/predict';
  static const String healthEndpoint = '/health';
}
