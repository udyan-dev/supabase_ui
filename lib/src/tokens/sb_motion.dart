import 'package:flutter/animation.dart';

/// Motion tokens — durations and easing curves taken verbatim from Supabase's
/// design-system CSS (`--animate-*` definitions and their `@keyframes`).
///
/// | use                     | duration | easing                      |
/// |-------------------------|----------|-----------------------------|
/// | dropdown / collapsible  | 100ms    | standard `(.16,1,.3,1)`     |
/// | accordion               | 150ms    | easeOut (CSS `ease-out`)    |
/// | panel slide out         | 200ms    | emphasized `(.87,0,.13,1)`  |
/// | panel/side-sheet in     | 250ms    | emphasized `(.87,0,.13,1)`  |
/// | overlay / fade / sheet  | 300ms    | standard `(.16,1,.3,1)`     |
/// | skeleton pulse          | 2000ms   | pulse `(.4,0,.6,1)`         |
/// | spinner                 | 1000ms   | linear                      |
abstract final class SbMotion {
  const SbMotion._();

  // Durations.
  static const Duration instant = Duration(milliseconds: 100); // dropdown
  static const Duration fast = Duration(milliseconds: 150); // accordion
  static const Duration normal = Duration(milliseconds: 200); // panel out
  static const Duration panel = Duration(milliseconds: 250); // panel/sheet in
  static const Duration slow = Duration(milliseconds: 300); // overlay/fade
  static const Duration pulse = Duration(milliseconds: 2000); // skeleton
  static const Duration spin = Duration(milliseconds: 1000); // spinner

  // Easing curves (exact cubic-beziers from Supabase's CSS).
  /// Overlay / dropdown content: `cubic-bezier(.16, 1, .3, 1)`.
  static const Curve standard = Cubic(0.16, 1, 0.3, 1);

  /// Panel / sheet slide: `cubic-bezier(.87, 0, .13, 1)`.
  static const Curve emphasized = Cubic(0.87, 0, 0.13, 1);

  /// Accordion / collapsible height: CSS `ease-out` (= `cubic-bezier(0,0,.58,1)`,
  /// which Flutter's [Curves.easeOut] matches).
  static const Curve easeOut = Curves.easeOut;

  /// Skeleton opacity pulse: `cubic-bezier(.4, 0, .6, 1)`.
  static const Curve pulseEase = Cubic(0.4, 0, 0.6, 1);

  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
}
