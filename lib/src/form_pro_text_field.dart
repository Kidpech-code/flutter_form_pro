import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'form_pro_widget.dart';

class FormProTextField extends StatelessWidget {
  final String formFieldName;
  final InputDecoration? decoration;

  const FormProTextField({super.key, required this.formFieldName, this.decoration});

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: TextFormField(
        key: ValueKey(form.getValue(formFieldName)),
        initialValue: form.getValue(formFieldName)?.toString(),
        obscureText: config.obscureText,
        decoration: (decoration ?? const InputDecoration()).copyWith(errorText: config.error),
        onChanged: (val) {
          form.setValue(formFieldName, val);
        },
      ),
    );
  }
}

/// Controller-friendly Material text field integrated with FormPro.
/// - Accepts an external controller/focusNode for advanced cursor control
/// - If not provided, creates and disposes its own
/// - Syncs controller.text with FormPro value on rebuild without breaking selection
class FormProTextControllerField extends StatefulWidget {
  final String formFieldName;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final bool preserveSelection;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const FormProTextControllerField({
    super.key,
    required this.formFieldName,
    this.controller,
    this.focusNode,
    this.decoration,
    this.preserveSelection = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  @override
  State<FormProTextControllerField> createState() => _FormProTextControllerFieldState();
}

class _FormProTextControllerFieldState extends State<FormProTextControllerField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[widget.formFieldName]!;
    final valueStr = form.getValue(widget.formFieldName)?.toString() ?? '';

    // Keep controller text in sync with form value without losing selection.
    if (_controller.text != valueStr) {
      if (widget.preserveSelection) {
        final newLen = valueStr.length;
        _controller.value = TextEditingValue(
          text: valueStr,
          selection: TextSelection.collapsed(offset: newLen),
        );
      } else {
        _controller.text = valueStr;
      }
    }

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      obscureText: config.obscureText,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(errorText: config.error),
      onChanged: (val) => form.setValue(widget.formFieldName, val),
    );
  }
}

/// Numeric input field integrated with FormPro
class FormProNumberField extends StatelessWidget {
  final String formFieldName;
  final InputDecoration? decoration;
  final bool allowDecimal;
  final bool signed;

  const FormProNumberField({super.key, required this.formFieldName, this.decoration, this.allowDecimal = true, this.signed = false});

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    final pattern = allowDecimal
        ? (signed ? RegExp(r'^[+-]?[0-9]*[\.]?[0-9]*$') : RegExp(r'^[0-9]*[\.]?[0-9]*$'))
        : (signed ? RegExp(r'^[+-]?[0-9]*$') : RegExp(r'^[0-9]*$'));
    return TextFormField(
      key: ValueKey(form.getValue(formFieldName)),
      initialValue: form.getValue(formFieldName)?.toString(),
      keyboardType: allowDecimal ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(pattern)],
      decoration: (decoration ?? const InputDecoration()).copyWith(errorText: config.error),
      onChanged: (val) => form.setValue(formFieldName, val),
    );
  }
}

/// Date picker field integrated with FormPro. Stores value as YYYY-MM-DD string.
class FormProDatePickerField extends StatelessWidget {
  final String formFieldName;
  final InputDecoration? decoration;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final Locale? locale;

  const FormProDatePickerField({
    super.key,
    required this.formFieldName,
    this.decoration,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    final text = form.getValue(formFieldName)?.toString();
    return TextFormField(
      controller: TextEditingController(text: text ?? ''),
      readOnly: true,
      decoration: (decoration ?? const InputDecoration()).copyWith(errorText: config.error, suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final now = DateTime.now();
        final parsed = _tryParseYmd(text);
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? parsed ?? now,
          firstDate: firstDate ?? DateTime(now.year - 100),
          lastDate: lastDate ?? DateTime(now.year + 100),
          locale: locale,
        );
        if (picked != null) {
          final ymd = _formatYmd(picked);
          form.setValue(formFieldName, ymd);
        }
      },
    );
  }

  static DateTime? _tryParseYmd(String? v) {
    if (v == null || v.length < 10) return null;
    try {
      final p = DateTime.parse(v.substring(0, 10));
      return p;
    } catch (_) {
      return null;
    }
  }

  static String _formatYmd(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

/// Material Autocomplete field integrated with FormPro
class FormProAutocomplete<T extends Object> extends StatelessWidget {
  final String formFieldName;
  final Iterable<T> Function(TextEditingValue text) optionsBuilder;
  final String Function(T option) displayStringForOption;
  final InputDecoration? decoration;

  const FormProAutocomplete({
    super.key,
    required this.formFieldName,
    required this.optionsBuilder,
    required this.displayStringForOption,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    final initial = form.getValue(formFieldName)?.toString() ?? '';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Autocomplete<T>(
        initialValue: TextEditingValue(text: initial),
        optionsBuilder: optionsBuilder,
        displayStringForOption: displayStringForOption,
        fieldViewBuilder: (ctx, textController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: textController,
            focusNode: focusNode,
            decoration: (decoration ?? const InputDecoration()).copyWith(errorText: config.error),
            onChanged: (val) => form.setValue(formFieldName, val),
            onFieldSubmitted: (_) => onFieldSubmitted(),
          );
        },
        onSelected: (T option) => form.setValue(formFieldName, option),
      ),
    );
  }
}

/// Cupertino TextField integrated with FormPro
class FormProCupertinoTextField extends StatelessWidget {
  final String formFieldName;
  final String? placeholder;

  const FormProCupertinoTextField({super.key, required this.formFieldName, this.placeholder});

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[formFieldName]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoTextFormFieldRow(
          initialValue: form.getValue(formFieldName)?.toString() ?? '',
          placeholder: placeholder,
          obscureText: config.obscureText,
          onChanged: (val) => form.setValue(formFieldName, val),
        ),
        if (config.error != null) ...[
          const SizedBox(height: 6),
          Text(config.error!, style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12)),
        ],
      ],
    );
  }
}

/// KeyboardListener wrapper to submit on Enter (desktop/web)
class FormProKeyboardSubmit extends StatelessWidget {
  final Widget child;
  final Set<LogicalKeyboardKey>? triggerKeys;
  final bool autofocus;

  const FormProKeyboardSubmit({super.key, required this.child, this.triggerKeys, this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    final submit = FormProInheritedWidget.submitOf(context);
    final keys = triggerKeys ?? {LogicalKeyboardKey.enter, LogicalKeyboardKey.numpadEnter};
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: autofocus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && keys.contains(event.logicalKey)) {
          submit();
        }
      },
      child: child,
    );
  }
}
