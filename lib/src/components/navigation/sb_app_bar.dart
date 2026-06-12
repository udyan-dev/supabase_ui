import 'package:flutter/material.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// A top app bar: a bottom-bordered surface with an optional [leading] widget,
/// a [title], and trailing [actions]. Honors the top safe area. Use as the top
/// of a screen body (it is not tied to Material's Scaffold).
class SbAppBar extends StatelessWidget {
  const SbAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const <Widget>[],
    this.centerTitle = false,
    this.showBorder = true,
    this.padding,
    this.showTitle = true,
  });

  final String? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool showBorder;
  final Widget? titleWidget;
  final EdgeInsets? padding;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final centerWidget =
        titleWidget ??
        SbText(title ?? "", variant: SbTextVariant.title, maxLines: 1);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: SbSurface(
          color: colors.background,
          border: showBorder
              ? Border(bottom: BorderSide(color: colors.border))
              : null,
          child: Padding(
            padding:
                padding ??
                EdgeInsets.only(
                  right: SbSpacing.s16,
                  left: leading != null ? 0 : SbSpacing.s16,
                ),
            child: Row(
              children: <Widget>[
                ?leading,
                if (showTitle)
                  Flexible(
                    child: Align(
                      alignment: centerTitle
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: centerWidget,
                    ),
                  ),
                for (final action in actions) ...<Widget>[action],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
