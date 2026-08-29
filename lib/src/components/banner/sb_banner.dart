import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Supabase's semantic set: neutral, brand, warning, destructive.
enum SbBannerVariant { neutral, brand, warning, destructive }

/// A full-width, edge-to-edge announcement bar — typically pinned to the top of
/// a screen. Carries a [message], an optional [action], and an optional dismiss
/// affordance ([onDismiss]).
class SbBanner extends StatelessWidget {
  const SbBanner({
    super.key,
    required this.message,
    this.variant = SbBannerVariant.neutral,
    this.action,
    this.onDismiss,
  });

  final String message;
  final SbBannerVariant variant;
  final Widget? action;
  final VoidCallback? onDismiss;

  Color _accent(SbColorScheme c) {
    switch (variant) {
      case SbBannerVariant.neutral:
        return c.textSecondary;
      case SbBannerVariant.brand:
        return c.primary;
      case SbBannerVariant.warning:
        return c.warning;
      case SbBannerVariant.destructive:
        return c.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final accent = _accent(colors);

    return SbSurface(
      color: colors.surfaceActive,
      padding: const EdgeInsets.symmetric(
        horizontal: SbSpacing.s16,
        vertical: SbSpacing.s12,
      ),
      child: Column(
        spacing: SbSpacing.s8,
        children: <Widget>[
          SbText(message, variant: SbTextVariant.bodyStrong),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: SbSpacing.s16,
            children: [
              if (action != null) ...<Widget>[action!],
              if (onDismiss != null) ...<Widget>[
                SbInteraction(
                  onTap: onDismiss,
                  builder: (context, _, _) =>
                      _Cross(color: colors.textTertiary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Cross extends StatelessWidget {
  const _Cross({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 12,
    height: 12,
    child: CustomPaint(painter: _CrossPainter(color)),
  );
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
