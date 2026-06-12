import 'package:flutter/widgets.dart';

import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// A shimmering placeholder shown while content loads.
///
/// Token-driven and self-animating: a single repeating opacity pulse between
/// the theme's two surface tints — no shader, no per-frame layout. Compose
/// several to build a skeleton for a card, list row, etc.
///
/// ```dart
/// const SbSkeleton(width: 120, height: 16);          // a text line
/// const SbSkeleton.circle(48);                        // an avatar
/// const SbSkeleton(height: 80, borderRadius: SbRadius.all12); // a block
/// ```
class SbSkeleton extends StatefulWidget {
  const SbSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = SbRadius.all6,
  });

  /// A circular skeleton (e.g. an avatar placeholder) of the given [diameter].
  const SbSkeleton.circle(double diameter, {super.key})
      : width = diameter,
        height = diameter,
        borderRadius = SbRadius.full;

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SbSkeleton> createState() => _SbSkeletonState();
}

class _SbSkeletonState extends State<SbSkeleton>
    with SingleTickerProviderStateMixin {
  // Supabase `animate-pulse`: opacity 1 -> .5 -> 1 over 2s, cubic(.4,0,.6,1).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SbMotion.pulse,
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.5,
  ).animate(CurvedAnimation(parent: _controller, curve: SbMotion.pulseEase));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.sbColors.surfaceActive;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FadeTransition(
          opacity: _opacity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: widget.borderRadius,
            ),
          ),
        ),
      ),
    );
  }
}

/// A ready-made multi-line text skeleton: [lines] bars with the last one
/// shortened, separated by [SbSpacing.s8].
class SbSkeletonText extends StatelessWidget {
  const SbSkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.lastLineFactor = 0.6,
  }) : assert(lines > 0);

  final int lines;
  final double lineHeight;

  /// Width fraction of the final line (0–1) so paragraphs look natural.
  final double lastLineFactor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < lines; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: SbSpacing.s8),
          if (i == lines - 1 && lines > 1)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: lastLineFactor,
                child: SbSkeleton(height: lineHeight),
              ),
            )
          else
            SbSkeleton(height: lineHeight),
        ],
      ],
    );
  }
}
