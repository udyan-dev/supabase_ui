import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Injects a positional [borderRadius] into an [SbListTile] subtree.
///
/// [SbList] wraps only the first and last items with this widget, so middle
/// items incur zero wrapper overhead. [updateShouldNotify] suppresses
/// descendant rebuilds when the radius is unchanged across [SbList] rebuilds.
class SbListTileBorderRadius extends InheritedWidget {
  const SbListTileBorderRadius({
    super.key,
    required this.borderRadius,
    required super.child,
  });

  final BorderRadius borderRadius;

  static BorderRadius? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SbListTileBorderRadius>()
      ?.borderRadius;

  @override
  bool updateShouldNotify(SbListTileBorderRadius old) =>
      borderRadius != old.borderRadius;
}

/// A single list row: optional [leading], a [title] with optional [subtitle],
/// and an optional [trailing] widget. Tappable when [onTap] is provided, with
/// hover/press feedback via the shared interaction primitive.
///
/// When used inside [SbList], the positional border radius is injected via
/// [SbListTileBorderRadius] — no [copyWith] and no extra allocation per item.
/// The [borderRadius] field acts as the fallback for standalone use.
class SbListTile extends StatelessWidget {
  const SbListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.borderRadius = BorderRadius.zero,
    this.padding,
    this.isSelected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool isSelected;

  /// Corner radius when used standalone. Overridden by [SbListTileBorderRadius]
  /// when the tile lives inside an [SbList].
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final resolvedRadius = SbListTileBorderRadius.of(context) ?? borderRadius;

    return SbInteraction(
      onTap: onTap,
      enabled: onTap != null,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);

        return SbSurface(
          color: hovered
              ? colors.surfaceHover
              : isSelected
              ? colors.backgroundSelection
              : colors.surface,
          borderRadius: resolvedRadius,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: SbSpacing.s16,
                vertical: SbSpacing.s12,
              ),
          child: Row(
            children: <Widget>[
              if (leading != null) ...[
                leading!,
                const SizedBox(width: SbSpacing.s12),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SbText(
                      title,
                      variant: isSelected
                          ? SbTextVariant.bodyStrong
                          : SbTextVariant.body,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      SbText.caption(subtitle!),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: SbSpacing.s12),
                trailing!,
              ],
            ],
          ),
        );
      },
    );
  }
}
