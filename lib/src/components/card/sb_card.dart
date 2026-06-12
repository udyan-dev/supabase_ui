import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../divider/sb_divider.dart';
import '../../utils/context_extensions.dart';

/// Surface container with optional header/footer slots separated by dividers.
class SbCard extends StatelessWidget {
  const SbCard({
    super.key,
    this.header,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.all(SbSpacing.s16),
    this.elevated = false,
  });

  final Widget? header;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;

  /// Raise with a soft shadow instead of a flat bordered surface.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbSurface(
      color: colors.surface,
      borderColor: elevated ? null : colors.border,
      borderRadius: SbRadius.all12,
      boxShadow: elevated ? SbElevation.e2 : SbElevation.e0,
      clipChildren: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (header != null) ...[
            Padding(padding: padding, child: header),
            const SbDivider(),
          ],
          Padding(padding: padding, child: child),
          if (footer != null) ...[
            const SbDivider(),
            Padding(padding: padding, child: footer),
          ],
        ],
      ),
    );
  }
}
