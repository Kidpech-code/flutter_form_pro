# Accessibility (a11y) with Flutter Form Pro

This guide shows how to make forms accessible with semantics, error announcements, and focus management.

## Built-in

- Semantics: `FormProTextField` and controller variant set label/hint/value.
- Live region errors: When a field has an error, a screen reader-friendly announcement is emitted.
- Submit behavior: `FormProWidget` locates the first invalid field on failed submit (hook point for focus).

## Focusing the first invalid field

Use controller field + FocusNode mapping in your page and request focus after validate fails.

Example pattern:

- Keep `Map<String, FocusNode>` keyed by field name.
- After `form.validate()`, if false, find the first `config.error != null` and call `focusNode.requestFocus()`.

## Async validators

- Use `Validators.async(fn, pendingMessage: 'Checking...')` to surface a temporary state.
- Debounce input and re-run `form.validate()` when the async completes to refresh error text.

## Tips

- Keep labels concise and descriptive.
- Use `TextInputType` and input formatters for better virtual keyboard and SR hints.
- Announce page-level errors in a single place (SnackBar or a banner) in addition to per-field errors.
