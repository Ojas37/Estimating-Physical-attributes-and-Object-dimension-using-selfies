// lib/core/utils/date_formatter.dart

import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm:ss').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
