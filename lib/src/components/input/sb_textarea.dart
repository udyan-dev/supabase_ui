import 'package:flutter/widgets.dart';

import 'sb_text_field.dart';

/// Multi-line text input. Thin wrapper over [SbTextField] in multiline mode —
/// shares the same token-driven shell, no duplicated styling.
class SbTextArea extends StatelessWidget {
  const SbTextArea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.enabled = true,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SbTextField(
      controller: controller,
      type: SbTextFieldType.multiline,
      label: label,
      hint: hint,
      helper: helper,
      error: error,
      enabled: enabled,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      focusNode: focusNode,
    );
  }
}
