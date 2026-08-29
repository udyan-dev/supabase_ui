import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import 'sb_button_style.dart';

export 'sb_button_style.dart' show SbButtonVariant, SbButtonSize;

/// Token-driven button with variants, sizes, and full interaction states.
///
/// All color/state logic lives in [resolveButtonVisual]; this widget only wires
/// the interaction primitive to a surface + label.
class SbButton extends StatelessWidget {
  const SbButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SbButtonVariant.primary,
    this.size = SbButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.fullWidth = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SbButtonVariant variant;
  final SbButtonSize size;

  /// Optional leading/trailing slots (e.g. icons via `VectorGraphic`).
  final Widget? leading;
  final Widget? trailing;

  final bool loading;
  final bool fullWidth;
  final bool isExpanded;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    return SbInteraction(
      enabled: _enabled,
      onTap: onPressed,
      builder: (context, states, _) {
        final visual = resolveButtonVisual(
          variant: variant,
          colors: colors,
          hovered: states.contains(WidgetState.hovered),
          pressed: states.contains(WidgetState.pressed),
          disabled: states.contains(WidgetState.disabled),
        );

        final textStyle = size.textStyle.copyWith(
          color: visual.foreground,
          height: 1,
        );

        final Widget content = loading
            ? _Spinner(color: visual.foreground, size: size.iconSize)
            : DefaultTextStyle(
                style: textStyle,
                child: _ButtonRow(
                  label: label,
                  leading: leading,
                  trailing: trailing,
                  isExpanded: isExpanded,
                ),
              );

        final button = SbSurface(
          color: visual.background,
          borderColor: visual.borderColor,
          borderRadius: size.radius,
          padding: size.padding,
          constraints: BoxConstraints(minHeight: size.minHeight),
          child: Center(widthFactor: 1, heightFactor: 1, child: content),
        );

        return fullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button;
      },
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.label,
    this.leading,
    this.trailing,
    this.isExpanded = false,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: SbSpacing.s8,
        children: <Widget>[
          if (leading != null) ...[leading!],
          if (label.isNotEmpty)
            Expanded(
              child: SbText(
                label,
                variant: SbTextVariant.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (trailing != null) ...[trailing!],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: SbSpacing.s8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (leading != null) ...[leading!],
        if (label.isNotEmpty)
          Flexible(
            child: SbText(
              label,
              variant: SbTextVariant.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (trailing != null) ...[trailing!],
      ],
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SbMotion.slow,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(painter: _SpinnerPainter(widget.color)),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    final rect = Offset.zero & size;
    // 270° arc.
    canvas.drawArc(rect.deflate(1), 0, 4.71, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => oldDelegate.color != color;
}
