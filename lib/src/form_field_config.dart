typedef Validator = String? Function(dynamic value);

class FormFieldConfig {
  final List<Validator> validators;
  final dynamic initialValue;
  final bool obscureText;
  String? error;

  FormFieldConfig({required this.validators, this.initialValue, this.obscureText = false});

  String? validate(dynamic value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
