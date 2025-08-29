## 0.0.5

Fixes:

- Style: Applied `dart format` to align with pub.dev formatter checks.

## 0.0.4

Improvements:

- Style: Fixed analyzer lints (curly_braces_in_flow_control_structures) across `validators.dart` to satisfy pana/pub points.
- Quality: `flutter analyze` now reports zero issues; test suite unchanged and passing.

## 0.0.3

Fixes & housekeeping:

- CI: Fix Flutter setup by switching to `channel: stable` in GitHub Actions.
- Style: Ran `dart format` across the repo to satisfy pub.dev (pana) formatting checks.

## 0.0.2

Improvements:

- Docs: Polished README (features, widgets, troubleshooting, pub points checklist)
- Tests: Added widget tests for number and date picker (deterministic via injectable picker)
- API: FormProDatePickerField now accepts optional `pickDate` for testing/custom dialogs
- Docs: Added dartdoc to key widgets (FormProWidget, FormProSubmitButton, FormProField)
- Publish: Added `doc/` (pub layout), screenshots metadata, async validator demo + a11y spinner, README links to docs

## 0.0.1

Initial release:

- Thai-first i18n with JSON assets and built-in Thai fallbacks
- Extensive Validators usable standalone or via FormPro widgets
- Reactive form core (FormPro) with high-performance rebuilds
- Material/Cupertino fields, Autocomplete, Keyboard submit
- Controller-friendly text field, number field, date picker field
- Example app and widget/unit tests
