import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/utils/formatters.dart';

void main() {
  group('AppFormatters', () {
    test('formatDate should strictly format dates to DD MMM YYYY', () {
      final date = DateTime(2026, 9, 10, 14, 30);
      final formatted = AppFormatters.formatDate(date);
      expect(formatted, equals('10 Sep 2026'));
    });

    test('formatTime should format to 12-hour format with AM/PM', () {
      final morning = DateTime(2026, 9, 10, 9, 15);
      final evening = DateTime(2026, 9, 10, 21, 45);

      expect(AppFormatters.formatTime(morning), equals('09:15 AM'));
      expect(AppFormatters.formatTime(evening), equals('09:45 PM'));
    });

    test('formatCurrency should format INR numbers with Indian grouping', () {
      const amount = 150000;
      final formatted = AppFormatters.formatCurrency(amount);

      // Verify symbol and grouping (e.g., ₹1,50,000.00 or ₹ 1,50,000.00)
      expect(formatted, contains('₹'));
      expect(formatted, contains('1,50,000'));
    });

    test('nowUtcIso should return valid UTC ISO-8601 string', () {
      final iso = AppFormatters.nowUtcIso();
      expect(iso, isNotEmpty);
      expect(iso.endsWith('Z'), isTrue);
    });
  });
}
