import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

void main() {
  test('Validators.required returns error on empty', () {
    final v = Validators.required();
    expect(v(''), isNotNull);
  });

  test('Validators.email validates format', () {
    final v = Validators.email();
    expect(v('not-an-email'), isNotNull);
    expect(v('a@b.com'), isNull);
  });
}
