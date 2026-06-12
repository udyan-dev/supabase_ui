import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// Controlled on/off switch. `onChanged == null` disables it.
class SbSwitch extends StatelessWidget {
  const SbSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  bool get _enabled => onChanged != null;

  static const double _w = 40;
  static const double _h = 22;
  static const double _thumb = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbInteraction(
      enabled: _enabled,
      onTap: _enabled ? () => onChanged!(!value) : null,
      builder: (context, states, _) {
        final disabled = states.contains(WidgetState.disabled);
        final trackOn = disabled ? colors.textTertiary : colors.primary;
        final trackOff = colors.surfaceActive;

        return AnimatedContainer(
          duration: SbMotion.fast,
          curve: SbMotion.standard,
          width: _w,
          height: _h,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? trackOn : trackOff,
            borderRadius: SbRadius.full,
          ),
          child: AnimatedAlign(
            duration: SbMotion.fast,
            curve: SbMotion.standard,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: SbSurface(
              width: _thumb,
              height: _thumb,
              color: colors.surface,
              borderRadius: SbRadius.full,
            ),
          ),
        );
      },
    );
  }
}
