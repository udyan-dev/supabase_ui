import 'package:flutter/material.dart';

/// The styled-container primitive: the one place a fill, border, radius,
/// shadow, and padding are composed. Every visual container in the system is
/// built from `SbSurface` — components never construct a raw `Container`/
/// `BoxDecoration`.
///
/// Colors are resolved by the caller from `context.sbColors`; radius/shadow are
/// passed as `SbRadius`/`SbElevation` tokens.
///
/// Backed by [Material] so that ink effects from descendant [InkWell]/
/// [InkResponse] widgets render correctly without a separate Material ancestor.
/// [animationDuration] is always zero — color transitions are instant, matching
/// the previous [DecoratedBox] behaviour.
class SbSurface extends StatelessWidget {
  const SbSurface({
    super.key,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius,
    this.boxShadow,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.clipChildren = false,
    this.child,
    this.border,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Border? border;

  /// Clip the child to [borderRadius] (e.g. images inside a card).
  final bool clipChildren;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        border ??
        (borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth));

    Widget? content = child;
    if (padding != null && content != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (clipChildren && borderRadius != null && content != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    // Material handles the fill and establishes an ink canvas for descendants.
    // animationDuration: zero keeps instant color changes (matches DecoratedBox).
    // MaterialType.transparency when color is null avoids an opaque default fill.
    Widget result = Material(
      type: color != null ? MaterialType.canvas : MaterialType.transparency,
      color: color,
      borderRadius: borderRadius,
      animationDuration: Duration.zero,
      child: content,
    );

    // Shadows must live behind the Material. Material only exposes elevation,
    // not List<BoxShadow>, so a background DecoratedBox carries them instead.
    if (boxShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: result,
      );
    }

    // Border is painted as a foreground overlay so it is never occluded by the
    // Material fill. BoxDecoration.border draws inside the widget bounds (same
    // as before), and foreground position keeps it on top of both fill and ink.
    // Note: Material.shape border is edge-centered (half outside) — we avoid
    // that path intentionally to preserve pixel-identical rendering.
    if (effectiveBorder != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: effectiveBorder,
        ),
        position: DecorationPosition.foreground,
        child: result,
      );
    }

    if (width != null || height != null) {
      result = SizedBox(width: width, height: height, child: result);
    }
    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints!, child: result);
    }
    return result;
  }
}
