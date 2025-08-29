import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'form_pro_widget.dart';

/// Material text field bound to a FormPro field by [formFieldName].
///
/// Displays the current value, writes back on change, and shows error text.
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
      child: Semantics(
        textField: true,
        label: decoration?.labelText,
        hint: decoration?.hintText,
        value: form.getValue(formFieldName)?.toString(),
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: ValueKey(form.getValue(formFieldName)),
              initialValue: form.getValue(formFieldName)?.toString(),
              obscureText: config.obscureText,
              decoration: (decoration ?? const InputDecoration()).copyWith(errorText: config.error),
              onChanged: (val) {
                form.setValue(formFieldName, val);
              },
            ),
            if (config.error != null)
              Semantics(
                liveRegion: true,
                label: 'Error: ${config.error}',
                child: ExcludeSemantics(child: SizedBox(height: 0)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Controller-friendly Material text field integrated with FormPro.
/// - Accepts an external controller/focusNode for advanced cursor control
/// - If not provided, creates and disposes its own
/// - Syncs controller.text with FormPro value on rebuild without breaking selection
/// Controller-friendly Material text field bound to FormPro.
///
/// Accepts external controller/focus for advanced cursor control. If omitted,
/// it creates and disposes its own. Keeps controller text in sync with the
/// FormPro value.
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
/// Numeric input field bound to FormPro.
///
/// Supports integers or decimals, with optional sign, via input formatters.
class FormProNumberField extends StatefulWidget {
  final String formFieldName;
  final InputDecoration? decoration;
  final bool allowDecimal;
  final bool signed;

  const FormProNumberField({super.key, required this.formFieldName, this.decoration, this.allowDecimal = true, this.signed = false});

  @override
  State<FormProNumberField> createState() => _FormProNumberFieldState();
}

class _FormProNumberFieldState extends State<FormProNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[widget.formFieldName]!;
    final valueStr = form.getValue(widget.formFieldName)?.toString() ?? '';
    if (_controller.text != valueStr) {
      final newLen = valueStr.length;
      _controller.value = TextEditingValue(
        text: valueStr,
        selection: TextSelection.collapsed(offset: newLen),
      );
    }

    final pattern = widget.allowDecimal
        ? (widget.signed ? RegExp(r'^[+-]?[0-9]*[\.]?[0-9]*$') : RegExp(r'^[0-9]*[\.]?[0-9]*$'))
        : (widget.signed ? RegExp(r'^[+-]?[0-9]*$') : RegExp(r'^[0-9]*$'));

    return TextFormField(
      controller: _controller,
      keyboardType: widget.allowDecimal ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(pattern)],
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(errorText: config.error),
      onChanged: (val) => form.setValue(widget.formFieldName, val),
    );
  }
}

/// Phone input field integrated with FormPro
///
/// - Keyboard type set to [TextInputType.phone]
/// - By default, strips '-' automatically as the user types
/// - You can customize normalization via [normalizer]. If provided, it
///   overrides the default behavior.
class FormProPhoneField extends StatefulWidget {
  final String formFieldName;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  // If provided, overrides built-in normalization.
  final String Function(String)? normalizer;
  // Dial codes to strip from the start (default Thai '+66').
  final List<String> stripDialCodes;
  // If true, when a dial code is stripped, prepend a leading '0' (local format).
  final bool replaceWithLeadingZero;
  // If true, remove common separators like '-' and spaces and parentheses.
  final bool stripSeparators;

  const FormProPhoneField({
    super.key,
    required this.formFieldName,
    this.decoration,
    this.inputFormatters,
    this.normalizer,
    this.stripDialCodes = const ['+66'],
    this.replaceWithLeadingZero = true,
    this.stripSeparators = true,
  });

  @override
  State<FormProPhoneField> createState() => _FormProPhoneFieldState();
}

class _FormProPhoneFieldState extends State<FormProPhoneField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String Function(String) get _normalizer =>
      widget.normalizer ??
      (String s) {
        String t = s;
        if (widget.stripSeparators) {
          t = t.replaceAll(RegExp(r'[\s\-()]'), '');
        }
        for (final code in widget.stripDialCodes) {
          if (code.isEmpty) continue;
          if (t.startsWith(code)) {
            final rest = t.substring(code.length);
            if (widget.replaceWithLeadingZero) {
              // Avoid duplicate leading zero if already present.
              t = rest.startsWith('0') ? rest : '0$rest';
            } else {
              t = rest;
            }
            break;
          }
        }
        return t;
      };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = FormProInheritedWidget.of(context);
    final config = form.fields[widget.formFieldName]!;
    final valueStr = form.getValue(widget.formFieldName)?.toString() ?? '';

    // Sync controller text from form value without breaking caret too much.
    if (_controller.text != valueStr) {
      final newLen = valueStr.length;
      _controller.value = TextEditingValue(
        text: valueStr,
        selection: TextSelection.collapsed(offset: newLen),
      );
    }

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: widget.inputFormatters,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(errorText: config.error),
      onChanged: (val) {
        final selection = _controller.selection.baseOffset;
        // Normalize both the full string and the substring before caret
        final before = selection >= 0 && selection <= val.length ? val.substring(0, selection) : val;
        final normalized = _normalizer(val);
        final beforeNorm = _normalizer(before);
        final newIndex = beforeNorm.length.clamp(0, normalized.length);

        if (normalized != val) {
          _controller.value = TextEditingValue(
            text: normalized,
            selection: TextSelection.collapsed(offset: newIndex),
          );
        }
        form.setValue(widget.formFieldName, normalized);
      },
    );
  }
}

/// Date picker field bound to FormPro.
///
/// Stores value as `YYYY-MM-DD` string. For tests or custom UX, you can inject
/// a custom [pickDate] function; by default it uses [showDatePicker].
class FormProDatePickerField extends StatelessWidget {
  final String formFieldName;
  final InputDecoration? decoration;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final Locale? locale;

  /// Optional custom date picker function for testing or custom dialogs.
  final Future<DateTime?> Function(BuildContext context, DateTime initialDate, DateTime firstDate, DateTime lastDate, Locale? locale)? pickDate;

  const FormProDatePickerField({
    super.key,
    required this.formFieldName,
    this.decoration,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.locale,
    this.pickDate,
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
        final init = initialDate ?? parsed ?? now;
        final first = firstDate ?? DateTime(now.year - 100);
        final last = lastDate ?? DateTime(now.year + 100);
        DateTime? picked;
        if (pickDate != null) {
          picked = await pickDate!(context, init, first, last, locale);
        } else {
          picked = await showDatePicker(context: context, initialDate: init, firstDate: first, lastDate: last, locale: locale);
        }
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
/// Material Autocomplete bound to FormPro. Generic type parameter `T` is
/// displayed via [displayStringForOption].
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
/// Cupertino text field bound to FormPro.
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
/// Keyboard submit wrapper; calls FormPro submit on Enter/NumpadEnter.
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
