import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Page navigation: previous/next arrows plus numbered page buttons, with
/// ellipsis truncation for large ranges. [currentPage] is 1-based.
class SbPagination extends StatelessWidget {
  const SbPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onChanged,
  }) : assert(currentPage >= 1 && currentPage <= totalPages);

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onChanged;

  /// Pages to render: 1, last, current±1, with `0` marking an ellipsis gap.
  List<int> get _pages {
    final pages = <int>{1, totalPages, currentPage};
    if (currentPage - 1 >= 1) pages.add(currentPage - 1);
    if (currentPage + 1 <= totalPages) pages.add(currentPage + 1);
    final sorted = pages.toList()..sort();
    final out = <int>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(0); // gap
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ArrowButton(
          back: true,
          enabled: currentPage > 1,
          onTap: () => onChanged(currentPage - 1),
        ),
        const SizedBox(width: SbSpacing.s4),
        for (final p in _pages) ...<Widget>[
          if (p == 0)
            const _Ellipsis()
          else
            _PageButton(
              page: p,
              selected: p == currentPage,
              onTap: () => onChanged(p),
            ),
          const SizedBox(width: SbSpacing.s4),
        ],
        _ArrowButton(
          back: false,
          enabled: currentPage < totalPages,
          onTap: () => onChanged(currentPage + 1),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      onTap: onTap,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return SbSurface(
          width: 32,
          height: 32,
          color: selected
              ? colors.surfaceActive
              : (hovered ? colors.surfaceHover : null),
          borderColor: selected ? colors.borderStrong : null,
          borderRadius: SbRadius.all6,
          child: Center(
            child: SbText(
              '$page',
              variant: SbTextVariant.bodyStrong,
              role: selected
                  ? SbColorRole.textPrimary
                  : SbColorRole.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 32,
        height: 32,
        child: Center(child: SbText.caption('…')),
      );
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.back,
    required this.enabled,
    required this.onTap,
  });

  final bool back;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      enabled: enabled,
      onTap: onTap,
      builder: (context, states, _) {
        final hovered = enabled && states.contains(WidgetState.hovered);
        return SbSurface(
          width: 32,
          height: 32,
          color: hovered ? colors.surfaceHover : null,
          borderRadius: SbRadius.all6,
          child: Center(
            child: _Chevron(
              back: back,
              color: enabled ? colors.textSecondary : colors.textTertiary,
            ),
          ),
        );
      },
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.back, required this.color});

  final bool back;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 8,
        height: 12,
        child: CustomPaint(painter: _ChevronPainter(back: back, color: color)),
      );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.back, required this.color});

  final bool back;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    if (back) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height / 2)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.back != back || old.color != color;
}
