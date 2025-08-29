import 'package:flutter/material.dart';
import 'formpro_demo.dart';

void main() => runApp(const FormProDemoApp());

class FormProDemoApp extends StatelessWidget {
  const FormProDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFormPro Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const FormProFullDemo(),
    );
  }
}
