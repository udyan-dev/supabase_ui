import 'package:flutter/painting.dart';

/// Corner-radius scale.
///
/// Exposes both raw [Radius] and ready-to-use [BorderRadius] consts so callers
/// never construct radii inline.
abstract final class SbRadius {
  const SbRadius._();

  // Supabase's named radius tokens: xs=2, sm=4, lg=8, xl=16 (6/12 are standard
  // intermediates its components also use via Tailwind's rounded-md/lg).
  static const Radius r2 = Radius.circular(2);
  static const Radius r4 = Radius.circular(4);
  static const Radius r6 = Radius.circular(6);
  static const Radius r8 = Radius.circular(8);
  static const Radius r12 = Radius.circular(12);
  static const Radius r16 = Radius.circular(16);

  static const BorderRadius all2 = BorderRadius.all(r2);
  static const BorderRadius all4 = BorderRadius.all(r4);
  static const BorderRadius all6 = BorderRadius.all(r6);
  static const BorderRadius all8 = BorderRadius.all(r8);
  static const BorderRadius all12 = BorderRadius.all(r12);
  static const BorderRadius all16 = BorderRadius.all(r16);

  /// Fully rounded (pills / circles). Large constant; clamps to the shorter
  /// side at paint time.
  static const BorderRadius full = BorderRadius.all(Radius.circular(9999));
}
