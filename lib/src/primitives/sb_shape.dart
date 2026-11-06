import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SbShape extends InheritedWidget {
  const SbShape({
    super.key,
    required this.radius,
    this.inset = 0,
    this.extent,
    required super.child,
  });

  final double radius;
  final double inset;
  final double? extent;

  static SbShape? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SbShape>();

  static double radiusOf(
    BuildContext context, {
    double? size,
    double gap = 0,
    required double fallback,
  }) {
    final shape = maybeOf(context);
    return shape == null ? fallback : shape.inner(size: size, gap: gap);
  }

  static BorderRadius of(
    BuildContext context, {
    double? size,
    double gap = 0,
    required BorderRadius fallback,
  }) {
    final shape = maybeOf(context);
    return shape == null
        ? fallback
        : BorderRadius.all(Radius.circular(shape.inner(size: size, gap: gap)));
  }

  double inner({double? size, double gap = 0}) {
    final e = extent;
    final d = e != null && size != null ? (e - size) / 2 : inset;
    return math.max(0, radius - d - gap);
  }

  @override
  bool updateShouldNotify(SbShape oldWidget) =>
      oldWidget.radius != radius ||
      oldWidget.inset != inset ||
      oldWidget.extent != extent;
}
