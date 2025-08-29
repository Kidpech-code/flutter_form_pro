# Migration Guide

## From Other Validator Packages

### From flutter_form_builder

Before:

```dart
FormBuilderTextField(
	name: 'email',
	validator: FormBuilderValidators.compose([
		FormBuilderValidators.required(),
		FormBuilderValidators.email(),
	]),
)
```

After:

```dart
TextFormField(
	validator: Validators.multi([
		Validators.required(),
		Validators.email(),
	]),
)
```

Notes:

- `Validators.multi([...])` returns the first failing message.
- Use `Validators.optional([...])` when the field can be empty but must satisfy rules if provided.

### From form_validator

Before:

```dart
TextFormField(
	validator: ValidationBuilder().required().email().maxLength(64).build(),
)
```

After:

```dart
TextFormField(
	validator: Validators.multi([
		Validators.required(),
		Validators.email(),
		Validators.maxLength(64),
	]),
)
```

### From flutter_form_builder + reactive forms

Replace composite builders with `FormPro` when you need reactive widgets and state:

```dart
final form = FormPro.builder()
	.addField('email', FormFieldConfig(validators: [Validators.required(), Validators.email()]))
	.addField('password', FormFieldConfig(validators: [Validators.required(), Validators.passwordStrong()]))
	.build();
```

### Async validators

Use the adapter:

```dart
final usernameAvailable = Validators.async(
	() async => await api.checkUsername(_usernameController.text),
	pendingMessage: 'Checking...',
	messageWhenFalse: 'Username not available',
);
```

### I18n differences

- Messages are retrieved via `Messages.t(key)` and bridged to `FormProI18n` automatically.
- Set locale with `await FormProI18n.setLocaleAndLoad('th');` (Thai default).
