import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../tokens/sb_typography.dart';
import '../../utils/context_extensions.dart';

enum SbTextFieldType { text, password, email, number, multiline }

/// Token-driven text input built on the framework's [EditableText] editing
/// primitive (no Material decoration). Provides label / hint / helper / error /
/// prefix / suffix and an animated focus ring. Reused by `SbTextArea`.
class SbTextField extends StatefulWidget {
  const SbTextField({
    super.key,
    this.controller,
    this.type = SbTextFieldType.text,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final SbTextFieldType type;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final bool autofocus;

  @override
  State<SbTextField> createState() => _SbTextFieldState();
}

class _SbTextFieldState extends State<SbTextField> {
  late FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _focused = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(SbTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChange);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  void _onTextChange() {
    // Only the empty/non-empty transition affects the hint overlay.
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChange);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  bool get _isPassword => widget.type == SbTextFieldType.password;
  bool get _isMultiline => widget.type == SbTextFieldType.multiline;

  TextInputType get _keyboardType {
    switch (widget.type) {
      case SbTextFieldType.email:
        return TextInputType.emailAddress;
      case SbTextFieldType.number:
        return TextInputType.number;
      case SbTextFieldType.multiline:
        return TextInputType.multiline;
      case SbTextFieldType.text:
      case SbTextFieldType.password:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final hasError = widget.error != null;
    final borderColor = hasError
        ? colors.destructive
        : (_focused ? colors.primary : colors.border);
    final editable = TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: colors.primary.withValues(alpha: 0.25),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        textAlign: widget.textAlign,
        readOnly: !widget.enabled,
        obscureText: _isPassword && _obscured,
        keyboardType: _keyboardType,
        textInputAction: _isMultiline
            ? TextInputAction.newline
            : TextInputAction.done,
        maxLines: _isMultiline ? widget.maxLines : 1,
        minLines: _isMultiline ? widget.minLines : 1,
        style: SbTypography.body.copyWith(color: colors.textPrimary),
        cursorColor: colors.primary,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.type == SbTextFieldType.number
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: const InputDecoration.collapsed(hintText: null),
      ),
    );

    final field = widget.hint != null
        ? Stack(
            children: <Widget>[
              editable,
              Positioned.fill(
                child: IgnorePointer(
                  child: Visibility(
                    visible: _controller.text.isEmpty,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SbText.body(
                        widget.hint!,
                        role: SbColorRole.textTertiary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : editable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...[
          SbText(widget.label!, variant: SbTextVariant.bodyStrong),
          const SizedBox(height: SbSpacing.s8),
        ],
        AnimatedContainer(
          duration: SbMotion.fast,
          decoration: BoxDecoration(
            color: widget.enabled ? colors.surface : colors.surfaceActive,
            borderRadius: SbRadius.all8,
            border: Border.all(
              color: borderColor,
              width: _focused || hasError ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s12,
            vertical: SbSpacing.s12,
          ),
          child: Row(
            children: <Widget>[
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: SbSpacing.s8),
              ],
              Expanded(child: field),
              if (_isPassword)
                SbInteraction(
                  onTap: () => setState(() => _obscured = !_obscured),
                  builder: (context, _, _) => Padding(
                    padding: const EdgeInsets.only(left: SbSpacing.s8),
                    child: SbText.caption(_obscured ? 'Show' : 'Hide'),
                  ),
                )
              else if (widget.suffix != null) ...[
                const SizedBox(width: SbSpacing.s8),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: SbSpacing.s4),
          SbText.caption(widget.error!, role: SbColorRole.destructive),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: SbSpacing.s4),
          SbText.caption(widget.helper!, role: SbColorRole.textTertiary),
        ],
      ],
    );
  }
}
