import 'package:flutter/widgets.dart';

/// Spacing / sizing primitive — a thin, const wrapper over [Padding] +
/// [SizedBox]. Callers pass `SbSpacing` tokens for [padding]/[margin]; magic
/// numbers never appear in components.
class SbBox extends StatelessWidget {
  const SbBox({
    super.key,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.child,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget? current = child;

    if (padding != null && current != null) {
      current = Padding(padding: padding!, child: current);
    }
    if (alignment != null) {
      current = Align(alignment: alignment!, child: current);
    }
    if (width != null || height != null) {
      current = SizedBox(width: width, height: height, child: current);
    }
    if (margin != null) {
      current = Padding(padding: margin!, child: current);
    }
    return current ?? const SizedBox.shrink();
  }
}

/// Fixed gap for use between flex children (replaces inline `SizedBox`).
class SbGap extends StatelessWidget {
  const SbGap(this.size, {super.key}) : _vertical = null;

  /// Vertical-only gap.
  const SbGap.v(this.size, {super.key}) : _vertical = true;

  /// Horizontal-only gap.
  const SbGap.h(this.size, {super.key}) : _vertical = false;

  final double size;
  final bool? _vertical;

  @override
  Widget build(BuildContext context) {
    switch (_vertical) {
      case true:
        return SizedBox(height: size);
      case false:
        return SizedBox(width: size);
      case null:
        return SizedBox(width: size, height: size);
    }
  }
}
