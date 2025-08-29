import 'package:flutter/foundation.dart';
import 'form_field_config.dart';

/// FormPro
///
/// Lightweight, reactive form state container.
/// - Holds field configs and current values
/// - Validates on demand and notifies listeners for efficient UI rebuilds
class FormPro extends ChangeNotifier {
  final Map<String, FormFieldConfig> _fields;
  final Map<String, dynamic> _values;

  FormPro._(this._fields, this._values);

  /// Create a [FormProBuilder] for declarative field registration.
  static FormProBuilder builder() => FormProBuilder();

  Map<String, dynamic> get values => Map.unmodifiable(_values);
  Map<String, FormFieldConfig> get fields => Map.unmodifiable(_fields);

  /// Validate all registered fields. Updates each field's error and
  /// notifies listeners. Returns true when the form is valid.
  bool validate() {
    bool isValid = true;
    _fields.forEach((name, config) {
      final value = _values[name];
      final error = config.validate(value);
      config.error = error;
      if (error != null) isValid = false;
    });
    // แจ้งเตือนให้ widget ที่ฟังอยู่รีเฟรช
    notifyListeners();
    return isValid;
  }

  void setValue(String name, dynamic value) {
    _values[name] = value;
    _fields[name]?.error = _fields[name]?.validate(value);
    // รีเฟรชเฉพาะผู้ฟัง แทนการ setState ทั้งหน้าจอ
    notifyListeners();
  }

  dynamic getValue(String name) => _values[name];

  /// Reset all field values back to their initial values and clear errors.
  /// Notifies listeners once after all values are reset.
  void resetAll() {
    _fields.forEach((name, config) {
      _values[name] = config.initialValue;
      config.error = null;
    });
    notifyListeners();
  }
}

/// Fluent builder for constructing a [FormPro] instance.
class FormProBuilder {
  final Map<String, FormFieldConfig> _fields = {};
  final Map<String, dynamic> _values = {};

  /// Register a field with [name] and its [config].
  FormProBuilder addField(String name, FormFieldConfig config) {
    _fields[name] = config;
    _values[name] = config.initialValue;
    return this;
  }

  /// Build the immutable [FormPro] model.
  FormPro build() => FormPro._(_fields, _values);
}
