import 'package:flutter/material.dart';

import '../tokens/sb_typography.dart';
import 'sb_dark_theme.dart';
import 'sb_light_theme.dart';
import 'sb_theme.dart';

/// Builds the `ThemeData` that hosts the `SbTheme` extension.
///
/// ```dart
/// MaterialApp(
///   theme: SbAppTheme.light,
///   darkTheme: SbAppTheme.dark,
/// );
/// ```
abstract final class SbAppTheme {
  const SbAppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final sb = isDark ? SbTheme.dark : SbTheme.light;
    final colors = isDark ? sbDarkColors : sbLightColors;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: SbTypography.fontFamily,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      // Keep Material's ColorScheme roughly aligned so any stray Material
      // widget (e.g. in a host app) reads sensible colors.
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        surface: colors.surface,
        primary: colors.primary,
        error: colors.destructive,
      ),
      extensions: <ThemeExtension<dynamic>>[sb],
    );
  }
}
