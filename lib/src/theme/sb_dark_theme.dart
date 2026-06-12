import '../tokens/sb_colors.dart';
import 'sb_theme_extensions.dart';

/// Dark color roles — Supabase's exact default dark-theme token values.
const SbColorScheme sbDarkColors = SbColorScheme(
  background: SbColors.bgDark,
  surface: SbColors.surface100Dark,
  surfaceHover: SbColors.surface200Dark,
  surfaceActive: SbColors.surface300Dark,
  border: SbColors.borderDark,
  borderStrong: SbColors.borderStrongDark,
  textPrimary: SbColors.fgDark,
  textSecondary: SbColors.fgDarkSecondary,
  textTertiary: SbColors.fgDarkTertiary,
  textInverse: SbColors.bgDark,
  primary: SbColors.brand,
  primaryHover: SbColors.brandHoverDark,
  primaryActive: SbColors.brandActiveDark,
  onPrimary: SbColors.bgDark, // dark text on brand green
  warning: SbColors.warningDark,
  destructive: SbColors.destructive,
  onSemantic: SbColors.white,
  overlay: SbColors.overlayDark,
  backgroundSelection: SbColors.backgroundSelectionDark,
  icon: SbColors.iconDark,
);
