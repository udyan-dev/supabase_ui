import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../checkbox/sb_checkbox.dart';
import '../chip/sb_chip.dart';
import 'sb_select.dart';

/// A select that allows multiple values. The field shows the current selection
/// as removable chips; an anchored popup lists every option with a checkbox.
class SbMultiSelect<T> extends StatefulWidget {
  const SbMultiSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select…',
  });

  final List<SbSelectOption<T>> options;
  final List<T> value;
  final ValueChanged<List<T>> onChanged;
  final String? label;
  final String hint;

  @override
  State<SbMultiSelect<T>> createState() => _SbMultiSelectState<T>();
}

class _SbMultiSelectState<T> extends State<SbMultiSelect<T>> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _toggle(T v) {
    final next = <T>[...widget.value];
    next.contains(v) ? next.remove(v) : next.add(v);
    widget.onChanged(next);
  }

  String _labelOf(T v) =>
      widget.options.firstWhere((o) => o.value == v).label;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final selected = widget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          SbText.caption(widget.label!),
          const SizedBox(height: SbSpacing.s4),
        ],
        CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _controller,
            overlayChildBuilder: (context) => _Overlay<T>(
              link: _link,
              options: widget.options,
              selected: selected,
              onToggle: _toggle,
              onDismiss: _controller.hide,
            ),
            child: SbInteraction(
              onTap: _controller.toggle,
              builder: (context, states, _) {
                final focused = states.contains(WidgetState.focused);
                return SbSurface(
                  color: colors.surface,
                  borderColor: focused ? colors.primary : colors.border,
                  borderRadius: SbRadius.all8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SbSpacing.s12,
                    vertical: SbSpacing.s8,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: selected.isEmpty
                            ? SbText.body(widget.hint,
                                role: SbColorRole.textTertiary)
                            : Wrap(
                                spacing: SbSpacing.s4,
                                runSpacing: SbSpacing.s4,
                                children: <Widget>[
                                  for (final v in selected)
                                    SbChip(
                                      label: _labelOf(v),
                                      onDeleted: () => _toggle(v),
                                    ),
                                ],
                              ),
                      ),
                      _Chevron(color: colors.textTertiary),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Overlay<T> extends StatelessWidget {
  const _Overlay({
    required this.link,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onDismiss,
  });

  final LayerLink link;
  final List<SbSelectOption<T>> options;
  final List<T> selected;
  final ValueChanged<T> onToggle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(0, SbSpacing.s4),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 360),
              child: IntrinsicWidth(
                child: SbSurface(
                  color: colors.surface,
                  borderColor: colors.border,
                  borderRadius: SbRadius.all8,
                  boxShadow: SbElevation.e3,
                  padding: const EdgeInsets.all(SbSpacing.s8),
                  // Native scroll once the option list exceeds maxHeight.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final o in options)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: SbSpacing.s4),
                              child: SbCheckbox(
                                value: selected.contains(o.value),
                                label: o.label,
                                onChanged: (_) => onToggle(o.value),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 12,
        height: 8,
        child: CustomPaint(painter: _ChevronPainter(color)),
      );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
