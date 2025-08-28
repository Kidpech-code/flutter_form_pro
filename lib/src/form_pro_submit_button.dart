import 'package:flutter/material.dart';
import 'form_pro_widget.dart';

class FormProSubmitButton extends StatelessWidget {
  final Widget child;

  const FormProSubmitButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final submit = FormProInheritedWidget.submitOf(context);
    return ElevatedButton(onPressed: submit, child: child);
  }
}
