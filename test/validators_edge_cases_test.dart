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

  group('Micro-validators', () {
    test('EAN-13 checksum valid/invalid', () {
      // 5901234123457 is a well-known valid EAN-13 sample
      final ean = Validators.isEAN13Checksum();
      expect(ean('5901234123457'), isNull);
      expect(ean('5901234123456'), isNotNull);
      // invalid length
      expect(ean('123456789012'), isNotNull);
    });

    test('EAN-8 checksum valid/invalid', () {
      final ean8 = Validators.isEAN8Checksum();
      expect(ean8('73513537'), isNull); // known valid sample
      expect(ean8('73513536'), isNotNull);
      expect(ean8('1234567'), isNotNull);
    });

    test('Email in allowed domains', () {
      final v = Validators.isEmailInDomains(['example.com', 'my.co']);
      expect(v('user@example.com'), isNull);
      expect(v('user@EXAMPLE.COM'), isNull);
      expect(v('user@not-allowed.com'), isNotNull);
      expect(v('invalid-email'), isNotNull);
    });

    test('IBAN validator (DE, GB samples)', () {
      final iban = Validators.iban();
      // Valid samples (sources commonly used in specs/tests)
      expect(iban('DE89 3704 0044 0532 0130 00'), isNull);
      expect(iban('GB82 WEST 1234 5698 7654 32'), isNull);
      // Invalid checksum
      expect(iban('DE89 3704 0044 0532 0130 01'), isNotNull);
      // Invalid format
      expect(iban('XX00 1234'), isNotNull);
    });

    test('Card brand detection and allowlist', () {
      // Visa (16)
      expect(Validators.detectCardBrand('4111111111111111'), 'visa');
      // MasterCard (51)
      expect(Validators.detectCardBrand('5105105105105100'), 'mastercard');
      // Amex
      expect(Validators.detectCardBrand('371449635398431'), 'amex');
      // Unknown
      expect(Validators.detectCardBrand('1234'), isNull);

      final onlyVisa = Validators.isCardBrandOneOf(['visa']);
      expect(onlyVisa('4111111111111111'), isNull);
      expect(onlyVisa('5105105105105100'), isNotNull);
    });
  });
}
