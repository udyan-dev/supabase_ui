import 'package:flutter/painting.dart';

/// Type scale — sizes, weights, and line-heights from Supabase's Tailwind type
/// scale (`--text-*` / `--leading-*` / `--font-weight-*`).
///
/// | style       | size | line-height        | weight |
/// |-------------|------|--------------------|--------|
/// | display     | 30   | 36 (text-3xl)      | 700    |
/// | heading     | 24   | 32 (text-2xl)      | 700    |
/// | title       | 18   | 28 (text-lg)       | 500    |
/// | body        | 14   | 20 (text-sm)       | 400    |
/// | bodyStrong  | 14   | 20                 | 500    |
/// | caption     | 12   | 16 (text-xs)       | 400    |
/// | mono        | 14   | 20                 | 400    |
///
/// Weights are chosen from CustomFont's available faces (400/500/700/800);
/// CustomFont ships no 600, matching Supabase. Color-less base [TextStyle]s;
/// the theme layer applies the text color role.
abstract final class SbTypography {
  const SbTypography._();

  /// UI text — Supabase Studio's `--font-custom` (CustomFont / Circular),
  /// bundled and exported by this package, referenced with the package prefix.
  static const String fontFamily = 'packages/supabase_ui/CustomFont';

  /// Monospace/code — Supabase's `--font-source-code-pro`. Bundled here.
  static const String monoFamily = 'packages/supabase_ui/Source Code Pro';

  // Tailwind line-heights are unitless ratios (px line-height ÷ px font-size).
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30, // text-3xl
    height: 1.2, // 36/30
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24, // text-2xl
    height: 1.3333, // 32/24
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18, // text-lg
    height: 1.5556, // 28/18
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14, // text-sm
    height: 1.4286, // 20/14
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4286,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12, // text-xs
    height: 1.3333, // 16/12
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: monoFamily,
    fontSize: 14, // text-sm
    height: 1.4286,
    fontWeight: FontWeight.w400,
  );
}
