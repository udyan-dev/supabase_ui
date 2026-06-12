import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// Three-state checkbox: `true` (all), `false` (none) and `null` (mixed).
///
/// Tapping resolves to a concrete boolean: an unchecked or mixed box becomes
/// `true`, a fully-checked box becomes `false`. `onChanged == null` disables it.
class SbTriStateCheckbox extends StatelessWidget {
  const SbTriStateCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool? value;
  final ValueChanged<bool>? onChanged;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final bool filled = value != false;

    return SbInteraction(
      enabled: _enabled,
      onTap: _enabled ? () => onChanged!(value != true) : null,
      builder: (context, states, _) {
        final bool hovered = states.contains(WidgetState.hovered);
        final bool disabled = states.contains(WidgetState.disabled);
        final Color accent = disabled ? colors.textTertiary : colors.primary;

        return AnimatedContainer(
          duration: SbMotion.fast,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: filled
                ? accent
                : (hovered ? colors.surfaceHover : colors.surface),
            borderRadius: SbRadius.all4,
            border: Border.all(
              color: filled
                  ? accent
                  : (hovered ? colors.borderStrong : colors.border),
              width: 1.5,
            ),
          ),
          child: filled
              ? CustomPaint(
                  painter: _MarkPainter(
                    color: colors.onPrimary,
                    indeterminate: value == null,
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.color, required this.indeterminate});

  final Color color;
  final bool indeterminate;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double w = size.width, h = size.height;
    final Path path = Path();
    if (indeterminate) {
      path
        ..moveTo(w * 0.26, h * 0.5)
        ..lineTo(w * 0.74, h * 0.5);
    } else {
      path
        ..moveTo(w * 0.28, h * 0.52)
        ..lineTo(w * 0.43, h * 0.68)
        ..lineTo(w * 0.72, h * 0.34);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.indeterminate != indeterminate;
}
