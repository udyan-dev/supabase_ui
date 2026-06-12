import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// A circular floating action button: brand-filled, elevated, with a centered
/// [child] (typically an icon). Tinted darker on hover/press.
class SbFab extends StatelessWidget {
  const SbFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 56,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      onTap: onPressed,
      enabled: onPressed != null,
      builder: (context, states, _) {
        final pressed = states.contains(WidgetState.pressed);
        final hovered = states.contains(WidgetState.hovered);
        final bg = pressed
            ? colors.primaryActive
            : (hovered ? colors.primaryHover : colors.primary);
        return SbSurface(
          width: size,
          height: size,
          color: bg,
          borderRadius: SbRadius.full,
          boxShadow: SbElevation.e3,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
