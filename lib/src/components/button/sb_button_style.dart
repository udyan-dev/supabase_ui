import 'package:flutter/widgets.dart';

import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../tokens/sb_typography.dart';

enum SbButtonVariant { primary, secondary, outline, ghost, destructive }

enum SbButtonSize { sm, md, lg }

/// Resolved visual spec for a button at a given variant/size/state. Pure data;
/// computed once per build with no allocation beyond the record itself.
@immutable
class SbButtonVisual {
  const SbButtonVisual({
    required this.background,
    required this.foreground,
    required this.borderColor,
  });

  final Color? background;
  final Color foreground;
  final Color? borderColor;
}

extension SbButtonSizeMetrics on SbButtonSize {
  EdgeInsets get padding {
    switch (this) {
      case SbButtonSize.sm:
        return const EdgeInsets.symmetric(
            horizontal: SbSpacing.s12, vertical: SbSpacing.s8);
      case SbButtonSize.md:
        return const EdgeInsets.symmetric(
            horizontal: SbSpacing.s16, vertical: SbSpacing.s12);
      case SbButtonSize.lg:
        return const EdgeInsets.symmetric(
            horizontal: SbSpacing.s20, vertical: SbSpacing.s16);
    }
  }

  double get minHeight {
    switch (this) {
      case SbButtonSize.sm:
        return 32;
      case SbButtonSize.md:
        return 40;
      case SbButtonSize.lg:
        return 48;
    }
  }

  double get iconSize {
    switch (this) {
      case SbButtonSize.sm:
        return 14;
      case SbButtonSize.md:
        return 16;
      case SbButtonSize.lg:
        return 18;
    }
  }

  TextStyle get textStyle {
    switch (this) {
      case SbButtonSize.sm:
        return SbTypography.caption.copyWith(fontWeight: FontWeight.w500);
      case SbButtonSize.md:
        return SbTypography.bodyStrong;
      case SbButtonSize.lg:
        return SbTypography.title;
    }
  }

  BorderRadius get radius => SbRadius.all8;
}

/// Resolves the [SbButtonVisual] for the given inputs. Single source of button
/// color logic, shared by every button instance.
SbButtonVisual resolveButtonVisual({
  required SbButtonVariant variant,
  required SbColorScheme colors,
  required bool hovered,
  required bool pressed,
  required bool disabled,
}) {
  if (disabled) {
    switch (variant) {
      case SbButtonVariant.primary:
      case SbButtonVariant.destructive:
        return SbButtonVisual(
          background: colors.surfaceActive,
          foreground: colors.textTertiary,
          borderColor: null,
        );
      case SbButtonVariant.secondary:
      case SbButtonVariant.outline:
        return SbButtonVisual(
          background: null,
          foreground: colors.textTertiary,
          borderColor: colors.border,
        );
      case SbButtonVariant.ghost:
        return SbButtonVisual(
          background: null,
          foreground: colors.textTertiary,
          borderColor: null,
        );
    }
  }

  switch (variant) {
    case SbButtonVariant.primary:
      return SbButtonVisual(
        background: pressed
            ? colors.primaryActive
            : (hovered ? colors.primaryHover : colors.primary),
        foreground: colors.onPrimary,
        borderColor: null,
      );
    case SbButtonVariant.destructive:
      return SbButtonVisual(
        background: pressed
            ? Color.alphaBlend(const Color(0x33000000), colors.destructive)
            : (hovered
                ? Color.alphaBlend(const Color(0x1A000000), colors.destructive)
                : colors.destructive),
        foreground: colors.onSemantic,
        borderColor: null,
      );
    case SbButtonVariant.secondary:
      return SbButtonVisual(
        background: pressed
            ? colors.surfaceActive
            : (hovered ? colors.surfaceHover : colors.surface),
        foreground: colors.textPrimary,
        borderColor: colors.border,
      );
    case SbButtonVariant.outline:
      return SbButtonVisual(
        background: pressed
            ? colors.surfaceActive
            : (hovered ? colors.surfaceHover : null),
        foreground: colors.textPrimary,
        borderColor: colors.borderStrong,
      );
    case SbButtonVariant.ghost:
      return SbButtonVisual(
        background: pressed
            ? colors.surfaceActive
            : (hovered ? colors.surfaceHover : null),
        foreground: colors.textPrimary,
        borderColor: null,
      );
  }
}
