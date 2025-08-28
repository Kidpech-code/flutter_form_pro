import 'package:flutter/foundation.dart';
import 'form_field_config.dart';

class FormPro extends ChangeNotifier {
  final Map<String, FormFieldConfig> _fields;
  final Map<String, dynamic> _values;

  FormPro._(this._fields, this._values);

  static FormProBuilder builder() => FormProBuilder();

  Map<String, dynamic> get values => Map.unmodifiable(_values);
  Map<String, FormFieldConfig> get fields => Map.unmodifiable(_fields);

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
}

class FormProBuilder {
  final Map<String, FormFieldConfig> _fields = {};
  final Map<String, dynamic> _values = {};

  FormProBuilder addField(String name, FormFieldConfig config) {
    _fields[name] = config;
    _values[name] = config.initialValue;
    return this;
  }

  FormPro build() => FormPro._(_fields, _values);
}
