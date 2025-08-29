# Design Notes: Large & Conditional Forms

## Large forms (100+ fields)

- Minimize rebuilds: `FormPro` notifies listeners and widgets read the specific field config; avoid rebuilding entire trees.
- Use lazy lists: `ListView.builder` or paginated sections; mount only visible fields.
- Precompile regex and cache i18n (already in package).
- Batch updates: prefer `resetAll()` and avoid frequent `setState` wrappers.
- Measure: profile with Flutter DevTools; watch rebuild counts and frame times.

## Conditional validation

- Today: wrap validators with `Validators.optional([...])` and add your own condition in UI (hide/disable field).
- Near-term pattern: create composite validators that check other values via a closure capturing `form`.

Example:

```dart
final form = FormPro.builder()
	.addField('hasShipping', FormFieldConfig())
	.addField('shippingAddress', FormFieldConfig(validators: [
		(val) {
			final required = form.getValue('hasShipping') == true;
			if (required && (val == null || val.toString().isEmpty)) return 'Required when shipping enabled';
			return null;
		}
	]))
	.build();
```

## Async/network checks

- Use `Validators.async(() async { ... }, pendingMessage: 'Checking...')`.
- Debounce text changes and call `form.validate()` after the future completes.
- Display a small loading indicator in the field decoration if needed.

## Testing

- Add unit tests for validators (happy + edge cases).
- Widget tests: simulate invalid input, run `form.validate()`, expect error text; for async, pump with `tester.pump(const Duration(...))`.
