import 'package:flutter/material.dart';
import 'package:flutter_form_pro/flutter_form_pro.dart';
import 'formpro_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Default is 'th'; we explicitly set for demo clarity.
  await FormProI18n.setLocaleAndLoad('th');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FlutterFormPro Example',
    routes: {'/': (_) => const DemoPage(), '/formpro': (_) => const FormProFullDemo()},
    initialRoute: '/',
  );
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterFormPro Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Open FormPro full demo',
            onPressed: () => Navigator.of(context).pushNamed('/formpro'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => _email = v,
                validator: Validators.multi([Validators.required(), Validators.email(), Validators.maxLength(64)]),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username (letters only)'),
                onChanged: (v) => _username = v,
                validator: Validators.usernameLettersOnly(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final ok = _formKey.currentState!.validate();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Valid' : 'Invalid')));
                    },
                    child: const Text('Validate'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await FormProI18n.setLocaleAndLoad('en');
                      setState(() {});
                    },
                    child: const Text('EN'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await FormProI18n.setLocaleAndLoad('th');
                      setState(() {});
                    },
                    child: const Text('TH'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Current email: $_email'),
              Text('Current username: $_username'),
            ],
          ),
        ),
      ),
    );
  }
}
