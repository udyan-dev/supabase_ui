import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../tokens/sb_typography.dart';
import '../../utils/context_extensions.dart';

/// Supabase's semantic set: neutral, brand (primary/positive), warning, and
/// destructive.
enum SbBadgeVariant { neutral, brand, warning, destructive }

enum SbBadgeSize { sm, md }

/// Compact status label. Tinted background + readable foreground, optional dot.
class SbBadge extends StatelessWidget {
  const SbBadge(
    this.label, {
    super.key,
    this.variant = SbBadgeVariant.neutral,
    this.size = SbBadgeSize.md,
    this.dot = false,
  });

  final String label;
  final SbBadgeVariant variant;
  final SbBadgeSize size;
  final bool dot;

  Color _accent(SbColorScheme c) {
    switch (variant) {
      case SbBadgeVariant.neutral:
        return c.textSecondary;
      case SbBadgeVariant.brand:
        return c.primary;
      case SbBadgeVariant.warning:
        return c.warning;
      case SbBadgeVariant.destructive:
        return c.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final accent = _accent(colors);
    final bg = Color.alphaBlend(accent.withValues(alpha: 0.12), colors.surface);
    final isSm = size == SbBadgeSize.sm;

    return SbSurface(
      color: bg,
      borderColor: accent.withValues(alpha: 0.24),
      borderRadius: SbRadius.full,
      padding: EdgeInsets.symmetric(
        horizontal: isSm ? SbSpacing.s8 : SbSpacing.s12,
        vertical: isSm ? 2 : SbSpacing.s4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (dot) ...[
            _Dot(color: accent),
            const SizedBox(width: SbSpacing.s4),
          ],
          Text(
            label,
            style: SbTypography.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w500,
              fontSize: isSm ? 11 : 12,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SbSurface(
      width: 6,
      height: 6,
      color: color,
      borderRadius: SbRadius.full,
    );
  }
}
