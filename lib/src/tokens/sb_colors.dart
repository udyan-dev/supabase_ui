import 'dart:ui' show Color;

/// Raw color palette — the **exact** values from Supabase's compiled design
/// tokens (their default light/dark themes), read from the live design system
/// CSS (`--background-*`, `--foreground-*`, `--border-*`, `--brand-*`,
/// `--destructive-*`, `--warning-*`) and converted from HSL.
///
/// Note: Supabase's *default* theme uses a pure-neutral gray ramp (0° hue),
/// distinct from its optional "classic" theme which uses Radix slate/gray.
/// Values are role-less; the theme layer assigns them to `SbColorScheme`.
abstract final class SbColors {
  const SbColors._();

  // --- Brand (Supabase green) -------------------------------------------
  // `--brand-default` (#3ECF8E) is the canonical Supabase brand / primary.
  static const Color brand = Color(0xFF3ECF8E); // brand-default
  static const Color brandHoverLight = Color(0xFF16B674); // light: brand-500
  static const Color brandActiveLight = Color(0xFF097C4F); // light: brand-600
  static const Color brandHoverDark = Color(0xFF85E0BA); // dark: brand-600
  static const Color brandActiveDark = Color(0xFF16B674);
  static const Color brandLinkLight = Color(0xFF00BB68); // --brand-link (light)
  static const Color brandLinkDark = Color(0xFF00C573); // --brand-link (dark)

  // --- Neutral ramp — LIGHT theme (pure gray) ---------------------------
  static const Color bgLight = Color(0xFFFCFCFC); // --background-default
  static const Color surface100Light = Color(0xFFFCFCFC); // --bg-surface-100
  static const Color surface200Light = Color(0xFFF3F3F3); // --bg-surface-200
  static const Color surface300Light = Color(0xFFEDEDED); // --bg-surface-300
  static const Color borderLight = Color(0xFFDFDFDF); // --border-default
  static const Color borderStrongLight = Color(0xFFD4D4D4); // --border-strong
  static const Color borderStrongerLight = Color(0xFF8F8F8F); // border-stronger
  static const Color fgLight = Color(0xFF171717); // --foreground-default
  static const Color fgLightSecondary = Color(0xFF525252); // --foreground-light
  static const Color fgLightTertiary = Color(0xFF707070); // foreground-lighter
  static const Color fgLightMuted = Color(0xFFB2B2B2); // --foreground-muted
  static const Color backgroundSelectionLight = Color(
    0xFFEDEDED,
  ); // --background-selection

  // Icon colors — Supabase has no separate --icon-* variables; icons inherit
  // from --foreground-*. The primary ("default") icon color is
  // --foreground-default in both themes (0° 0% 9% light / 0° 0% 98% dark).
  static const Color iconLight = Color(0xFF171717); // --foreground-default (light)
  static const Color iconDark = Color(0xFFFAFAFA); // --foreground-default (dark)

  // --- Neutral ramp — DARK theme (pure gray) ----------------------------
  static const Color bgDark = Color(0xFF121212); // --background-default
  static const Color surface100Dark = Color(0xFF1F1F1F); // --bg-surface-100
  static const Color surface200Dark = Color(0xFF212121); // --bg-surface-200
  static const Color surface300Dark = Color(0xFF292929); // --bg-surface-300
  static const Color borderDark = Color(0xFF2E2E2E); // --border-default
  static const Color borderStrongDark = Color(0xFF363636); // --border-strong
  static const Color borderStrongerDark = Color(0xFF454545); // border-stronger
  static const Color fgDark = Color(0xFFFAFAFA); // --foreground-default
  static const Color fgDarkSecondary = Color(0xFFB4B4B4); // --foreground-light
  static const Color fgDarkTertiary = Color(0xFF898989); // foreground-lighter
  static const Color fgDarkMuted = Color(0xFF4D4D4D); // --foreground-muted
  static const Color backgroundSelectionDark = Color(
    0xFF313131,
  ); // --background-selection
  // --- Semantic accents --------------------------------------------------
  // Supabase's non-brand semantics: destructive (red/orange) and warning
  // (amber). Positive/success is the brand itself.
  static const Color destructive = Color(0xFFE54D2E); // --destructive-default
  static const Color warningLight = Color(0xFFDC7B18); // --warning-default
  static const Color warningDark = Color(0xFFDB8E00);

  // --- Absolutes & overlays ---------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color overlayLight = Color(0x66000000); // 40% black
  static const Color overlayDark = Color(0x99000000); // 60% black
}
