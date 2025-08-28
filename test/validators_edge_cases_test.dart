import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

String _fmt(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

void main() {
  group('Date/time boundaries', () {
    test('isFutureDate: today should be invalid; tomorrow valid', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final v = Validators.isFutureDate();
      expect(v(_fmt(today)), isNotNull);
      expect(v(_fmt(tomorrow)), isNull);
    });

    test('isPastDate: yesterday valid; invalid format rejected', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final v = Validators.isPastDate();
      expect(v(_fmt(yesterday)), isNull);
      expect(v('2024/01/01'), isNotNull); // invalid format
    });

    test('date format validator', () {
      final good = Validators.date();
      final bad = Validators.date();
      expect(good('2025-01-31'), isNull);
      expect(bad('2025/01/31'), isNotNull);
    });
  });

  group('List/Enum negative paths', () {
    test('isInList returns error when value not in list', () {
      final v = Validators.isInList(['a', 'b']);
      expect(v('c'), isNotNull);
    });

    test('isNotInList returns error when value is in list', () {
      final v = Validators.isNotInList(['x', 'y']);
      expect(v('x'), isNotNull);
    });

    test('isEnumValue returns error when not in enum', () {
      final values = ['one', 'two'];
      final v = Validators.isEnumValue(values);
      expect(v('three'), isNotNull);
    });
  });
}
