import 'package:flutter/widgets.dart';
import 'form_pro_widget.dart';

/// A high-performance, fully customizable field widget bound to FormPro.
///
/// - Rebuilds when the parent [FormProWidget] notifies
/// - Provides current value, error, and an [onChanged] callback
class FormProField<T> extends StatelessWidget {
  final String name;
  final Widget Function(BuildContext context, T? value, String? error, void Function(T? value) onChanged) builder;

  const FormProField({super.key, required this.name, required this.builder});

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    return Builder(
      builder: (context) {
        final value = form.getValue(name) as T?;
        final error = form.fields[name]?.error;
        return builder(context, value, error, (val) => form.setValue(name, val));
      },
    );
  }
}
