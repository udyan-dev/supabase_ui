import 'package:flutter/painting.dart';

/// Shadow / elevation scale.
///
/// Each level is a ready-to-use `List<BoxShadow>` for `SbSurface`. Level 0 is
/// explicitly empty (flat) so callers can switch levels without null checks.
abstract final class SbElevation {
  const SbElevation._();

  static const List<BoxShadow> e0 = <BoxShadow>[];

  static const List<BoxShadow> e1 = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> e2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> e3 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> e4 = <BoxShadow>[
    BoxShadow(
      color: Color(0x29000000), // 16% black
      blurRadius: 28,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Resolve a level index (0–4) to its shadow list. Out-of-range clamps.
  static List<BoxShadow> level(int level) {
    switch (level) {
      case 0:
        return e0;
      case 1:
        return e1;
      case 2:
        return e2;
      case 3:
        return e3;
      default:
        return e4;
    }
  }
}
