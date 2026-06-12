import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../divider/sb_divider.dart';

/// One selectable row in an [SbDropdown].
@immutable
class SbDropdownItem<T> {
  const SbDropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
  });

  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  /// Renders the row in the destructive color (e.g. "Delete").
  final bool destructive;
}

/// Anchored popup menu. Wraps a [trigger]; tapping it pushes a [PopupRoute]
/// that positions the menu relative to the trigger's [RenderBox], flips
/// above/below when needed, and clamps within screen bounds — correct on both
/// mobile and desktop without clipping.
class SbDropdown<T> extends StatefulWidget {
  const SbDropdown({
    super.key,
    required this.trigger,
    required this.items,
    required this.onSelected,
    this.menuWidth,
    this.offset = const Offset(0, SbSpacing.s4),
  });

  final Widget trigger;
  final List<SbDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final double? menuWidth;
  final Offset offset;

  @override
  State<SbDropdown<T>> createState() => _SbDropdownState<T>();
}

class _SbDropdownState<T> extends State<SbDropdown<T>> {
  bool _isOpen = false;

  void _open() {
    if (_isOpen) return;
    final button = context.findRenderObject()! as RenderBox;
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final rect = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    _isOpen = true;
    navigator
        .push(
          _SbMenuRoute<T>(
            position: rect,
            offset: widget.offset,
            items: widget.items,
            onSelected: widget.onSelected,
            menuWidth: widget.menuWidth,
          ),
        )
        .then((_) {
          if (mounted) _isOpen = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    return SbInteraction(
      onTap: _open,
      builder: (context, _, child) => child!,
      child: widget.trigger,
    );
  }
}

// ---------------------------------------------------------------------------
// Route
// ---------------------------------------------------------------------------

class _SbMenuRoute<T> extends PopupRoute<T> {
  _SbMenuRoute({
    required this.position,
    required this.offset,
    required this.items,
    required this.onSelected,
    this.menuWidth,
  });

  final RelativeRect position;
  final Offset offset;
  final List<SbDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final double? menuWidth;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => SbMotion.instant;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CustomSingleChildLayout(
      delegate: _MenuPositionDelegate(position: position, offset: offset),
      child: _MenuContent<T>(
        items: items,
        menuWidth: menuWidth,
        onSelected: (value) {
          Navigator.of(context).pop();
          onSelected(value);
        },
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: SbMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Position delegate
// ---------------------------------------------------------------------------

class _MenuPositionDelegate extends SingleChildLayoutDelegate {
  _MenuPositionDelegate({required this.position, required this.offset});

  final RelativeRect position;
  final Offset offset;

  static const double _margin = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(
        constraints.maxWidth - _margin * 2,
        constraints.maxHeight - _margin * 2,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final buttonLeft = position.left;
    final buttonTop = position.top;
    final buttonBottom = size.height - position.bottom;

    // x: align to button left edge, clamp so menu stays on-screen
    double x = buttonLeft + offset.dx;
    if (x + childSize.width > size.width - _margin) {
      x = size.width - childSize.width - _margin;
    }
    if (x < _margin) x = _margin;

    // y: prefer below button; flip above when not enough space below
    double y = buttonBottom + offset.dy;
    if (y + childSize.height > size.height - _margin) {
      y = buttonTop - childSize.height - offset.dy;
    }
    if (y < _margin) y = _margin;

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MenuPositionDelegate old) =>
      position != old.position || offset != old.offset;
}

// ---------------------------------------------------------------------------
// Menu content
// ---------------------------------------------------------------------------

class _MenuContent<T> extends StatelessWidget {
  const _MenuContent({
    required this.items,
    required this.onSelected,
    this.menuWidth,
  });

  final List<SbDropdownItem<T>> items;
  final ValueChanged<T> onSelected;
  final double? menuWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return ConstrainedBox(
      constraints: menuWidth != null
          ? BoxConstraints.tightFor(width: menuWidth)
          : const BoxConstraints(),
      child: IntrinsicWidth(
        child: SbSurface(
          color: colors.surface,
          borderColor: colors.border,
          borderRadius: SbRadius.all8,
          boxShadow: SbElevation.e3,
          padding: const EdgeInsets.symmetric(vertical: SbSpacing.s4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SbDivider(),
                  _DropdownRow<T>(item: items[i], onSelected: onSelected),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({required this.item, required this.onSelected});

  final SbDropdownItem<T> item;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      enabled: item.enabled,
      onTap: () => onSelected(item.value),
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return SbSurface(
          color: hovered ? colors.surfaceHover : null,
          borderRadius: SbRadius.all6,
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s12,
            vertical: SbSpacing.s8,
          ),
          child: Row(
            children: <Widget>[
              if (item.leading != null) ...[
                item.leading!,
                const SizedBox(width: SbSpacing.s8),
              ],
              Expanded(
                child: SbText.body(
                  item.label,
                  role: !item.enabled
                      ? SbColorRole.textTertiary
                      : (item.destructive
                            ? SbColorRole.destructive
                            : SbColorRole.textPrimary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
