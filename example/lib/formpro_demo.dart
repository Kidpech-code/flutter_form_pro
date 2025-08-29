import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';

class FormProFullDemo extends StatefulWidget {
  const FormProFullDemo({super.key});

  @override
  State<FormProFullDemo> createState() => _FormProFullDemoState();
}

class _FormProFullDemoState extends State<FormProFullDemo> with TickerProviderStateMixin {
  late final FormPro _form;
  late final TabController _tabController;
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _controllers = {};
  Timer? _usernameNetDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _form = FormPro.builder()
        // Basic fields
        .addField('email', FormFieldConfig(validators: [Validators.required(), Validators.email()]))
        .addField('username', FormFieldConfig(validators: [Validators.required(), Validators.usernameLettersOnly()]))
        .addField(
          'usernameNet',
          FormFieldConfig(
            validators: [
              Validators.required(),
              Validators.async((value) async {
                await Future.delayed(const Duration(milliseconds: 500));
                final v = (value ?? '').toString();
                if (v.isEmpty) return Messages.t('required');
                // Fake server rule: names containing "taken" are unavailable
                return v.toLowerCase().contains('taken') ? Messages.t('username_taken', fallback: 'Username already taken') : null;
              }, pendingMessage: Messages.t('checking', fallback: 'Checking...')),
            ],
          ),
        )
        .addField('city', FormFieldConfig(validators: [Validators.required()]))
        .addField('amount', FormFieldConfig(validators: [Validators.required(), Validators.isCurrency()]))
        .addField('birthday', FormFieldConfig(validators: [Validators.required(), Validators.date()]))
        // Thai-specific validators
        .addField('thaiPhone', FormFieldConfig(validators: [Validators.isThaiPhone()]))
        .addField('thaiZip', FormFieldConfig(validators: [Validators.isThaiZipCode()]))
        .addField('nationalId', FormFieldConfig(validators: [Validators.nationalId()]))
        // Financial/Security validators
        .addField('creditCard', FormFieldConfig(validators: [Validators.creditCard()]))
        .addField('iban', FormFieldConfig(validators: [Validators.iban()]))
        .addField('strongPassword', FormFieldConfig(validators: [Validators.passwordStrong()], obscureText: true))
        .addField('otp', FormFieldConfig(validators: [Validators.otp()]))
        // Advanced validators
        .addField(
          'isbn',
          FormFieldConfig(
            validators: [
              Validators.optional([Validators.isISBN13()]),
            ],
          ),
        )
        .addField(
          'uuid',
          FormFieldConfig(
            validators: [
              Validators.optional([Validators.isUUIDv4()]),
            ],
          ),
        )
        .addField(
          'hexColor',
          FormFieldConfig(
            validators: [
              Validators.optional([Validators.isHexColor()]),
            ],
          ),
        )
        .build();

    // FocusNodes for focus management
    for (final name in [
      'email',
      'username',
      'usernameNet',
      'city',
      'amount',
      'thaiPhone',
      'thaiZip',
      'nationalId',
      'strongPassword',
      'otp',
      'creditCard',
      'iban',
      'isbn',
      'uuid',
      'hexColor',
    ]) {
      _focusNodes[name] = FocusNode();
    }

