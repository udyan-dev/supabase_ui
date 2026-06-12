import 'package:flutter/material.dart';

import 'sb_dark_theme.dart';
import 'sb_light_theme.dart';
import 'sb_theme_extensions.dart';

/// The single source of theme truth, attached to `ThemeData.extensions`.
///
/// Only brightness-dependent data lives here ([colors] + [brightness]). The
/// other token families (spacing, radius, typography, elevation, motion) are
/// brightness-independent compile-time constants and are referenced directly
/// from their `Sb*` token classes — this avoids duplicating them per theme and
/// keeps lookups free.
///
/// Access via `context.sb` (see `context_extensions.dart`).
@immutable
class SbTheme extends ThemeExtension<SbTheme> {
  const SbTheme({
    required this.colors,
    required this.brightness,
  });

  final SbColorScheme colors;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  static const SbTheme light = SbTheme(
    colors: sbLightColors,
    brightness: Brightness.light,
  );

  static const SbTheme dark = SbTheme(
    colors: sbDarkColors,
    brightness: Brightness.dark,
  );

  @override
  SbTheme copyWith({SbColorScheme? colors, Brightness? brightness}) {
    return SbTheme(
      colors: colors ?? this.colors,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  SbTheme lerp(ThemeExtension<SbTheme>? other, double t) {
    if (other is! SbTheme) return this;
    return SbTheme(
      colors: SbColorScheme.lerp(colors, other.colors, t),
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}
