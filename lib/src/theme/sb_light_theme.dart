import '../tokens/sb_colors.dart';
import 'sb_theme_extensions.dart';

/// Light color roles — Supabase's exact default light-theme token values.
const SbColorScheme sbLightColors = SbColorScheme(
  background: SbColors.bgLight,
  surface: SbColors.surface100Light,
  surfaceHover: SbColors.surface200Light,
  surfaceActive: SbColors.surface300Light,
  border: SbColors.borderLight,
  borderStrong: SbColors.borderStrongLight,
  textPrimary: SbColors.fgLight,
  textSecondary: SbColors.fgLightSecondary,
  textTertiary: SbColors.fgLightTertiary,
  textInverse: SbColors.white,
  primary: SbColors.brand,
  primaryHover: SbColors.brandHoverLight,
  primaryActive: SbColors.brandActiveLight,
  onPrimary: SbColors.fgDark, // dark text on light brand green
  warning: SbColors.warningLight,
  destructive: SbColors.destructive,
  onSemantic: SbColors.white,
  overlay: SbColors.overlayLight,
  backgroundSelection: SbColors.backgroundSelectionLight,
  icon: SbColors.iconLight,
);
