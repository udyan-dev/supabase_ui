import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Supabase's semantic set: neutral, brand, warning, destructive.
enum SbAlertVariant { neutral, brand, warning, destructive }

/// An inline message banner: tinted background + accent left edge, with a title,
/// optional description, optional leading icon, and an optional trailing action.
class SbAlert extends StatelessWidget {
  const SbAlert({
    super.key,
    required this.title,
    this.description,
    this.variant = SbAlertVariant.neutral,
    this.icon,
    this.action,
  });

  final String title;
  final String? description;
  final SbAlertVariant variant;

  /// Optional leading widget (e.g. a `VectorGraphic` icon).
  final Widget? icon;

  /// Optional trailing widget (e.g. a dismiss button or link).
  final Widget? action;

  Color _accent(SbColorScheme c) {
    switch (variant) {
      case SbAlertVariant.neutral:
        return c.textSecondary;
      case SbAlertVariant.brand:
        return c.primary;
      case SbAlertVariant.warning:
        return c.warning;
      case SbAlertVariant.destructive:
        return c.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final accent = _accent(colors);
    final bg = Color.alphaBlend(accent.withValues(alpha: 0.08), colors.surface);

    return SbSurface(
      color: bg,
      borderColor: accent.withValues(alpha: 0.24),
      borderRadius: SbRadius.all8,
      padding: const EdgeInsets.all(SbSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            IconTheme.merge(
              data: const IconThemeData(size: 18),
              child: icon!,
            ),
            const SizedBox(width: SbSpacing.s12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SbText(title, variant: SbTextVariant.bodyStrong),
                if (description != null) ...<Widget>[
                  const SizedBox(height: SbSpacing.s4),
                  SbText.body(description!, role: SbColorRole.textSecondary),
                ],
              ],
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: SbSpacing.s12),
            action!,
          ],
        ],
      ),
    );
  }
}
