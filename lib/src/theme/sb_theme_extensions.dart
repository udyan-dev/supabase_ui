import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Resolved, brightness-specific color *roles*.
///
/// This is the only place raw palette values are mapped to semantic roles.
/// Components and primitives read roles from here (via `context.sb.colors`) and
/// never touch `SbColors` directly.
@immutable
class SbColorScheme {
  const SbColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.onPrimary,
    required this.warning,
    required this.destructive,
    required this.onSemantic,
    required this.overlay,
    required this.backgroundSelection,
    required this.icon,
  });

  /// App backdrop (scaffold).
  final Color background;

  /// Raised container fill.
  final Color surface;
  final Color surfaceHover;
  final Color surfaceActive;

  /// Hairline border.
  final Color border;
  final Color borderStrong;

  /// Text on [surface] / [background].
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// Text drawn over filled (primary/semantic) backgrounds.
  final Color textInverse;

  /// Brand.
  final Color primary;
  final Color primaryHover;
  final Color primaryActive;
  final Color onPrimary;

  /// Semantic accents. Supabase's model: positive/success uses the brand
  /// ([primary]); the only dedicated non-brand semantics are warning and
  /// destructive.
  final Color warning;
  final Color destructive;

  /// Foreground over a filled semantic background.
  final Color onSemantic;

  /// Modal / scrim overlay.
  final Color overlay;

  /// Selection highlight
  final Color backgroundSelection;

  /// Icon Color
  final Color icon;

  static SbColorScheme lerp(SbColorScheme a, SbColorScheme b, double t) {
    return SbColorScheme(
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceHover: Color.lerp(a.surfaceHover, b.surfaceHover, t)!,
      surfaceActive: Color.lerp(a.surfaceActive, b.surfaceActive, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
      textInverse: Color.lerp(a.textInverse, b.textInverse, t)!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      primaryHover: Color.lerp(a.primaryHover, b.primaryHover, t)!,
      primaryActive: Color.lerp(a.primaryActive, b.primaryActive, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      destructive: Color.lerp(a.destructive, b.destructive, t)!,
      onSemantic: Color.lerp(a.onSemantic, b.onSemantic, t)!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      backgroundSelection: Color.lerp(
        a.backgroundSelection,
        b.backgroundSelection,
        t,
      )!,
      icon: Color.lerp(a.icon, b.icon, t)!,
    );
  }
}

/// Named color roles addressable at runtime (used by `SbText` / `SbSurface`
/// so callers pick a role without referencing concrete colors).
enum SbColorRole {
  textPrimary,
  textSecondary,
  textTertiary,
  textInverse,
  primary,
  onPrimary,
  warning,
  destructive,
  surface,
  background,
  border,
}

extension SbColorRoleResolver on SbColorScheme {
  Color resolve(SbColorRole role) {
    switch (role) {
      case SbColorRole.textPrimary:
        return textPrimary;
      case SbColorRole.textSecondary:
        return textSecondary;
      case SbColorRole.textTertiary:
        return textTertiary;
      case SbColorRole.textInverse:
        return textInverse;
      case SbColorRole.primary:
        return primary;
      case SbColorRole.onPrimary:
        return onPrimary;
      case SbColorRole.warning:
        return warning;
      case SbColorRole.destructive:
        return destructive;
      case SbColorRole.surface:
        return surface;
      case SbColorRole.background:
        return background;
      case SbColorRole.border:
        return border;
    }
  }
}
