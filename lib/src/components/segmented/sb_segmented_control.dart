import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// A compact single-select control: equal-width segments inside a track, with
/// the active segment raised on a surface (a.k.a. toggle group).
class SbSegmentedControl extends StatelessWidget {
  const SbSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  }) : assert(segments.length > 0);

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbSurface(
      color: colors.surfaceActive,
      borderRadius: SbRadius.all8,
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < segments.length; i++)
            Expanded(
              child: _Segment(
                label: segments[i],
                selected: i == selectedIndex,
                enabled: onChanged != null,
                onTap: () => onChanged?.call(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      enabled: enabled,
      onTap: onTap,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return AnimatedContainer(
          duration: SbMotion.fast,
          curve: SbMotion.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s16,
            vertical: SbSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.surface : null,
            borderRadius: SbRadius.all6,
          ),
          child: SbText(
            label,
            align: TextAlign.center,
            variant: SbTextVariant.bodyStrong,
            role: selected || hovered
                ? SbColorRole.textPrimary
                : SbColorRole.textSecondary,
          ),
        );
      },
    );
  }
}
