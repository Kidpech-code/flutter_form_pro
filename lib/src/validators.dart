import 'dart:convert';
import 'domain/messages.dart';

typedef Validator = String? Function(dynamic value);
typedef AsyncValidator = Future<String?> Function(dynamic value);

class Validators {
  /// Minimal adapter for async validators (e.g., server-side checks).
  /// Returns last known result; while pending, returns [pendingMessage].
  static Validator async(AsyncValidator check, {String? pendingMessage}) {
    String? last;
    bool inFlight = false;
    return (value) {
      if (!inFlight) {
        inFlight = true;
        () async {
          try {
            last = await check(value);
          } finally {
            inFlight = false;
          }
        }();
      }
      return last ?? pendingMessage;
    };
  }

  // Cached regex patterns for performance
  static final RegExp _uuidV4 = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ); // รูปแบบ UUID เวอร์ชัน 4
  static final RegExp _ipv4 = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$'); // รูปแบบที่อยู่ IPv4
  static final RegExp _ipv6 = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'); // รูปแบบที่อยู่ IPv6
  static final RegExp _currency = RegExp(r'^\d+(\.\d{1,2})?$'); // จำนวนเงิน ทศนิยมไม่เกิน 2 หลัก
  static final RegExp _baht = RegExp(r'^฿\d+(\.\d{1,2})?$'); // จำนวนเงินสกุลบาทไทย (฿)
  static final RegExp _dollar = RegExp(r'^\$\d+(\.\d{1,2})?$'); // จำนวนเงินสกุลดอลลาร์ ($)
  static final RegExp _ean13 = RegExp(r'^\d{13}$'); // บาร์โค้ด EAN-13 (13 หลัก)
  static final RegExp _ean8 = RegExp(r'^\d{8}$'); // บาร์โค้ด EAN-8 (8 หลัก)
  static final RegExp _hasWhitespace = RegExp(r'\s'); // ตรวจจับช่องว่าง (whitespace)
  static final RegExp _repeatChar = RegExp(r'(.)\1{2,}'); // ตัวอักษรซ้ำติดกันตั้งแต่ 3 ตัวขึ้นไป
  static final RegExp _sequential = RegExp(
    r'(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
  );
  static final RegExp _thaiPhone = RegExp(r'^(0[689]{1})\d{8}$'); // เบอร์โทรศัพท์ไทย 10 หลัก เริ่มด้วย 06/08/09
  static final RegExp _thaiZip = RegExp(r'^[1-9][0-9]{4}$'); // รหัสไปรษณีย์ไทย 5 หลัก (ขึ้นต้น 1-9)
  static final RegExp _visa = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$'); // เลขบัตร Visa (ขึ้นต้นด้วย 4)
  static final RegExp _mastercard = RegExp(r'^5[1-5][0-9]{14}$'); // เลขบัตร MasterCard (ขึ้นต้นด้วย 51-55)
  static final RegExp _alpha = RegExp(r'^[A-Za-z]+$'); // ตัวอักษรภาษาอังกฤษเท่านั้น
  static final RegExp _alnum = RegExp(r'^[A-Za-z0-9]+$'); // ตัวอักษรและตัวเลขเท่านั้น
  static final RegExp _ascii = RegExp(r'^[\x00-\x7F]+$'); // อักขระ ASCII เท่านั้น
  static final RegExp _hexColor = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$'); // สี Hex 3 หรือ 6 หลัก (มี/ไม่มี #)
  static final RegExp _url = RegExp(r"^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-\._\?\,\'\/\\\+&%\$#=~]*)?"); // รูปแบบ URL (http/https)
  static final RegExp _email = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'); // อีเมลพื้นฐาน name@domain.tld
  static final RegExp _phone = RegExp(r'^(\+\d{1,3}[- ]?)?\d{9,15}$'); // เบอร์โทรศัพท์สากล 9-15 หลัก รองรับ +รหัสประเทศ
  static final RegExp _username = RegExp(r'^[A-Za-z0-9_]{3,20}$'); // ชื่อผู้ใช้ A-Z a-z 0-9 และ _ ความยาว 3-20 ตัว
  static final RegExp _usernameLettersOnly = RegExp(r'^[A-Za-z]{3,20}$'); // ชื่อผู้ใช้: ตัวอักษรเท่านั้น
  static final RegExp _usernameLowercaseOnly = RegExp(r'^[a-z]{3,20}$'); // ชื่อผู้ใช้: ตัวอักษรพิมพ์เล็กเท่านั้น
  static final RegExp _usernameAlnumOnly = RegExp(r'^[A-Za-z0-9]{3,20}$'); // ชื่อผู้ใช้: ตัวอักษรและตัวเลข (ไม่มีอักขระพิเศษ)
  static final RegExp _otp = RegExp(r'^\d{6}$'); // รหัส OTP 6 หลัก
  static final RegExp _pin = RegExp(r'^\d{4,6}$'); // รหัส PIN 4-6 หลัก
  static final RegExp _pwdStrong = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$',
  ); // รหัสผ่านแข็งแรง ≥8 ตัว: มีตัวเล็ก ตัวใหญ่ ตัวเลข และอักขระพิเศษ
  static final RegExp _pwdNumber = RegExp(r'^[0-9]+$'); // รหัสผ่านเป็นตัวเลขล้วน
  static final RegExp _pwdNumberText = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$'); // รหัสผ่านมีตัวอักษรและตัวเลข
  static final RegExp _pwdNumberOrText = RegExp(r'^[A-Za-z0-9]+$'); // รหัสผ่านเป็นตัวอักษรหรือตัวเลขเท่านั้น
  static final RegExp _pwdNumberTextSpecial = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]+$',
  ); // รหัสผ่านมีตัวอักษร ตัวเลข และอักขระพิเศษ
  static final RegExp _pwdLettersOnlyWithUpper = RegExp(r'^(?=.*[A-Z])[A-Za-z]+$'); // รหัสผ่าน: ตัวอักษรเท่านั้น และต้องมีตัวพิมพ์ใหญ่ ≥1
  static final RegExp _thaiOnly = RegExp(r'^[ก-๙\s]+$'); // ข้อความภาษาไทยและช่องว่างเท่านั้น
  static final RegExp _engOnly = RegExp(r'^[A-Za-z\s]+$'); // ข้อความภาษาอังกฤษและช่องว่างเท่านั้น
  static final RegExp _date = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // วันที่รูปแบบ YYYY-MM-DD
  static final RegExp _datetime = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'); // วันเวลา YYYY-MM-DD HH:mm:ss
  static final RegExp _nationalId13 = RegExp(r'^\d{13}$'); // ตัวเลข 13 หลักสำหรับบัตรประชาชนไทย
  static final RegExp _zip5 = RegExp(r'^\d{5}$'); // รหัสไปรษณีย์ 5 หลักทั่วไป

  // ===================== UUID Validators =====================
  /// UUID v4
  static Validator isUUIDv4([String? message]) {
    // ตรวจสอบรูปแบบ UUID เวอร์ชัน 4
    return (value) => (value is String && !_uuidV4.hasMatch(value)) ? (message ?? Messages.t('uuid')) : null;
  }

  // ===================== IP Validators =====================
  /// IPv4
  static Validator isIPv4([String? message]) {
    // ตรวจสอบรูปแบบที่อยู่ IP เวอร์ชัน 4
    return (value) => (value is String && !_ipv4.hasMatch(value)) ? (message ?? Messages.t('ip')) : null;
  }

  /// IPv6
  static Validator isIPv6([String? message]) {
    // ตรวจสอบรูปแบบที่อยู่ IP เวอร์ชัน 6
    return (value) => (value is String && !_ipv6.hasMatch(value)) ? (message ?? Messages.t('ip')) : null;
  }

  // ===================== Currency Validators =====================
  /// Any currency (number, optional 2 decimals)
  static Validator isCurrency([String? message]) {
    // ตรวจสอบจำนวนเงินรูปแบบทั่วไป (ทศนิยมไม่เกิน 2 ตำแหน่ง)
    return (value) => (value is String && !_currency.hasMatch(value)) ? (message ?? Messages.t('currency')) : null;
  }

  /// Thai Baht (฿)
  static Validator isBaht([String? message]) {
    // ตรวจสอบจำนวนเงินสกุลบาทไทย (สัญลักษณ์ ฿)
    return (value) => (value is String && !_baht.hasMatch(value)) ? (message ?? Messages.t('currency')) : null;
  }

  /// US Dollar ($)
  static Validator isDollar([String? message]) {
    // ตรวจสอบจำนวนเงินสกุลดอลลาร์สหรัฐ (สัญลักษณ์ $)
    return (value) => (value is String && !_dollar.hasMatch(value)) ? (message ?? Messages.t('currency')) : null;
  }

  // ===================== Barcode Validators =====================
  /// EAN-13 barcode
  static Validator isEAN13([String? message]) {
    // ตรวจสอบบาร์โค้ด EAN-13
    return (value) => (value is String && !_ean13.hasMatch(value)) ? (message ?? Messages.t('barcode')) : null;
  }

  /// EAN-8 barcode
  static Validator isEAN8([String? message]) {
    // ตรวจสอบบาร์โค้ด EAN-8
    return (value) => (value is String && !_ean8.hasMatch(value)) ? (message ?? Messages.t('barcode')) : null;
  }

  /// EAN-8 with checksum validation
  static Validator isEAN8Checksum([String? message]) {
    return (value) {
      if (value is! String || !_ean8.hasMatch(value)) {
        return message ?? Messages.t('invalid_ean8', fallback: 'Invalid EAN-8');
      }
      int sum = 0;
      for (int i = 0; i < 7; i++) {
        final d = value.codeUnitAt(i) - 48; // '0' => 48
        // EAN-8: weight 3 for indices 0,2,4,6; weight 1 for 1,3,5
        sum += (i % 2 == 0) ? d * 3 : d;
      }
      final check = (10 - (sum % 10)) % 10;
      final last = value.codeUnitAt(7) - 48;
      return check == last ? null : (message ?? Messages.t('invalid_ean8', fallback: 'Invalid EAN-8 checksum'));
    };
  }

  /// EAN-13 with checksum validation (12-digit body + 1 checksum)
  static Validator isEAN13Checksum([String? message]) {
    return (value) {
      if (value is! String || !_ean13.hasMatch(value)) {
        return message ?? Messages.t('invalid_ean13', fallback: 'Invalid EAN-13');
      }
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        final d = value.codeUnitAt(i) - 48; // '0' => 48
        // positions: 0..11 -> EAN rule: even index (0-based) weight 1, odd index weight 3
        sum += (i % 2 == 0) ? d : d * 3;
      }
      final check = (10 - (sum % 10)) % 10;
      final last = value.codeUnitAt(12) - 48;
      return check == last ? null : (message ?? Messages.t('invalid_ean13', fallback: 'Invalid EAN-13 checksum'));
    };
  }

  // ===================== Password Policy Validators =====================
  /// No whitespace
  static Validator noWhitespace([String? message]) {
    // ห้ามมีช่องว่างในค่า
    return (value) =>
        (value is String && _hasWhitespace.hasMatch(value)) ? (message ?? Messages.t('no_whitespace', fallback: 'No whitespace allowed')) : null;
  }

  /// No repeat char (aaa, 111)
  static Validator noRepeatChar([String? message]) {
    // ห้ามมีอักขระซ้ำติดกันเกิน 2 ตัว (เช่น aaa, 111)
    return (value) =>
        (value is String && _repeatChar.hasMatch(value)) ? (message ?? Messages.t('no_repeat_char', fallback: 'No repeated characters')) : null;
  }

  /// No sequential char (abc, 123)
  static Validator noSequentialChar([String? message]) {
    // ห้ามมีอักขระลำดับต่อเนื่อง (เช่น abc, 123)
    return (value) => (value is String && _sequential.hasMatch(value.toLowerCase()))
        ? (message ?? Messages.t('no_sequential_char', fallback: 'No sequential characters'))
        : null;
  }

  // ===================== Custom Logic Validators =====================
  /// Palindrome
  static Validator isPalindrome([String? message]) {
    // ตรวจสอบว่าเป็นพาลินโดรม (อ่านกลับหลังได้เหมือนเดิม)
    return (value) {
      if (value is! String) {
        return null;
      }
      String s = value.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      return s == s.split('').reversed.join('') ? null : (message ?? Messages.t('not_palindrome', fallback: 'Not a palindrome'));
    };
  }

  /// Prime number
  static Validator isPrime([String? message]) {
    // ตรวจสอบจำนวนเฉพาะ (Prime number) ด้วยอัลกอริทึมแบบ sqrt(n) และ 6k±1 เพื่อประสิทธิภาพ
    return (value) {
      int? n = value is int ? value : int.tryParse(value?.toString() ?? '');
      if (n == null || n < 2) {
        return (message ?? Messages.t('not_prime', fallback: 'Not a prime number'));
      }
      if (n == 2 || n == 3) {
        return null;
      }
      if (n % 2 == 0 || n % 3 == 0) {
        return (message ?? Messages.t('not_prime', fallback: 'Not a prime number'));
      }
      for (int i = 5; i * i <= n; i += 6) {
        if (n % i == 0 || n % (i + 2) == 0) {
          return (message ?? Messages.t('not_prime', fallback: 'Not a prime number'));
        }
      }
      return null;
    };
  }

  /// Multiple of n
  static Validator isMultipleOf(int n, [String? message]) {
    // ตรวจสอบว่าเป็นพหุคูณของ n
    return (value) {
      int? v = value is int ? value : int.tryParse(value?.toString() ?? '');
      return (v != null && v % n == 0) ? null : (message ?? Messages.t('not_multiple', fallback: 'Not a multiple of $n'));
    };
  }

  // ===================== Thai Validators =====================
  /// Thai phone number (09xxxxxxxx, 08xxxxxxxx, 06xxxxxxxx)
  static Validator isThaiPhone([String? message]) {
    // ตรวจสอบเบอร์โทรศัพท์ไทย (06/08/09)
    return (value) => (value is String && !_thaiPhone.hasMatch(value)) ? (message ?? Messages.t('phone')) : null;
  }

  /// Thai zip code (5 digits, 10xxx-96xxx)
  static Validator isThaiZipCode([String? message]) {
    // ตรวจสอบรหัสไปรษณีย์ไทย 5 หลัก
    return (value) => (value is String && !_thaiZip.hasMatch(value)) ? (message ?? Messages.t('invalid_zip_code')) : null;
  }

  // ===================== CreditCard Validators =====================
  /// Visa card (starts with 4, 13/16 digits)
  static Validator isVisaCard([String? message]) {
    // ตรวจสอบเลขบัตรเครดิต Visa
    return (value) => (value is String && !_visa.hasMatch(value)) ? (message ?? Messages.t('invalid_visa')) : null;
  }

  /// MasterCard (starts with 5, 16 digits)
  static Validator isMasterCard([String? message]) {
    // ตรวจสอบเลขบัตรเครดิต MasterCard
    return (value) => (value is String && !_mastercard.hasMatch(value)) ? (message ?? Messages.t('invalid_mastercard')) : null;
  }

  // ===================== Boolean Validators =====================
  static Validator isTrue([String? message]) {
    // ต้องเป็นค่า true เท่านั้น
    return (value) => value == true ? null : (message ?? Messages.t('value_must_be_true', fallback: 'Value must be true'));
  }

  static Validator isFalse([String? message]) {
    // ต้องเป็นค่า false เท่านั้น
    return (value) => value == false ? null : (message ?? Messages.t('value_must_be_false', fallback: 'Value must be false'));
  }

  // ===================== Enum Validators =====================
  static Validator isEnumValue(List enumValues, [String? message]) {
    // ตรวจสอบว่าค่าอยู่ในชุดค่า (Enum) ด้วย Set เพื่อประสิทธิภาพ
    final set = enumValues is Set ? enumValues : enumValues.toSet();
    return (value) => set.contains(value) ? null : (message ?? Messages.t('not_in_enum', fallback: 'Value not in enum'));
  }

  // ===================== Custom/Advanced Validators =====================
  /// Run [inner] only when value is not empty (null or blank strings are treated as valid).
  /// Useful for optional fields: combine with [required] when you need non-empty values.
  static Validator whenNotEmpty(Validator inner) {
    return (value) {
      if (value == null) {
        return null;
      }
      if (value is String && value.trim().isEmpty) {
        return null;
      }
      return inner(value);
    };
  }

  /// Like [whenNotEmpty], but composes multiple validators and returns the first error.
  /// Example: `validator: Validators.optional([Validators.email(), Validators.maxLength(64)])`
  static Validator optional(List<Validator> validators) {
    final composed = multi(validators);
    return whenNotEmpty(composed);
  }

  /// Combine multiple validators (returns first error)
  static Validator multi(List<Validator> validators) {
    // รวมหลายตัวตรวจสอบ คืนข้อผิดพลาดแรกที่พบ
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Not match pattern
  static Validator notMatch(RegExp pattern, [String? message]) {
    // ไม่อนุญาตให้ตรงกับรูปแบบที่กำหนด
    return (value) => (value is String && pattern.hasMatch(value)) ? (message ?? Messages.t('invalid_value', fallback: 'Invalid value')) : null;
  }

  // ===================== String Validators =====================
  /// Only alphabetic (A-Z, a-z)
  static Validator isAlpha([String? message]) {
    // อนุญาตเฉพาะตัวอักษรภาษาอังกฤษ (A-Z, a-z)
    return (value) => (value is String && !_alpha.hasMatch(value)) ? (message ?? Messages.t('only_letters')) : null;
  }

  /// Only alphanumeric (A-Z, a-z, 0-9)
  static Validator isAlphanumeric([String? message]) {
    // อนุญาตเฉพาะตัวอักษรและตัวเลข (A-Z, a-z, 0-9)
    return (value) => (value is String && !_alnum.hasMatch(value)) ? (message ?? Messages.t('only_letters_numbers')) : null;
  }

  /// Only ASCII
  static Validator isAscii([String? message]) {
    // อนุญาตเฉพาะอักขระ ASCII
    return (value) => (value is String && !_ascii.hasMatch(value)) ? (message ?? Messages.t('only_ascii')) : null;
  }

  /// Hex color (#fff, #ffffff)
  static Validator isHexColor([String? message]) {
    // ตรวจสอบรหัสสี Hex (#fff, #ffffff)
    return (value) => (value is String && !_hexColor.hasMatch(value)) ? (message ?? Messages.t('invalid_hex_color')) : null;
  }

  /// JSON string
  static Validator isJson([String? message]) {
    // ตรวจสอบว่าเป็นสตริง JSON ที่แปลงได้ (pre-check ก่อน parse เพื่อลด exception)
    return (value) {
      if (value is! String) {
        return null;
      }
      final s = value.trimLeft();
      if (s.isEmpty) {
        return null;
      }
      const allowedStarts = '{["tfn-0123456789';
      if (!allowedStarts.contains(s[0])) {
        return message ?? Messages.t('invalid_json');
      }
      try {
        final _ = jsonDecode(s);
        return null;
      } catch (_) {
        return message ?? Messages.t('invalid_json');
      }
    };
  }

  // ===================== File Validators =====================
  /// File extension allowed
  static Validator isFileExtension(List<String> exts, [String? message]) {
    // ตรวจสอบว่านามสกุลไฟล์อยู่ในรายการที่อนุญาต
    return (value) => (value is String && !exts.any((e) => value.endsWith(e))) ? (message ?? Messages.t('invalid_file_extension')) : null;
  }

  // ===================== Network Validators =====================
  /// URL format
  static Validator isUrl([String? message]) {
    // ตรวจสอบรูปแบบ URL
    return (value) => (value is String && !_url.hasMatch(value)) ? (message ?? Messages.t('invalid_url')) : null;
  }

  /// Email must end with domain
  static Validator isEmailDomain(String domain, [String? message]) {
    // อีเมลต้องลงท้ายด้วยโดเมนที่กำหนด
    return (value) => (value is String && value.contains('@') && !value.endsWith('@$domain'))
        ? (message ?? Messages.t('email_must_end_with', fallback: 'Email must end with @$domain'))
        : null;
  }

  /// Email must belong to one of the allowed domains (case-insensitive)
  static Validator isEmailInDomains(Iterable<String> allowedDomains, [String? message]) {
    final set = allowedDomains.map((e) => e.toLowerCase()).toSet();
    return (value) {
      if (value is! String || !value.contains('@')) {
        return message ?? Messages.t('email', fallback: 'Invalid email');
      }
      final domain = value.split('@').last.toLowerCase();
      return set.contains(domain) ? null : (message ?? Messages.t('email_must_end_with', fallback: 'Email must be in allowed domains'));
    };
  }

  // ===================== Utility/Empty Validators =====================
  /// Value is empty (String, List, Map)
  static Validator isEmpty([String? message]) {
    // ตรวจสอบค่าว่าง (String/List/Map)
    return (value) {
      if (value == null) {
        return (message ?? Messages.t('value_empty'));
      }
      if (value is String && value.trim().isEmpty) {
        return (message ?? Messages.t('value_empty'));
      }
      if (value is List && value.isEmpty) {
        return (message ?? Messages.t('value_empty'));
      }
      if (value is Map && value.isEmpty) {
        return (message ?? Messages.t('value_empty'));
      }
      return null;
    };
  }

  /// Value is not empty (String, List, Map)
  static Validator isNotEmpty([String? message]) {
    // ตรวจสอบว่าไม่ว่าง (ต้องมีค่า)
    return (value) {
      if (value == null) {
        return (message ?? Messages.t('value_not_empty'));
      }
      if (value is String && value.trim().isEmpty) {
        return (message ?? Messages.t('value_not_empty'));
      }
      if (value is List && value.isEmpty) {
        return (message ?? Messages.t('value_not_empty'));
      }
      if (value is Map && value.isEmpty) {
        return (message ?? Messages.t('value_not_empty'));
      }
      return null;
    };
  }

  /// Value is null
  static Validator isNull([String? message]) {
    // ต้องเป็นค่า null เท่านั้น
    return (value) => value == null ? (message ?? Messages.t('value_null')) : null;
  }

  /// Value is not null
  static Validator isNotNull([String? message]) {
    // ต้องไม่เป็นค่า null
    return (value) => value != null ? null : (message ?? Messages.t('value_not_null'));
  }

  static Validator onlyThaiText([String? message]) {
    // อนุญาตเฉพาะภาษาไทยและช่องว่าง
    return (value) => (value is String && !_thaiOnly.hasMatch(value)) ? (message ?? Messages.t('only_thai')) : null;
  }

  static Validator onlyEnglishText([String? message]) {
    // อนุญาตเฉพาะภาษาอังกฤษและช่องว่าง
    return (value) => (value is String && !_engOnly.hasMatch(value)) ? (message ?? Messages.t('only_english')) : null;
  }

  static Validator isLowerCase([String? message]) {
    // ต้องเป็นตัวพิมพ์เล็กทั้งหมด
    return (value) => (value is String && value != value.toLowerCase()) ? (message ?? Messages.t('only_lowercase')) : null;
  }

  static Validator isUpperCase([String? message]) {
    // ต้องเป็นตัวพิมพ์ใหญ่ทั้งหมด
    return (value) => (value is String && value != value.toUpperCase()) ? (message ?? Messages.t('only_uppercase')) : null;
  }

  static Validator pattern(RegExp pattern, [String? message]) {
    // ตรวจสอบด้วยรูปแบบ RegExp ที่กำหนดเอง
    return (value) => (value is String && !pattern.hasMatch(value)) ? (message ?? Messages.t('invalid_format')) : null;
  }

  static Validator minLength(int min, [String? message]) {
    // ความยาวอย่างน้อย min ตัวอักษร
    return (value) => (value is String && value.length < min) ? (message ?? Messages.t('minLength')) : null;
  }

  static Validator maxLength(int max, [String? message]) {
    // ความยาวไม่เกิน max ตัวอักษร
    return (value) => (value is String && value.length > max) ? (message ?? Messages.t('maxLength', fallback: 'Maximum $max characters')) : null;
  }

  static Validator required([String? message]) {
    // ต้องระบุค่า (ห้ามว่าง)
    return (value) => (value == null || (value is String && value.trim().isEmpty)) ? (message ?? Messages.t('required')) : null;
  }

  static Validator email([String? message]) {
    // ตรวจสอบรูปแบบอีเมล
    return (value) {
      if (value == null || value is! String || value.trim().isEmpty) {
        return null;
      }
      return _email.hasMatch(value) ? null : (message ?? Messages.t('email'));
    };
  }

  // ===================== Number Validators =====================
  static Validator isInt([String? message]) {
    // ต้องเป็นจำนวนเต็ม (int)
    return (value) => (value is int || (value is String && int.tryParse(value) != null)) ? null : (message ?? Messages.t('not_integer'));
  }

  static Validator isDouble([String? message]) {
    // ต้องเป็นจำนวนทศนิยม (double)
    return (value) => (value is double || (value is String && double.tryParse(value) != null)) ? null : (message ?? Messages.t('not_double'));
  }

  static Validator isBool([String? message]) {
    // ต้องเป็นค่า boolean (true/false)
    return (value) => (value is bool || (value is String && (value == 'true' || value == 'false'))) ? null : (message ?? Messages.t('not_boolean'));
  }

  static Validator isPositive([String? message]) {
    // ต้องเป็นจำนวนบวก (> 0)
    return (value) => (value is num && value > 0) ? null : (message ?? Messages.t('not_positive'));
  }

  static Validator isNegative([String? message]) {
    // ต้องเป็นจำนวนลบ (< 0)
    return (value) => (value is num && value < 0) ? null : (message ?? Messages.t('not_negative'));
  }

  static Validator isEven([String? message]) {
    // ต้องเป็นเลขคู่
    return (value) => (value is int && value % 2 == 0) ? null : (message ?? Messages.t('not_even'));
  }

  static Validator isOdd([String? message]) {
    // ต้องเป็นเลขคี่
    return (value) => (value is int && value % 2 == 1) ? null : (message ?? Messages.t('not_odd'));
  }

  // ===================== List Validators =====================
  static Validator isInList(List values, [String? message]) {
    // ค่าอยู่ในรายการที่กำหนด (ใช้ Set เพื่อ O(1))
    final set = values is Set ? values : values.toSet();
    return (value) => set.contains(value) ? null : (message ?? Messages.t('not_in_list'));
  }

  static Validator isNotInList(List values, [String? message]) {
    // ค่าไม่อยู่ในรายการที่กำหนด (ใช้ Set เพื่อ O(1))
    final set = values is Set ? values : values.toSet();
    return (value) => !set.contains(value) ? null : (message ?? Messages.t('not_allowed'));
  }

  static Validator notEmptyList([String? message]) {
    // รายการต้องไม่ว่างเปล่า
    return (value) => (value is List && value.isEmpty) ? (message ?? Messages.t('list_empty')) : null;
  }

  // ===================== Date/Time Validators =====================
  static Validator date([String? message]) {
    // ตรวจสอบรูปแบบวันที่ (YYYY-MM-DD); รองรับ DateTime โดยผ่านทันที
    return (value) {
      if (value is DateTime) {
        return null;
      }
      return (value is String && _date.hasMatch(value)) ? null : (message ?? Messages.t('date'));
    };
  }

  static Validator datetime([String? message]) {
    // ตรวจสอบรูปแบบวันเวลา (YYYY-MM-DD HH:mm:ss); รองรับ DateTime โดยผ่านทันที
    return (value) {
      if (value is DateTime) {
        return null;
      }
      return (value is String && _datetime.hasMatch(value)) ? null : (message ?? Messages.t('datetime'));
    };
  }

  static Validator isFutureDate([String? message]) {
    // ต้องเป็นวันที่ในอนาคต
    return (value) {
      DateTime? date;
      if (value is DateTime) {
        date = value;
      } else if (value is String && _date.hasMatch(value)) {
        date = DateTime.tryParse(value);
      } else {
        return message ?? Messages.t('invalid_date', fallback: 'Invalid date');
      }
      final now = DateTime.now();
      return (date != null && date.isAfter(now)) ? null : (message ?? Messages.t('future_date'));
    };
  }

  static Validator isPastDate([String? message]) {
    // ต้องเป็นวันที่ในอดีต
    return (value) {
      DateTime? date;
      if (value is DateTime) {
        date = value;
      } else if (value is String && _date.hasMatch(value)) {
        date = DateTime.tryParse(value);
      } else {
        return message ?? Messages.t('invalid_date', fallback: 'Invalid date');
      }
      final now = DateTime.now();
      return (date != null && date.isBefore(now)) ? null : (message ?? Messages.t('past_date'));
    };
  }

  // ===================== Auth/Security Validators =====================
  static Validator otp([String? message]) {
    // ตรวจสอบรหัส OTP 6 หลัก
    return (value) => (value is String && _otp.hasMatch(value)) ? null : (message ?? Messages.t('invalid_otp'));
  }

  /// IBAN (International Bank Account Number) validator (mod-97 algorithm)
  /// Accepts strings with or without spaces; case-insensitive.
  static Validator iban([String? message]) {
    final pattern = RegExp(r'^[A-Za-z]{2}\d{2}[A-Za-z0-9]{1,30}$');
    int mod97(String s) {
      int rem = 0;
      for (int i = 0; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (c >= 48 && c <= 57) {
          // 0-9
          rem = (rem * 10 + (c - 48)) % 97;
        } else if (c >= 65 && c <= 90) {
          // A-Z => 10..35
          final v = (c - 55); // 'A'(65)->10
          // two digits possibly: treat as string digits
          final tens = v >= 10 ? v ~/ 10 : 0;
          final ones = v % 10;
          if (tens > 0) {
            rem = (rem * 10 + tens) % 97;
          }
          rem = (rem * 10 + ones) % 97;
        } else {
          // Should not happen if prevalidated
          return -1;
        }
      }
      return rem;
    }

    return (value) {
      if (value is! String) {
        return null;
      }
      final raw = value.replaceAll(' ', '').toUpperCase();
      if (raw.length < 15 || raw.length > 34 || !pattern.hasMatch(raw)) {
        return message ?? Messages.t('invalid_iban', fallback: 'Invalid IBAN');
      }
      // Move first 4 chars to the end
      final rearranged = raw.substring(4) + raw.substring(0, 4);
      final result = mod97(rearranged);
      return result == 1 ? null : (message ?? Messages.t('invalid_iban', fallback: 'Invalid IBAN'));
    };
  }

  // ===================== ISBN Validators =====================
  /// ISBN-10 (accepts digits and X as checksum, hyphens/spaces ignored)
  static Validator isISBN10([String? message]) {
    return (value) {
      if (value is! String) {
        return null;
      }
      final s = value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();
      if (s.length != 10) {
        return message ?? Messages.t('invalid_isbn10', fallback: 'Invalid ISBN-10');
      }
      int sum = 0;
      for (int i = 0; i < 9; i++) {
        final c = s.codeUnitAt(i);
        if (c < 48 || c > 57) {
          return message ?? Messages.t('invalid_isbn10', fallback: 'Invalid ISBN-10');
        }
        final d = c - 48;
        final weight = 10 - i;
        sum += weight * d;
      }
      int lastVal;
      final last = s[s.length - 1];
      if (last == 'X') {
        lastVal = 10;
      } else {
        final c = last.codeUnitAt(0);
        if (c < 48 || c > 57) {
          return message ?? Messages.t('invalid_isbn10', fallback: 'Invalid ISBN-10');
        }
        lastVal = c - 48;
      }
      sum += lastVal; // weight 1 for last position
      return (sum % 11 == 0) ? null : (message ?? Messages.t('invalid_isbn10', fallback: 'Invalid ISBN-10 checksum'));
    };
  }

  /// ISBN-13 (hyphens/spaces ignored; EAN-13 checksum)
  static Validator isISBN13([String? message]) {
    return (value) {
      if (value is! String) {
        return null;
      }
      final s = value.replaceAll(RegExp(r'[-\s]'), '');
      if (!_ean13.hasMatch(s)) {
        return message ?? Messages.t('invalid_isbn13', fallback: 'Invalid ISBN-13');
      }
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        final d = s.codeUnitAt(i) - 48;
        sum += (i % 2 == 0) ? d : d * 3;
      }
      final check = (10 - (sum % 10)) % 10;
      final last = s.codeUnitAt(12) - 48;
      return check == last ? null : (message ?? Messages.t('invalid_isbn13', fallback: 'Invalid ISBN-13 checksum'));
    };
  }

  // ===================== Card Brand Helpers =====================
  /// Detect credit card brand by number (digits only). Returns lower-case brand id or null.
  /// Brands: visa, mastercard, amex, discover, jcb, diners, unionpay
  static String? detectCardBrand(String? number) {
    if (number == null) {
      return null;
    }
    final n = number.replaceAll(RegExp(r'\D'), '');
    if (n.isEmpty) {
      return null;
    }
    // Visa: 4, length 13/16/19
    if (RegExp(r'^4\d{12}(\d{3})?(\d{3})?$').hasMatch(n)) {
      return 'visa';
    }

    // MasterCard: 51-55 or 2221-2720 (16)
    if (RegExp(r'^(5[1-5]\d{14}|2(2[2-9]\d|[3-6]\d{2}|7(0\d|1\d|20))\d{12})$').hasMatch(n)) {
      return 'mastercard';
    }

    // Amex: 34 or 37 (15)
    if (RegExp(r'^(34|37)\d{13}$').hasMatch(n)) {
      return 'amex';
    }

    // Discover: various ranges (16/19)
    if (RegExp(r'^(6011\d{12}|65\d{14}|64[4-9]\d{13}|622(12[6-9]|1[3-9]\d|[2-8]\d{2}|9([01]\d|2[0-5]))\d{10})$').hasMatch(n)) {
      return 'discover';
    }

    // JCB: 3528-3589 (16)
    if (RegExp(r'^(35[2-8]\d{13})$').hasMatch(n)) {
      return 'jcb';
    }

    // Diners Club: 300-305, 36, 38 (14)
    if (RegExp(r'^(3(0[0-5]|[68]\d)\d{11})$').hasMatch(n)) {
      return 'diners';
    }

    // UnionPay: 62... (16-19)
    if (RegExp(r'^(62\d{14,17})$').hasMatch(n)) {
      return 'unionpay';
    }

    return null;
  }

  /// Validate that the card brand is one of [allowedBrands].
  static Validator isCardBrandOneOf(Iterable<String> allowedBrands, [String? message]) {
    final set = allowedBrands.map((e) => e.toLowerCase()).toSet();
    return (value) {
      final brand = detectCardBrand(value?.toString());
      return (brand != null && set.contains(brand)) ? null : (message ?? Messages.t('unsupported_card_brand', fallback: 'Unsupported card brand'));
    };
  }

  static Validator pin([String? message]) {
    // ตรวจสอบรหัส PIN 4-6 หลัก
    return (value) => (value is String && _pin.hasMatch(value)) ? null : (message ?? Messages.t('invalid_pin'));
  }

  static Validator passwordStrong([String? message]) {
    // รหัสผ่านแข็งแรง: มีตัวเล็ก ตัวใหญ่ ตัวเลข และอักขระพิเศษ อย่างละอย่าง
    return (value) => (value is String && _pwdStrong.hasMatch(value))
        ? null
        : (message ?? Messages.t('password_not_strong', fallback: 'Password not strong enough'));
  }

  static Validator passwordWeak([String? message]) {
    // รหัสผ่านพื้นฐาน: ความยาวอย่างน้อย 4 ตัวอักษร
    return (value) => (value is String && value.length >= 4) ? null : (message ?? Messages.t('password_too_weak', fallback: 'Password too weak'));
  }

  static Validator passwordNumber([String? message]) {
    // รหัสผ่านเป็นตัวเลขล้วน
    return (value) => (value is String && _pwdNumber.hasMatch(value)) ? null : (message ?? Messages.t('password_number'));
  }

  static Validator passwordNumberText([String? message]) {
    // รหัสผ่านต้องมีตัวอักษรและตัวเลข
    return (value) => (value is String && _pwdNumberText.hasMatch(value)) ? null : (message ?? Messages.t('password_number_text'));
  }

  static Validator passwordNumberOrText([String? message]) {
    // รหัสผ่านเป็นตัวอักษรหรือตัวเลขเท่านั้น
    return (value) => (value is String && _pwdNumberOrText.hasMatch(value)) ? null : (message ?? Messages.t('password_number_or_text'));
  }

  static Validator passwordNumberTextSpecial([String? message]) {
    // รหัสผ่านต้องมีตัวอักษร ตัวเลข และอักขระพิเศษ
    return (value) => (value is String && _pwdNumberTextSpecial.hasMatch(value)) ? null : (message ?? Messages.t('password_number_text_special'));
  }

  static Validator passwordLettersWithUppercase([String? message]) {
    // รหัสผ่านเป็นตัวอักษรล้วน และต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว (ห้ามตัวเลขและอักขระพิเศษ)
    return (value) => (value is String && _pwdLettersOnlyWithUpper.hasMatch(value))
        ? null
        : (message ?? Messages.t('password_letters_upper_required', fallback: 'Password must contain letters and at least 1 uppercase'));
  }

  static Validator passwordTextNumberSpecialRequired([String? message]) {
    // รหัสผ่านต้องมีตัวอักษร ตัวเลข และอักขระพิเศษ อย่างละ 1 ตัวขึ้นไป
    return (value) => (value is String && _pwdNumberTextSpecial.hasMatch(value))
        ? null
        : (message ?? Messages.t('password_text_number_special_required', fallback: 'Password must include letter, number and special character'));
  }

  static Validator phone([String? message]) {
    // ตรวจสอบรูปแบบเบอร์โทรศัพท์สากล
    return (value) => (value is String && _phone.hasMatch(value)) ? null : (message ?? Messages.t('phone'));
  }

  static Validator username([String? message]) {
    // ชื่อผู้ใช้: อนุญาต A-Z a-z 0-9 และ _ ความยาว 3-20 ตัว
    return (value) => (value is String && _username.hasMatch(value)) ? null : (message ?? Messages.t('username'));
  }

  static Validator usernameLettersOnly([String? message]) {
    // ชื่อผู้ใช้: ตัวอักษรเท่านั้น (ห้ามตัวเลขและอักขระพิเศษ)
    return (value) => (value is String && _usernameLettersOnly.hasMatch(value))
        ? null
        : (message ?? Messages.t('username_letters_only', fallback: 'Username must contain letters only'));
  }

  static Validator usernameLowercaseOnly([String? message]) {
    // ชื่อผู้ใช้: ตัวอักษรพิมพ์เล็กเท่านั้น (ห้ามตัวเลขและอักขระพิเศษ)
    return (value) => (value is String && _usernameLowercaseOnly.hasMatch(value))
        ? null
        : (message ?? Messages.t('username_lowercase_only', fallback: 'Username must be lowercase letters only'));
  }

  static Validator usernameAlphanumeric([String? message]) {
    // ชื่อผู้ใช้: ตัวอักษรและตัวเลข (ห้ามอักขระพิเศษ)
    return (value) => (value is String && _usernameAlnumOnly.hasMatch(value))
        ? null
        : (message ?? Messages.t('username_alnum_only', fallback: 'Username must be letters or numbers only'));
  }

  static Validator nationalId([String? message]) {
    // ตรวจสอบรหัสบัตรประชาชนไทย 13 หลัก
    return (value) {
      if (value is! String || !_nationalId13.hasMatch(value)) return message ?? Messages.t('national_id', fallback: 'รหัสประชาชนไม่ถูกต้อง');
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        sum += int.parse(value[i]) * (13 - i);
      }
      int check = (11 - (sum % 11)) % 10;
      return check == int.parse(value[12]) ? null : (message ?? Messages.t('national_id', fallback: 'รหัสประชาชนไม่ถูกต้อง'));
    };
  }

  // ===================== Misc/Advanced =====================
  static Validator creditCard([String? message]) {
    // ตรวจสอบหมายเลขบัตรเครดิตด้วยอัลกอริทึม Luhn
    return (value) {
      if (value is! String || value.isEmpty) {
        return null;
      }
      String digits = value.replaceAll(RegExp(r'\D'), '');
      int sum = 0;
      bool alt = false;
      for (int i = digits.length - 1; i >= 0; i--) {
        int n = int.parse(digits[i]);
        if (alt) {
          n *= 2;
          if (n > 9) n -= 9;
        }
        sum += n;
        alt = !alt;
      }
      return sum % 10 == 0 ? null : (message ?? Messages.t('invalid_credit_card'));
    };
  }

  static Validator zipCode([String? message]) {
    // ตรวจสอบรหัสไปรษณีย์ 5 หลัก
    return (value) => (value is String && !_zip5.hasMatch(value)) ? (message ?? Messages.t('invalid_zip_code')) : null;
  }

  static Validator custom(bool Function(dynamic value) test, [String? message]) {
    // ตัวตรวจสอบแบบกำหนดเอง (ส่งฟังก์ชันทดสอบเข้ามา)
    return (value) => test(value) ? null : (message ?? Messages.t('invalid_value', fallback: 'Invalid value'));
  }
}
