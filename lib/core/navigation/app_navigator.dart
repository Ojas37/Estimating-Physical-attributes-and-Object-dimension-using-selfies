// lib/core/navigation/app_navigator.dart

import 'package:flutter/material.dart';

class AppNavigator {
  static void navigateToSavedResults(BuildContext context) {
    Navigator.pushNamed(context, '/saved-results');
  }

  static void navigateToUnitConverter(BuildContext context) {
    Navigator.pushNamed(context, '/unit-converter');
  }

  static void navigateToPDFExport(BuildContext context, String measurementId) {
    Navigator.pushNamed(
      context,
      '/pdf-export',
      arguments: measurementId,
    );
  }
}
