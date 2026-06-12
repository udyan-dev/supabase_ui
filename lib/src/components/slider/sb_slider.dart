import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../utils/context_extensions.dart';

/// A horizontal slider for selecting a value in [[min], [max]].
///
/// Controlled: pass [value] and handle [onChanged]. Pass `null` for [onChanged]
/// to render disabled.
class SbSlider extends StatefulWidget {
  const SbSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.height = 24,
  }) : assert(max > min);

  final double value;
  final ValueChanged<double>? onChanged;

  /// Fired once when a drag/tap gesture ends, with the last emitted value.
  /// Use this to commit expensive side effects (e.g. a network seek)
  /// instead of reacting to every [onChanged] call during a drag.
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final double height;

  @override
  State<SbSlider> createState() => _SbSliderState();
}

class _SbSliderState extends State<SbSlider> {
  static const double _thumb = 18;
  static const double _track = 6;

  late double _current = widget.value;

  @override
  void didUpdateWidget(SbSlider old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _current = widget.value;
  }

  double get _t =>
      ((_current - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _emit(double localX, double width) {
    final usable = width - _thumb;
    final frac = usable <= 0
        ? 0.0
        : ((localX - _thumb / 2) / usable).clamp(0.0, 1.0);
    final double next = widget.min + frac * (widget.max - widget.min);
    setState(() => _current = next);
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final bool enabled = widget.onChanged != null;
    final fill = enabled ? colors.primary : colors.borderStrong;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final usable = width - _thumb;
        final thumbX = _thumb / 2 + _t * usable;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (d) => _emit(d.localPosition.dx, width) : null,
          onTapUp: enabled ? (_) => widget.onChangeEnd?.call(_current) : null,
          onHorizontalDragUpdate:
              enabled ? (d) => _emit(d.localPosition.dx, width) : null,
          onHorizontalDragEnd: enabled
              ? (_) => widget.onChangeEnd?.call(_current)
              : null,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                // Track.
                SbSurface(
                  height: _track,
                  color: colors.surfaceActive,
                  borderRadius: SbRadius.full,
                ),
                // Filled portion.
                SbSurface(
                  width: thumbX,
                  height: _track,
                  color: fill,
                  borderRadius: SbRadius.full,
                ),
                // Thumb.
                Positioned(
                  left: thumbX - _thumb / 2,
                  child: SbSurface(
                    width: _thumb,
                    height: _thumb,
                    color: colors.surface,
                    borderColor: fill,
                    borderWidth: 2,
                    borderRadius: SbRadius.full,
                    boxShadow: SbElevation.e1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
