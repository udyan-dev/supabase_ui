import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Controlled radio in a group keyed by [value]/[groupValue].
class SbRadio<T> extends StatelessWidget {
  const SbRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;

  bool get _selected => value == groupValue;
  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbInteraction(
      enabled: _enabled,
      onTap: _enabled ? () => onChanged!(value) : null,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        final disabled = states.contains(WidgetState.disabled);
        final accent = disabled ? colors.textTertiary : colors.primary;

        final dot = AnimatedContainer(
          duration: SbMotion.fast,
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: hovered && !_selected ? colors.surfaceHover : colors.surface,
            borderRadius: SbRadius.full,
            border: Border.all(
              color: _selected
                  ? accent
                  : (hovered ? colors.borderStrong : colors.border),
              width: _selected ? 5 : 1.5,
            ),
          ),
        );

        if (label == null) return dot;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            dot,
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
