import 'package:flutter/widgets.dart';

import '../theme/sb_theme_extensions.dart';
import '../tokens/sb_typography.dart';
import '../utils/context_extensions.dart';

/// The typed text scale. Each variant maps to one `SbTypography` style.
enum SbTextVariant { display, heading, title, body, bodyStrong, caption, mono }

/// The only text primitive. Style is chosen by [variant]; color by [role].
///
/// No inline `TextStyle` is ever passed — callers pick a token variant and a
/// semantic color role, keeping styling fully token-driven.
class SbText extends StatelessWidget {
  const SbText(
    this.data, {
    super.key,
    this.variant = SbTextVariant.body,
    this.role = SbColorRole.textPrimary,
    this.align,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  // Ergonomic named constructors.
  const SbText.display(this.data,
      {super.key,
      this.role = SbColorRole.textPrimary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.display;
  const SbText.heading(this.data,
      {super.key,
      this.role = SbColorRole.textPrimary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.heading;
  const SbText.title(this.data,
      {super.key,
      this.role = SbColorRole.textPrimary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.title;
  const SbText.body(this.data,
      {super.key,
      this.role = SbColorRole.textPrimary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.body;
  const SbText.caption(this.data,
      {super.key,
      this.role = SbColorRole.textSecondary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.caption;
  const SbText.mono(this.data,
      {super.key,
      this.role = SbColorRole.textPrimary,
      this.align,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : variant = SbTextVariant.mono;

  final String data;
  final SbTextVariant variant;
  final SbColorRole role;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  static TextStyle _baseStyle(SbTextVariant variant) {
    switch (variant) {
      case SbTextVariant.display:
        return SbTypography.display;
      case SbTextVariant.heading:
        return SbTypography.heading;
      case SbTextVariant.title:
        return SbTypography.title;
      case SbTextVariant.body:
        return SbTypography.body;
      case SbTextVariant.bodyStrong:
        return SbTypography.bodyStrong;
      case SbTextVariant.caption:
        return SbTypography.caption;
      case SbTextVariant.mono:
        return SbTypography.mono;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.sbColors.resolve(role);
    return Text(
      data,
      style: _baseStyle(variant).copyWith(color: color),
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
