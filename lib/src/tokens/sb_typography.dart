import 'package:flutter/painting.dart';

/// The type scale. Styles are mutable statics so [use] can rebind the family
/// once at startup and have every widget pick it up with no per-build cost.
abstract final class SbTypography {
  const SbTypography._();

  /// The variable family bundled with this package (axes: `opsz`, `wdth`,
  /// `wght`). Package-bundled families need the `packages/<name>/` prefix.
  static const String bundledFontFamily =
      'packages/supabase_ui/Bricolage Grotesque';

  static String fontFamily = bundledFontFamily;

  /// Family used by [mono]. No monospace face is bundled, so this defaults to
  /// `null` (the platform default) until an app supplies one via [use].
  static String? monoFamily;

  static TextStyle display = _ui(30, 1.2, 700, -0.5);
  static TextStyle heading = _ui(24, 1.3333, 700, -0.25);
  static TextStyle title = _ui(18, 1.5556, 500);
  static TextStyle body = _ui(14, 1.4286, 400);
  static TextStyle bodyStrong = _ui(14, 1.4286, 500);
  static TextStyle caption = _ui(12, 1.3333, 400, 0.1);
  static TextStyle captionStrong = _ui(12, 1.3333, 500, 0.1);
  static TextStyle mono = _mono();

  /// Rebinds the families and rebuilds the scale in place. Omitting an
  /// argument restores that family's default.
  static void use({String? fontFamily, String? monoFamily}) {
    SbTypography.fontFamily = fontFamily ?? bundledFontFamily;
    SbTypography.monoFamily = monoFamily;

    display = _ui(30, 1.2, 700, -0.5);
    heading = _ui(24, 1.3333, 700, -0.25);
    title = _ui(18, 1.5556, 500);
    body = _ui(14, 1.4286, 400);
    bodyStrong = _ui(14, 1.4286, 500);
    caption = _ui(12, 1.3333, 400, 0.1);
    captionStrong = _ui(12, 1.3333, 500, 0.1);
    mono = _mono();
  }

  /// Pins the `wght` and `opsz` axes so a variable file renders the intended
  /// instance instead of its default one; `fontWeight` covers static families,
  /// and axes a font lacks are ignored.
  static TextStyle _ui(
    double size,
    double height,
    int weight, [
    double? letterSpacing,
  ]) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: height,
    fontWeight: FontWeight.values[weight ~/ 100 - 1],
    fontVariations: <FontVariation>[
      FontVariation('opsz', size),
      FontVariation('wght', weight.toDouble()),
    ],
    letterSpacing: letterSpacing,
  );

  static TextStyle _mono() => TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    height: 1.4286,
    fontWeight: FontWeight.w400,
  );
}