    // Controller for async username field + debounce revalidation
    _controllers['usernameNet'] = TextEditingController();
    _controllers['usernameNet']!.addListener(() {
      _usernameNetDebounce?.cancel();
      // Debounce; then trigger form.validate twice to pick up async result
      _usernameNetDebounce = Timer(const Duration(milliseconds: 350), () {
        _form.validate();
        Future.delayed(const Duration(milliseconds: 400), () => _form.validate());
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormPro Full Demo'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => _showValidatorInfo(context)),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetForm),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.text_fields)),
            Tab(text: 'Thai', icon: Icon(Icons.flag)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'Advanced', icon: Icon(Icons.code)),
          ],
        ),
      ),
      body: FormProWidget(
        form: _form,
        onSubmit: (_) => _validateAndSubmit(),
        child: Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildBasicValidatorsTab(), _buildThaiValidatorsTab(), _buildSecurityValidatorsTab(), _buildAdvancedValidatorsTab()],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _validateAndSubmit(),
        icon: const Icon(Icons.check),
        label: const Text('Validate All'),
      ),
    );
  }

  Widget _buildBasicValidatorsTab() {
    // Detect async pending state for usernameNet by checking the pending message
    final form = FormProInheritedWidget.of(context);
    final pendingMsg = Messages.t('checking', fallback: 'Checking...');
    final isUsernameChecking = form.fields['usernameNet']?.error == pendingMsg;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Basic Validators', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDemoSection('Text Input', [
                  FormProTextControllerField(
                    formFieldName: 'email',
                    focusNode: _focusNodes['email'],
                    decoration: const InputDecoration(labelText: 'Email Address', hintText: 'user@example.com', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'username',
                    focusNode: _focusNodes['username'],
                    decoration: const InputDecoration(labelText: 'Username (Letters only)', hintText: 'JohnDoe', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'usernameNet',
                    controller: _controllers['usernameNet'],
                    focusNode: _focusNodes['usernameNet'],
                    decoration: InputDecoration(
                      labelText: 'Username (Async availability)',
                      hintText: 'Type, e.g., myname or taken_user',
                      prefixIcon: const Icon(Icons.person_search),
                      suffixIcon: isUsernameChecking
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: Padding(padding: EdgeInsets.all(2.0), child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'city',
                    focusNode: _focusNodes['city'],
                    decoration: const InputDecoration(labelText: 'City', hintText: 'Bangkok', prefixIcon: Icon(Icons.location_city)),
                  ),
                ]),
                _buildDemoSection('Formatted Input', [
                  FormProTextControllerField(
                    formFieldName: 'amount',
                    focusNode: _focusNodes['amount'],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[\.]?[0-9]*$'))],
                    decoration: const InputDecoration(labelText: 'Amount (Currency)', hintText: '1234.56', prefixIcon: Icon(Icons.attach_money)),
                  ),
                  const SizedBox(height: 12),
                  const FormProDatePickerField(
                    formFieldName: 'birthday',
                    decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)', hintText: '1990-01-01', suffixIcon: Icon(Icons.cake)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThaiValidatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Thai-Specific Validators', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDemoSection('Thai Contact Information', [
                  FormProTextControllerField(
                    formFieldName: 'thaiPhone',
                    focusNode: _focusNodes['thaiPhone'],
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Thai Phone Number', hintText: '0812345678', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'thaiZip',
                    focusNode: _focusNodes['thaiZip'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Thai Postal Code', hintText: '10110', prefixIcon: Icon(Icons.local_post_office)),
                  ),
                ]),
                _buildDemoSection('Thai Government ID', [
                  FormProTextControllerField(
                    formFieldName: 'nationalId',
                    focusNode: _focusNodes['nationalId'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Thai National ID', hintText: '1234567890123', prefixIcon: Icon(Icons.credit_card)),
                  ),
                ]),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ℹ️ Thai Validator Info', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• Phone: Supports mobile (08x, 09x) and some landlines (06x)'),
                        Text('• Postal: 5-digit codes that don\'t start with 0'),
                        Text('• National ID: Uses MOD 11 checksum algorithm'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityValidatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Security & Financial Validators', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDemoSection('Authentication', [
                  FormProTextControllerField(
                    formFieldName: 'strongPassword',
                    focusNode: _focusNodes['strongPassword'],
                    decoration: const InputDecoration(
                      labelText: 'Strong Password',
                      hintText: 'Min 8 chars, upper, lower, digit, symbol',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'otp',
                    focusNode: _focusNodes['otp'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'OTP Code', hintText: '123456', prefixIcon: Icon(Icons.security)),
                  ),
                ]),
                _buildDemoSection('Financial', [
                  FormProTextControllerField(
                    formFieldName: 'creditCard',
                    focusNode: _focusNodes['creditCard'],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Credit Card', hintText: '4111111111111111', prefixIcon: Icon(Icons.credit_card)),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'iban',
                    focusNode: _focusNodes['iban'],
                    decoration: const InputDecoration(
                      labelText: 'IBAN',
                      hintText: 'GB82 WEST 1234 5698 7654 32',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedValidatorsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Advanced Validators', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDemoSection('Format Validators', [
                  FormProTextControllerField(
                    formFieldName: 'isbn',
                    focusNode: _focusNodes['isbn'],
                    decoration: const InputDecoration(labelText: 'ISBN-13 (Optional)', hintText: '978-0134685991', prefixIcon: Icon(Icons.book)),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'uuid',
                    focusNode: _focusNodes['uuid'],
                    decoration: const InputDecoration(
                      labelText: 'UUID v4 (Optional)',
                      hintText: '550e8400-e29b-41d4-a716-446655440000',
                      prefixIcon: Icon(Icons.fingerprint),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FormProTextControllerField(
                    formFieldName: 'hexColor',
                    focusNode: _focusNodes['hexColor'],
                    decoration: const InputDecoration(labelText: 'Hex Color (Optional)', hintText: '#FF5733 or FFF', prefixIcon: Icon(Icons.palette)),
                  ),
                ]),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🚀 Performance Features', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• Pre-compiled RegExp patterns for speed'),
                        Text('• Cached i18n messages'),
                        Text('• Minimal rebuilds with ChangeNotifier'),
                        Text('• Clean Architecture with domain abstraction'),
                      ],
                    ),
                  ),
                ),
                const Card(
                  color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌍 I18n Support',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Supports Thai (default), English, French, Japanese, and Chinese with easy extensibility.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    try {
      final isValid = _form.validate();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid ? '✅ All validations passed!' : '❌ Please fix validation errors'),
          backgroundColor: isValid ? Colors.green : Colors.red,
        ),
      );

      if (isValid) {
        _showSubmissionDialog();
      } else {
        // Focus the first invalid field for better UX/a11y
        for (final entry in _form.fields.entries) {
          if (entry.value.error != null) {
            final node = _focusNodes[entry.key];
            if (node != null) {
              node.requestFocus();
            }
            break;
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error during validation: $e'), backgroundColor: Colors.red));
    }
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Form Submission'),
          content: const Text('In a real app, you would submit the validated data to your backend service here.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _form.resetAll();
              },
              child: const Text('Reset Form'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    _form.resetAll();
  }

  void _showValidatorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('FlutterFormPro Features'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔧 Available Validators:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Basic: required, email, numeric, alpha'),
                Text('• Thai: phone, postal code, national ID'),
                Text('• Security: strong password, OTP, credit card'),
                Text('• Financial: IBAN, currency formatting'),
                Text('• Advanced: ISBN, UUID, hex colors'),
                SizedBox(height: 16),
                Text('🌟 Key Features:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Thai-first internationalization'),
                Text('• Clean Architecture design'),
                Text('• High performance with caching'),
                Text('• Comprehensive error handling'),
                Text('• Easy standalone usage'),
                SizedBox(height: 16),
                Text('📱 Usage:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• FormPro for reactive forms'),
                Text('• Validators.* for standalone use'),
                Text('• FormProTextField for UI widgets'),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        );
      },
    );
  }
}
