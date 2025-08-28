import 'package:flutter/material.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

class FormProFullDemo extends StatefulWidget {
  const FormProFullDemo({super.key});

  @override
  State<FormProFullDemo> createState() => _FormProFullDemoState();
}

class _FormProFullDemoState extends State<FormProFullDemo> {
  late final FormPro _form;

  @override
  void initState() {
    super.initState();
    _form = FormPro.builder()
        .addField('email', FormFieldConfig(validators: [Validators.required(), Validators.email()]))
        .addField('username', FormFieldConfig(validators: [Validators.required(), Validators.usernameLettersOnly()]))
        .addField('city', FormFieldConfig(validators: [Validators.required()]))
        .addField('amount', FormFieldConfig(validators: [Validators.required(), Validators.isCurrency()]))
        .addField('birthday', FormFieldConfig(validators: [Validators.required(), Validators.date()]))
        .build();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormPro Full Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FormProWidget(
          form: _form,
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitted: ${values.toString()}')));
          },
          child: FormProKeyboardSubmit(
            autofocus: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Material text field using initialValue
                const FormProTextField(
                  formFieldName: 'email',
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                // Controller-friendly text field
                const FormProTextControllerField(
                  formFieldName: 'username',
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                // Fully custom field with builder
                FormProField<String>(
                  name: 'username',
                  builder: (ctx, value, error, onChanged) => TextField(
                    decoration: InputDecoration(labelText: 'Custom Username', errorText: error),
                    controller: TextEditingController(text: value ?? ''),
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(height: 12),
                // Numbers only (amount)
                const FormProNumberField(
                  formFieldName: 'amount',
                  decoration: InputDecoration(labelText: 'Amount'),
                  allowDecimal: true,
                  signed: false,
                ),
                const SizedBox(height: 12),
                // Date picker stored as YYYY-MM-DD
                const FormProDatePickerField(
                  formFieldName: 'birthday',
                  decoration: InputDecoration(labelText: 'Birthday'),
                ),
                const SizedBox(height: 20),
                // Autocomplete example
                FormProAutocomplete<String>(
                  formFieldName: 'city',
                  optionsBuilder: (text) {
                    const cities = <String>{'Bangkok', 'Chiang Mai', 'Phuket', 'Khon Kaen'};
                    final q = text.text.toLowerCase();
                    return cities.where((c) => c.toLowerCase().contains(q));
                  },
                  displayStringForOption: (s) => s,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                const SizedBox(height: 20),
                FormProSubmitButton(child: const Text('Submit (Enter also works)')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
