import 'package:intl/intl.dart';

/// Temporal & Currency Formatting Standards strictly adhering to:
/// staffRULES.md Rule 9 & AGENTS.md Rule 3.
/// - Display Date: Strictly DD MMM YYYY (e.g., 10 Sep 2026).
/// - Display Time: 12-Hour format with AM/PM (e.g., 09:30 AM).
/// - Currency: Indian Rupee (₹) with locale Indian numbering (en_IN).
class AppFormatters {
  AppFormatters._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateWithDayFormat = DateFormat('EEE, dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats DateTime or ISO string strictly to "DD MMM YYYY" (e.g., "10 Sep 2026")
  static String formatDate(dynamic date) {
    if (date == null) return '--';
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString()).toLocal();
      return _dateFormat.format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  /// Formats DateTime or ISO string to "EEE, DD MMM YYYY" (e.g., "Fri, 11 Sep 2026")
  static String formatDateWithDay(dynamic date) {
    if (date == null) return '--';
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString()).toLocal();
      return _dateWithDayFormat.format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  /// Formats DateTime or ISO string to 12-Hour "hh:mm a" (e.g., "09:30 AM")
  static String formatTime(dynamic date) {
    if (date == null) return '--';
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString()).toLocal();
      return _timeFormat.format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  /// Formats DateTime or ISO string to "DD MMM YYYY, hh:mm a"
  static String formatDateTime(dynamic date) {
    if (date == null) return '--';
    try {
      final parsed = date is DateTime ? date : DateTime.parse(date.toString()).toLocal();
      return _dateTimeFormat.format(parsed);
    } catch (_) {
      return date.toString();
    }
  }

  /// Formats numeric amount to Indian Rupee (₹ 1,50,000.00)
  static String formatCurrency(num? amount) {
    if (amount == null) return '₹0.00';
    return _currencyFormat.format(amount);
  }

  /// Returns current UTC timestamp in standard ISO-8601 format
  static String nowUtcIso() {
    return DateTime.now().toUtc().toIso8601String();
  }
}
