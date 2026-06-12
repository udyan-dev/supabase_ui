import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../divider/sb_divider.dart';

/// Data for a single row in [SbRadioGroupStacked].
class SbRadioOption<T> {
  const SbRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });

  final T value;
  final String label;
  final String? description;

  /// Prevents selection of this option independently of the group's [onChanged].
  final bool disabled;
}

/// A vertically stacked radio group rendered as a bordered card list.
///
/// Each [SbRadioOption] occupies a full-width row: label and optional
/// description on the left, radio indicator on the right. Rows are separated
/// by hairline dividers and the whole group is enclosed in a rounded border.
///
/// Follows the Supabase "radio-group-stacked" design token exactly:
/// - Selected row: [SbColorScheme.backgroundSelection] fill.
/// - Hover row: [SbColorScheme.surfaceHover] fill.
/// - Disabled option: [SbColorRole.textTertiary] labels, no interaction.
///
/// Generic over [T] — pass any comparable value type.
class SbRadioGroupStacked<T> extends StatelessWidget {
  const SbRadioGroupStacked({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
  });

  final List<SbRadioOption<T>> options;
  final T? groupValue;

  /// Set to `null` to disable the entire group.
  final ValueChanged<T>? onChanged;

  // Const border radii for first / last slots — pointer-stable so the
  // SbListTileBorderRadius.updateShouldNotify fast-path is preserved if this
  // widget is composed inside an SbList in the future.
  static const BorderRadius _top = BorderRadius.vertical(top: SbRadius.r8);
  static const BorderRadius _bottom = BorderRadius.vertical(
    bottom: SbRadius.r8,
  );

  BorderRadius _radiusFor(int index, int count) {
    if (count == 1) return SbRadius.all8;
    if (index == 0) return _top;
    if (index == count - 1) return _bottom;
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final colors = context.sbColors;
    final count = options.length;

    // Column of alternating [_StackedItem, SbDivider, _StackedItem, …].
    final children = List<Widget>.generate(count * 2 - 1, (i) {
      if (i.isOdd) return const SbDivider();
      final index = i ~/ 2;
      return _StackedItem<T>(
        option: options[index],
        groupValue: groupValue,
        onChanged: onChanged,
        borderRadius: _radiusFor(index, count),
      );
    });

    // ClipRRect clips content to the group's corners.
    // The foreground DecoratedBox draws the outer border on top of the clip
    // so the stroke is never cut off.
    return ClipRRect(
      borderRadius: SbRadius.all8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: SbRadius.all8,
          border: Border.all(color: colors.border),
        ),
        position: DecorationPosition.foreground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// A single selectable row inside [SbRadioGroupStacked].
class _StackedItem<T> extends StatelessWidget {
  const _StackedItem({
    required this.option,
    required this.groupValue,
    required this.onChanged,
    required this.borderRadius,
  });

  final SbRadioOption<T> option;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final BorderRadius borderRadius;

  bool get _selected => option.value == groupValue;
  bool get _enabled => onChanged != null && !option.disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbInteraction(
      enabled: _enabled,
      onTap: _enabled ? () => onChanged!(option.value) : null,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        final disabled = states.contains(WidgetState.disabled);
        final accent = disabled ? colors.textTertiary : colors.textPrimary;

        // Both hover and selected map to surface-300 (backgroundSelection),
        // matching data-[state=checked]:bg-surface-300 / hover:bg-surface-300.
        final bg = (hovered || _selected)
            ? colors.backgroundSelection
            : colors.surface;

        // Outer ring: 16×16 (w-4 h-4 = 16px), 1.5px border that strengthens
        // on hover/select (group-hover:border-foreground-muted,
        // data-[state=checked]:border-foreground-muted).
        // Inner dot: 8px filled accent circle, animates from 0→8px on select —
        // matches the Radix RadioGroupPrimitive.Indicator filled-circle render.
        final dot = SizedBox(
          width: 16,
          height: 16,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: SbMotion.fast,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_selected || hovered)
                        ? colors.borderStrong
                        : colors.border,
                    width: 1.5,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: SbMotion.fast,
                width: _selected ? 8 : 0,
                height: _selected ? 8 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
            ],
          ),
        );

        return SbSurface(
          color: bg,
          borderRadius: borderRadius,
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s16,
            vertical: SbSpacing.s12,
          ),
          child: Row(
            spacing: SbSpacing.s12,
            children: <Widget>[
              dot,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SbText.body(
                      option.label,
                      role: disabled
                          ? SbColorRole.textTertiary
                          : SbColorRole.textPrimary,
                    ),
                    if (option.description != null) ...<Widget>[
                      const SizedBox(height: 2),
                      SbText.caption(
                        option.description!,
                        role: disabled
                            ? SbColorRole.textTertiary
                            : SbColorRole.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
