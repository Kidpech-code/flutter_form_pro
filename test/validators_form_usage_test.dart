import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

void main() {
  testWidgets('Validators can be used standalone with TextFormField', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Form(
            key: key,
            child: TextFormField(validator: Validators.multi([Validators.required(), Validators.email()])),
          ),
        ),
      ),
    );

    // Empty: required should fail
    expect(key.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextFormField), 'not-email');
    await tester.pumpAndSettle();
    expect(key.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextFormField), 'a@b.com');
    await tester.pumpAndSettle();
    expect(key.currentState!.validate(), isTrue);
  });

  test('Validators i18n works without explicit load (Thai fallback)', () {
    final v = Validators.required();
    final msg = v('');
    expect(msg, isNotNull);
    // Expect a non-empty Thai fallback string when not loaded explicitly.
    expect(msg!.isNotEmpty, isTrue);
  });
}
