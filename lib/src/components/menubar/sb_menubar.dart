import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../dropdown/sb_dropdown.dart';

/// One top-level menu in an [SbMenuBar].
///
/// Supply either [label] (text button) or [icon] (icon button) — at least one
/// is required.
@immutable
class SbMenu<T> {
  const SbMenu({this.label, this.icon, this.trailing, required this.items})
    : assert(
        label != null || icon != null,
        'SbMenu requires a label or an icon',
      );

  final String? label;
  final Widget? icon;
  final Widget? trailing;
  final List<SbDropdownItem<T>> items;
}

/// A horizontal bar of named menus, each opening an anchored popup. Built on
/// [SbDropdown]. All menus share the value type [T]; selections surface through
/// [onSelected].
///
/// The bar itself is borderless — each trigger shows a rounded hover surface
/// on pointer-over. Icon triggers are plain; label triggers render their text.
class SbMenuBar<T> extends StatelessWidget {
  const SbMenuBar({
    super.key,
    required this.menus,
    required this.onSelected,
    this.showBorder = false,
  });

  final List<SbMenu<T>> menus;
  final ValueChanged<T> onSelected;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final menu in menus)
          SbDropdown<T>(
            items: menu.items,
            onSelected: onSelected,
            trigger: _Trigger(
              label: menu.label,
              icon: menu.icon,
              trailing: menu.trailing,
              showBorder: showBorder,
            ),
          ),
      ],
    );
  }
}

/// Trigger button for a single [SbMenu]. Handles only visual hover state;
/// the tap is owned by the parent [SbDropdown]'s [SbInteraction].
class _Trigger extends StatefulWidget {
  const _Trigger({
    this.label,
    this.icon,
    this.trailing,
    this.showBorder = false,
  });

  final String? label;
  final Widget? icon;
  final Widget? trailing;
  final bool showBorder;

  @override
  State<_Trigger> createState() => _TriggerState();
}

class _TriggerState extends State<_Trigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final content =
        widget.icon ?? SbText(widget.label!, variant: SbTextVariant.bodyStrong);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SbSurface(
        color: _hovered ? colors.surfaceHover : null,
        borderRadius: SbRadius.all16,
        border: widget.showBorder
            ? Border.all(color: context.sbColors.border)
            : null,
        padding: const EdgeInsets.symmetric(
          horizontal: SbSpacing.s12,
          vertical: SbSpacing.s8,
        ),
        child: widget.trailing == null
            ? content
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  content,
                  const SizedBox(width: SbSpacing.s4),
                  widget.trailing!,
                ],
              ),
      ),
    );
  }
}
