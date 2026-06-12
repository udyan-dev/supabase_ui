import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// Linear progress bar. Determinate when [value] (0–1) is provided, otherwise
/// an indeterminate sweep.
class SbProgress extends StatefulWidget {
  const SbProgress({super.key, this.value, this.height = 6})
      : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final double height;

  @override
  State<SbProgress> createState() => _SbProgressState();
}

class _SbProgressState extends State<SbProgress>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _maybeAnimate();
  }

  @override
  void didUpdateWidget(SbProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnimate();
  }

  void _maybeAnimate() {
    final indeterminate = widget.value == null;
    if (indeterminate && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2300), // Supabase line-loading
      )..repeat();
    } else if (!indeterminate && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final track = colors.surfaceActive;
    final fill = colors.primary;

    return ClipRRect(
      borderRadius: SbRadius.full,
      child: SizedBox(
        height: widget.height,
        child: widget.value != null
            ? _DeterminateBar(value: widget.value!, track: track, fill: fill)
            // Isolate the perpetual repaint from the rest of the tree.
            : RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, _) => CustomPaint(
                    painter: _IndeterminatePainter(
                      t: _controller!.value,
                      track: track,
                      fill: fill,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _DeterminateBar extends StatelessWidget {
  const _DeterminateBar({
    required this.value,
    required this.track,
    required this.fill,
  });

  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: track),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: SbMotion.normal,
          curve: SbMotion.standard,
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(decoration: BoxDecoration(color: fill)),
        ),
      ),
    );
  }
}

class _IndeterminatePainter extends CustomPainter {
  const _IndeterminatePainter({
    required this.t,
    required this.track,
    required this.fill,
  });

  final double t;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    final barWidth = size.width * 0.4;
    final travel = size.width + barWidth;
    final x = travel * t - barWidth;
    canvas.drawRect(
      Rect.fromLTWH(x, 0, barWidth, size.height),
      Paint()..color = fill,
    );
  }

  @override
  bool shouldRepaint(_IndeterminatePainter old) =>
      old.t != t || old.fill != fill || old.track != track;
}

/// Circular progress indicator. Determinate or indeterminate.
class SbCircularProgress extends StatefulWidget {
  const SbCircularProgress({
    super.key,
    this.value,
    this.size = 24,
    this.strokeWidth = 3,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final double size;
  final double strokeWidth;

  @override
  State<SbCircularProgress> createState() => _SbCircularProgressState();
}

class _SbCircularProgressState extends State<SbCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SbMotion.spin, // Supabase spinner: 1s linear
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(SbCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _CircularPainter(
              value: widget.value,
              rotation: _controller.value,
              track: colors.surfaceActive,
              fill: colors.primary,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  const _CircularPainter({
    required this.value,
    required this.rotation,
    required this.track,
    required this.fill,
    required this.strokeWidth,
  });

  final double? value;
  final double rotation;
  final Color track;
  final Color fill;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(inset, 0, math.pi * 2, false, trackPaint);

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    if (value != null) {
      canvas.drawArc(
        inset,
        -math.pi / 2,
        math.pi * 2 * value!,
        false,
        fillPaint,
      );
    } else {
      final start = rotation * math.pi * 2;
      canvas.drawArc(inset, start, math.pi * 1.4, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_CircularPainter old) =>
      old.value != value ||
      old.rotation != rotation ||
      old.fill != fill ||
      old.track != track;
}
