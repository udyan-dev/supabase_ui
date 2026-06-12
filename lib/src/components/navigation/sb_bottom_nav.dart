import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Builds an icon tinted with the resolved per-state [color] (selected vs not).
/// Lets callers render a `VectorGraphic` (or any widget) with the right color.
typedef SbNavIconBuilder = Widget Function(Color color);

/// One destination in an [SbBottomNav].
@immutable
class SbBottomNavItem {
  const SbBottomNavItem({required this.icon, required this.label});

  final SbNavIconBuilder icon;
  final String label;
}

/// A bottom navigation bar: a top-bordered surface of equal-width destinations,
/// the active one tinted with the brand/primary color. Honors the bottom safe
/// area.
class SbBottomNav extends StatelessWidget {
  const SbBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  }) : assert(items.length >= 2);

  final List<SbBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbSurface(
      color: colors.background,
      border: Border(top: BorderSide(color: colors.border)),
      // Only the top edge reads as a divider; render a 1px top border via a
      // full border tinted to match (kept simple and token-driven).
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final SbBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final color = selected ? colors.icon : colors.textTertiary;
    return SbInteraction(
      onTap: onTap,
      builder: (context, states, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SbSpacing.s4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: SbSpacing.s4,
            children: <Widget>[
              SizedBox(width: 20, height: 20, child: item.icon(color)),
              SbText(
                item.label,
                variant: SbTextVariant.caption,
                role: selected
                    ? SbColorRole.textPrimary
                    : SbColorRole.textTertiary,
              ),
            ],
          ),
        );
      },
    );
  }
}
