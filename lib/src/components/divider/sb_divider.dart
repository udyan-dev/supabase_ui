import 'package:flutter/widgets.dart';

import '../../utils/context_extensions.dart';

/// Hairline separator, horizontal or vertical, drawn with the border role.
class SbDivider extends StatelessWidget {
  const SbDivider({super.key, this.indent = 0, this.endIndent = 0})
      : _axis = Axis.horizontal;

  const SbDivider.vertical({super.key, this.indent = 0, this.endIndent = 0})
      : _axis = Axis.vertical;

  final Axis _axis;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final color = context.sbColors.border;
    if (_axis == Axis.horizontal) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: SizedBox(
          height: 1,
          child: DecoratedBox(decoration: BoxDecoration(color: color)),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: indent, bottom: endIndent),
      child: SizedBox(
        width: 1,
        child: DecoratedBox(decoration: BoxDecoration(color: color)),
      ),
    );
  }
}
