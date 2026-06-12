import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../input/sb_text_field.dart';

/// A search bar: a single-line text field with a leading magnifier and a clear
/// affordance that appears once there's input. Built on [SbTextField], so it
/// inherits the design system's focus ring and token styling.
class SbSearchField extends StatefulWidget {
  const SbSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.prefix,
    this.suffix,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;

  @override
  State<SbSearchField> createState() => _SbSearchFieldState();
}

class _SbSearchFieldState extends State<SbSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final hasText = _controller.text.isNotEmpty;

    return SbTextField(
      controller: _controller,
      hint: widget.hint,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      prefix: widget.prefix ?? _Magnifier(color: colors.textTertiary),
      suffix: hasText
          ? SbInteraction(
              onTap: _clear,
              builder: (context, _, _) =>
                  widget.suffix ?? _Clear(color: colors.textTertiary),
            )
          : null,
    );
  }
}

class _Magnifier extends StatelessWidget {
  const _Magnifier({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    height: 16,
    child: CustomPaint(painter: _MagnifierPainter(color)),
  );
}

class _MagnifierPainter extends CustomPainter {
  const _MagnifierPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final r = size.width * 0.34;
    final center = Offset(size.width * 0.42, size.height * 0.42);
    canvas.drawCircle(center, r, paint);
    final start = Offset(center.dx + r * 0.7, center.dy + r * 0.7);
    canvas.drawLine(start, Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_MagnifierPainter old) => old.color != color;
}

class _Clear extends StatelessWidget {
  const _Clear({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(SbSpacing.s4),
    child: SizedBox(
      width: 12,
      height: 12,
      child: CustomPaint(painter: _ClearPainter(color)),
    ),
  );
}

class _ClearPainter extends CustomPainter {
  const _ClearPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_ClearPainter old) => old.color != color;
}
