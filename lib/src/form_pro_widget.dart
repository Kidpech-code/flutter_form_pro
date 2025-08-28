import 'package:flutter/material.dart';
import 'form_pro.dart';

class FormProWidget extends StatefulWidget {
  final FormPro form;
  final Widget child;
  final void Function(Map<String, dynamic> values) onSubmit;

  const FormProWidget({super.key, required this.form, required this.child, required this.onSubmit});

  @override
  State<FormProWidget> createState() => _FormProWidgetState();
}

// ignore: library_private_types_in_public_api
class _FormProWidgetState extends State<FormProWidget> {
  void submit() {
    if (widget.form.validate()) {
      widget.onSubmit(widget.form.values);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormProInheritedWidget(
      form: widget.form,
      submit: submit,
      child: ListenableBuilder(
        listenable: widget.form,
        builder: (context, _) {
          return Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(children: [widget.child]),
          );
        },
      ),
    );
  }
}

class FormProInheritedWidget extends InheritedWidget {
  final FormPro form;
  final VoidCallback? submit;
  const FormProInheritedWidget({required this.form, this.submit, required super.child, super.key});

  static FormPro of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<FormProInheritedWidget>();
    if (inherited == null) {
      throw Exception('FormProWidget ancestor not found');
    }
    return inherited.form;
  }

  static VoidCallback submitOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<FormProInheritedWidget>();
    if (inherited == null || inherited.submit == null) {
      throw Exception('FormProWidget ancestor with submit not found');
    }
    return inherited.submit!;
  }

  @override
  bool updateShouldNotify(covariant FormProInheritedWidget oldWidget) => form != oldWidget.form;
}
