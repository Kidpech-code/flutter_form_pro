import 'package:flutter/material.dart';
import 'form_pro_widget.dart';

/// ตัวอย่าง Custom Field ที่เชื่อมต่อกับระบบฟอร์มอัตโนมัติ
class FormProCustomField extends StatelessWidget {
  final String formFieldName;
  final Widget Function(
    BuildContext context,
    dynamic value,
    String? error,
    void Function(dynamic) onChanged,
  )
  builder;

  const FormProCustomField({
    super.key,
    required this.formFieldName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: builder(
        context,
        form.getValue(formFieldName),
        config.error,
        (val) => form.setValue(formFieldName, val),
      ),
    );
  }
}
