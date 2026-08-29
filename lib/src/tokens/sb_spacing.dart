/// Spacing scale (in logical pixels).
///
/// One canonical scale used for all padding, margin, and gaps. Components never
/// use magic numbers — they reference these tokens (typically via `SbBox`).
abstract final class SbSpacing {
  const SbSpacing._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;
}
