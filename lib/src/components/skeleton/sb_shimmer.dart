import 'package:flutter/widgets.dart';

import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// Wraps a (typically solid, skeleton-shaped) [child] and sweeps a light band
/// across it — the gradient-sheen alternative to [SbSkeleton]'s opacity pulse.
///
/// ```dart
/// const SbShimmer(child: SbShimmerBox(width: 120, height: 16));
/// ```
class SbShimmer extends StatefulWidget {
  const SbShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final Duration duration;

  @override
  State<SbShimmer> createState() => _SbShimmerState();
}

class _SbShimmerState extends State<SbShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final base = colors.surfaceActive;
    final highlight = Color.alphaBlend(
      colors.textTertiary.withValues(alpha: 0.18),
      base,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          // t sweeps the band fully off both edges.
          final t = -0.3 + _controller.value * 1.6;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              colors: <Color>[base, highlight, base],
              stops: <double>[
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}

/// A solid block sized for use inside [SbShimmer].
class SbShimmerBox extends StatelessWidget {
  const SbShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = SbRadius.all6,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.sbColors.surfaceActive,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

