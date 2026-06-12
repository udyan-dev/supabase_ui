import 'package:flutter/widgets.dart';

/// Builder that receives the current interaction states.
typedef SbInteractionBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child,
);

/// The single interaction primitive: hover / focus / pressed / disabled state
/// tracking for every interactive component (button, input, checkbox, tabs,
/// dropdown item, …). Components describe how they *look* per state via
/// [builder]; they never re-implement pointer/focus plumbing.
///
/// Rebuilds only when the state set actually changes.
class SbInteraction extends StatefulWidget {
  const SbInteraction({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.child,
  });

  final SbInteractionBuilder builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool canRequestFocus;

  /// Optional cached subtree passed through to [builder] (build-once child).
  final Widget? child;

  @override
  State<SbInteraction> createState() => _SbInteractionState();
}

class _SbInteractionState extends State<SbInteraction> {
  final Set<WidgetState> _states = <WidgetState>{};

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _update(WidgetState state, bool active) {
    final changed = active ? _states.add(state) : _states.remove(state);
    if (changed) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Recompute the disabled flag without triggering an extra setState.
    final states = <WidgetState>{
      ..._states,
      if (!widget.enabled) WidgetState.disabled,
    };

    final cursor = widget.mouseCursor ??
        (_interactive
            ? SystemMouseCursors.click
            : (widget.enabled
                ? MouseCursor.defer
                : SystemMouseCursors.forbidden));

    Widget result = widget.builder(context, states, widget.child);

    result = GestureDetector(
      onTap: _interactive ? widget.onTap : null,
      onLongPress: _interactive ? widget.onLongPress : null,
      onTapDown:
          _interactive ? (_) => _update(WidgetState.pressed, true) : null,
      onTapUp: _interactive ? (_) => _update(WidgetState.pressed, false) : null,
      onTapCancel:
          _interactive ? () => _update(WidgetState.pressed, false) : null,
      behavior: HitTestBehavior.opaque,
      child: result,
    );

    result = MouseRegion(
      cursor: cursor,
      onEnter: (_) => _update(WidgetState.hovered, true),
      onExit: (_) => _update(WidgetState.hovered, false),
      child: result,
    );

    result = Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.canRequestFocus && _interactive,
      onFocusChange: (focused) => _update(WidgetState.focused, focused),
      child: result,
    );

    return result;
  }
}
