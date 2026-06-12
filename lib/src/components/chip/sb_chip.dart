import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// An interactive, pill-shaped chip — tappable, optionally [selected], with an
/// optional leading icon and an optional delete affordance.
///
/// Distinct from `SbBadge` (a static status label): a chip responds to input.
class SbChip extends StatelessWidget {
  const SbChip({
    super.key,
    required this.label,
    this.selected = false,
    this.leading,
    this.onTap,
    this.onDeleted,
  });

  final String label;
  final bool selected;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final fg = selected ? colors.onPrimary : colors.textSecondary;
    final bg = selected ? colors.primary : colors.surfaceHover;
    final border = selected ? colors.primary : colors.border;

    return SbInteraction(
      onTap: onTap,
      enabled: onTap != null,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return SbSurface(
          color: hovered && !selected ? colors.surfaceActive : bg,
          borderColor: border,
          borderRadius: SbRadius.full,
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s12,
            vertical: SbSpacing.s4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leading != null) ...<Widget>[
                SizedBox(width: 14, height: 14, child: leading),
                const SizedBox(width: SbSpacing.s4),
              ],
              SbText(
                label,
                variant: SbTextVariant.caption,
                role: selected
                    ? SbColorRole.onPrimary
                    : SbColorRole.textSecondary,
              ),
              if (onDeleted != null) ...<Widget>[
                const SizedBox(width: SbSpacing.s4),
                SbInteraction(
                  onTap: onDeleted,
                  builder: (context, _, _) =>
                      _Cross(color: fg.withValues(alpha: 0.7)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A small "×" delete glyph drawn without an icon dependency.
class _Cross extends StatelessWidget {
  const _Cross({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: CustomPaint(painter: _CrossPainter(color)),
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}
