import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

void main() {
  testWidgets(
    'FormProNumberField accepts only numbers by formatter and binds value',
    (tester) async {
      final form = FormPro.builder()
          .addField(
            'amount',
            FormFieldConfig(validators: [Validators.required()]),
          )
          .build();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormProWidget(
              form: form,
              onSubmit: (_) {},
              child: const FormProNumberField(formFieldName: 'amount'),
            ),
          ),
        ),
      );

      final finder = find.byType(TextFormField);
      // First type a valid numeric substring
      await tester.enterText(finder, '12');
      await tester.pumpAndSettle();
      var val = form.getValue('amount') as String?;
      expect(val, isNotNull);
      expect(val, '12');

      // Now try to insert invalid chars; formatter should prevent adding them
      await tester.enterText(finder, '12a3');
      await tester.pumpAndSettle();
      val = form.getValue('amount') as String?;
      expect(val, isNotNull);
      expect(RegExp(r'^[0-9.]*$').hasMatch(val!), isTrue);
    },
  );

  testWidgets(
    'FormProDatePickerField writes picked date (YYYY-MM-DD) via injected picker',
    (tester) async {
      final form = FormPro.builder()
          .addField(
            'birthday',
            FormFieldConfig(validators: [Validators.required()]),
          )
          .build();

      DateTime? receivedInit;
      final pickedDate = DateTime(2024, 1, 15);

      Future<DateTime?> picker(
        BuildContext context,
        DateTime init,
        DateTime first,
        DateTime last,
        Locale? locale,
      ) async {
        receivedInit = init;
        return pickedDate;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormProWidget(
              form: form,
              onSubmit: (_) {},
              child: FormProDatePickerField(
                formFieldName: 'birthday',
                decoration: const InputDecoration(labelText: 'Birthday'),
                pickDate: picker,
              ),
            ),
          ),
        ),
      );

      // Tap to open (simulate) and pick date via injected picker
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      expect(receivedInit, isNotNull);
      expect(form.getValue('birthday'), '2024-01-15');
    },
  );
}
