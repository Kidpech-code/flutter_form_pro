/// i18n utility for FlutterFormPro
library;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// i18n utility for FlutterFormPro (load from assets/i18n/{locale}.json)
class FormProI18n {
  // Default locale if user doesn't set one.
  static const String _defaultLocale = 'th';

  /// Current locale (default: 'th')
  static String _locale = _defaultLocale;

  /// Cache of loaded maps by locale to avoid repeated I/O and JSON parsing.
  static final Map<String, Map<String, String>> _cache = {};

  /// Loaded map for current locale (view into _cache[_locale])
  static Map<String, String> get _map => _cache[_locale] ?? const {};

  /// Set locale (does not load automatically). Prefer [setLocaleAndLoad].
  static void setLocale(String locale) {
    _locale = locale.isNotEmpty ? locale : _defaultLocale;
  }

  /// Get current locale
  static String get locale => _locale;

  /// Ensure there's at least something loaded. If nothing loaded yet, load default.
  static Future<void> ensureLoaded() async {
    if (_cache[_locale] == null) {
      await load(_locale);
    }
  }

  /// Set locale and load its messages (with fallback to default locale).
  static Future<void> setLocaleAndLoad(String locale) async {
    setLocale(locale);
    await load(locale);
  }

  /// Preload a list of locales (silently ignores failures). Useful for apps switching locales at runtime.
  static Future<void> preload(Iterable<String> locales) async {
    await Future.wait(locales.map((l) => load(l)));
  }

  /// Load locale file from assets/i18n/{locale}.json into cache, with fallback to default.
  static Future<void> load([String? locale]) async {
    final l = (locale ?? _locale).isNotEmpty ? (locale ?? _locale) : _defaultLocale;
    if (_cache.containsKey(l)) {
      // Already cached
      _locale = l;
      return;
    }

    Future<Map<String, String>> loadLocale(String loc) async {
      // When used as a dependency, loadString must include the package name prefix.
      final jsonStr = await rootBundle.loadString('packages/flutter_form_pro/assets/i18n/$loc.json');
      return Map<String, String>.from(json.decode(jsonStr));
    }

    try {
      _cache[l] = await loadLocale(l);
      _locale = l;
    } catch (_) {
      // fallback to default locale
      if (l != _defaultLocale) {
        try {
          _cache[_defaultLocale] = _cache[_defaultLocale] ?? await loadLocale(_defaultLocale);
          _locale = _defaultLocale;
        } catch (_) {
          // leave empty map on total failure
          _cache[_defaultLocale] = const {};
          _locale = _defaultLocale;
        }
      } else {
        _cache[_defaultLocale] = const {};
        _locale = _defaultLocale;
      }
    }
  }

  /// Translate key (if not found, return fallback or key)
  static String t(String key, {String? fallback}) {
    final m = _map;
    final v = m[key];
    if (v != null) return v;
    // Built-in fallback for default locale (Thai) when assets are not loaded.
    if (_locale == _defaultLocale) {
      final fb = _builtInThFallback[key];
      if (fb != null) return fb;
    }
    return fallback ?? key;
  }

  /// Add or update key-value for current locale (runtime only)
  static void add(String key, String value) {
    final m = Map<String, String>.from(_map);
    m[key] = value;
    _cache[_locale] = m;
  }

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
  };
}
