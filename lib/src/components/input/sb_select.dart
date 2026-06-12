import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../dropdown/sb_dropdown.dart';

/// One option in an [SbSelect].
@immutable
class SbSelectOption<T> {
  const SbSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Single-select field. Reuses [SbDropdown] for the popup menu so menu styling
/// and dismissal live in one place.
class SbSelect<T> extends StatelessWidget {
  const SbSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder = 'Select…',
    this.enabled = true,
  });

  final List<SbSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    SbSelectOption<T>? selected;
    if (value != null) {
      for (final o in options) {
        if (o.value == value) {
          selected = o;
          break;
        }
      }
    }

    final field = SbInteraction(
      enabled: enabled,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return SbSurface(
          color: enabled ? colors.surface : colors.surfaceActive,
          borderColor: hovered ? colors.borderStrong : colors.border,
          borderRadius: SbRadius.all8,
          padding: const EdgeInsets.symmetric(
            horizontal: SbSpacing.s12,
            vertical: SbSpacing.s12,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SbText.body(
                  selected?.label ?? placeholder,
                  role: selected == null
                      ? SbColorRole.textTertiary
                      : SbColorRole.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SbSpacing.s8),
              _Chevron(color: colors.textSecondary),
            ],
          ),
        );
      },
    );

    final body = enabled && onChanged != null
        ? SbDropdown<T>(
            trigger: field,
            items: <SbDropdownItem<T>>[
              for (final o in options)
                SbDropdownItem<T>(value: o.value, label: o.label),
            ],
            onSelected: onChanged!,
          )
        : field;

    if (label == null) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SbText(label!, variant: SbTextVariant.bodyStrong),
        const SizedBox(height: SbSpacing.s8),
        body,
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: const Size(12, 8), painter: _ChevronPainter(color));
  }
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
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width / 2, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.25);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
