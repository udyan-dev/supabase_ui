import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Controlled checkbox with optional label. `onChanged == null` disables it.
class SbCheckbox extends StatelessWidget {
  const SbCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbInteraction(
      enabled: _enabled,
      onTap: _enabled ? () => onChanged!(!value) : null,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        final disabled = states.contains(WidgetState.disabled);

        final box = AnimatedContainer(
          duration: SbMotion.fast,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value
                ? (disabled ? colors.textPrimary : colors.primary)
                : (hovered ? colors.surfaceHover : colors.surface),
            borderRadius: SbRadius.all4,
            border: Border.all(
              color: value
                  ? (disabled ? colors.textPrimary : colors.primary)
                  : (hovered ? colors.borderStrong : colors.border),
              width: 1.5,
            ),
          ),
          child: value
              ? _CheckGlyph(color: colors.onPrimary)
              : const SizedBox.shrink(),
        );

        if (label == null) return box;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            box,
            const SizedBox(width: SbSpacing.s8),
            Flexible(
              child: SbText.body(
                label!,
                role: disabled
                    ? SbColorRole.textTertiary
                    : SbColorRole.textPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CheckGlyph extends StatelessWidget {
  const _CheckGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CheckPainter(color));
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.43, h * 0.68)
      ..lineTo(w * 0.72, h * 0.34);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}
