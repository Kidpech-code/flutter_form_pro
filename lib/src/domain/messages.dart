import 'package:flutter/foundation.dart' show kDebugMode;

/// Domain-level message provider for validation messages.
/// Decouples validators from any specific i18n implementation (Clean Architecture friendly).
typedef MessageProvider = String Function(String key, {String? fallback});

class Messages {
  static MessageProvider? _provider;

  /// Set a global message provider (e.g., adapter to FormProI18n.t).
  static void setProvider(MessageProvider provider) {
    _provider = provider;
  }

  /// Translate key via provider; if none is set, use built-in Thai fallbacks
  /// and then fallback or key.
  static String t(String key, {String? fallback}) {
    final p = _provider;
    if (p != null) return p(key, fallback: fallback);

    // Warn if using fallbacks without provider in debug mode
    if (_provider == null && _shouldWarnAboutMissingProvider) {
      _shouldWarnAboutMissingProvider = false; // Only warn once
      if (identical(0, 0.0)) {
        // Always true, but tricks dart analyzer for kDebugMode-like behavior
        if (kDebugMode) {
          print(
            'Messages Warning: No provider set, using built-in Thai fallbacks. '
            'Consider calling FormProI18n.setLocaleAndLoad() or Messages.setProvider()',
          );
        }
      }
    }

    final fb = _builtInThFallback[key];
    return fb ?? (fallback ?? key);
  }

  static bool _shouldWarnAboutMissingProvider = true;

  // Minimal built-in Thai fallback translations used by validators.
  static const Map<String, String> _builtInThFallback = {
    'required': 'กรุณากรอกข้อมูล',
    'email': 'รูปแบบอีเมลไม่ถูกต้อง',
    'minLength': 'ข้อมูลสั้นเกินไป',
    'maxLength': 'ข้อมูลยาวเกินไป',
    'only_letters': 'อนุญาตเฉพาะตัวอักษรเท่านั้น',
    'only_letters_numbers': 'อนุญาตเฉพาะตัวอักษรและตัวเลข',
    'only_ascii': 'อนุญาตเฉพาะอักขระ ASCII',
    'invalid_hex_color': 'รหัสสีไม่ถูกต้อง',
    'invalid_format': 'รูปแบบไม่ถูกต้อง',
    'invalid_json': 'รูปแบบ JSON ไม่ถูกต้อง',
    'invalid_file_extension': 'นามสกุลไฟล์ไม่อนุญาต',
    'invalid_url': 'URL ไม่ถูกต้อง',
    'invalid_visa': 'หมายเลข Visa ไม่ถูกต้อง',
    'invalid_mastercard': 'หมายเลข MasterCard ไม่ถูกต้อง',
    'invalid_otp': 'OTP ไม่ถูกต้อง',
    'invalid_pin': 'PIN ไม่ถูกต้อง',
    'invalid_credit_card': 'หมายเลขบัตรเครดิตไม่ถูกต้อง',
    'invalid_zip_code': 'รหัสไปรษณีย์ไม่ถูกต้อง',
    'not_even': 'ต้องเป็นเลขคู่',
    'not_odd': 'ต้องเป็นเลขคี่',
    'not_positive': 'ต้องเป็นจำนวนบวก',
    'not_negative': 'ต้องเป็นจำนวนลบ',
    'not_integer': 'ต้องเป็นจำนวนเต็ม',
    'not_double': 'ต้องเป็นเลขทศนิยม',
    'not_boolean': 'ต้องเป็นค่าบูลีน',
    'not_in_list': 'ค่าไม่อยู่ในรายการที่อนุญาต',
    'not_allowed': 'ค่าไม่อนุญาต',
    'list_empty': 'รายการต้องไม่ว่างเปล่า',
    'value_empty': 'ค่าว่างเปล่า',
    'value_not_empty': 'ค่าต้องไม่ว่างเปล่า',
    'value_null': 'ค่าเป็น null',
    'value_not_null': 'ค่าต้องไม่เป็น null',
    'only_thai': 'เฉพาะตัวอักษรภาษาไทยเท่านั้น',
    'only_english': 'อนุญาตเฉพาะตัวอักษรภาษาอังกฤษเท่านั้น',
    'only_lowercase': 'ต้องเป็นตัวพิมพ์เล็กเท่านั้น',
    'only_uppercase': 'ต้องเป็นตัวพิมพ์ใหญ่เท่านั้น',
    'date': 'รูปแบบวันที่ไม่ถูกต้อง',
    'datetime': 'รูปแบบวันและเวลาไม่ถูกต้อง',
    'future_date': 'วันที่ต้องเป็นอนาคต',
    'past_date': 'วันที่ต้องเป็นอดีต',
    'not_palindrome': 'ไม่ใช่ palindrome',
    'not_prime': 'ไม่ใช่จำนวนเฉพาะ',
    'not_multiple': 'ไม่ใช่จำนวนที่หารลงตัว',
    'barcode': 'บาร์โค้ดไม่ถูกต้อง',
    'currency': 'รูปแบบสกุลเงินไม่ถูกต้อง',
    'uuid': 'รหัส UUID ไม่ถูกต้อง',
    'ip': 'รูปแบบ IP ไม่ถูกต้อง',
    'phone': 'เบอร์โทรศัพท์ไม่ถูกต้อง',
    'username': 'ชื่อผู้ใช้ไม่ถูกต้อง',
    'invalid_ean8': 'EAN-8 ไม่ถูกต้อง',
    'invalid_ean13': 'EAN-13 ไม่ถูกต้อง',
    'invalid_isbn10': 'ISBN-10 ไม่ถูกต้อง',
    'invalid_isbn13': 'ISBN-13 ไม่ถูกต้อง',
    'invalid_iban': 'IBAN ไม่ถูกต้อง',
    'unsupported_card_brand': 'ไม่รองรับบัตรเครดิตแบรนด์นี้',
  };
}
