import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

void main() {
  testWidgets('FormProTextField binds value and shows error', (tester) async {
    final form = FormPro.builder()
        .addField(
          'email',
          FormFieldConfig(
            validators: [Validators.required(), Validators.email()],
          ),
        )
        .build();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormProWidget(
            form: form,
            onSubmit: (_) {},
            child: const FormProTextField(formFieldName: 'email'),
          ),
        ),
      ),
    );

    // Initially empty, focus and type invalid then valid
    await tester.enterText(find.byType(TextFormField), 'not-email');
    await tester.pumpAndSettle();
    expect(form.getValue('email'), 'not-email');

    // Trigger validation via submit button
    form.validate();
    await tester.pump();
    // Error should be non-null
    expect(form.fields['email']!.error, isNotNull);

    await tester.enterText(find.byType(TextFormField), 'a@b.com');
    await tester.pumpAndSettle();
    form.validate();
    await tester.pump();
    expect(form.fields['email']!.error, isNull);
  });

  testWidgets('FormProKeyboardSubmit triggers submit on Enter', (tester) async {
    Map<String, dynamic>? submitted;
    final form = FormPro.builder()
        .addField(
          'name',
          FormFieldConfig(
            validators: [Validators.required()],
            initialValue: 'Bob',
          ),
        )
        .build();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormProWidget(
            form: form,
            onSubmit: (v) => submitted = v,
            child: const FormProKeyboardSubmit(
              autofocus: true,
              child: Text('content'),
            ),
          ),
        ),
      ),
    );

    // Send enter key
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(submitted, isNotNull);
    expect(submitted!['name'], 'Bob');
  });
}
