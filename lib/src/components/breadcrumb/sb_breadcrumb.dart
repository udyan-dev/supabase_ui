import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// One crumb in an [SbBreadcrumb]. The last item renders as the current page
/// (high-contrast, non-interactive) regardless of [onTap].
@immutable
class SbBreadcrumbItem {
  const SbBreadcrumbItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

/// A breadcrumb trail: tappable ancestor crumbs separated by a chevron, ending
/// in the current page.
class SbBreadcrumb extends StatelessWidget {
  const SbBreadcrumb({super.key, required this.items});

  final List<SbBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SbSpacing.s8),
              child: _Separator(color: colors.textTertiary),
            ),
          _Crumb(item: items[i], isLast: i == items.length - 1),
        ],
      ],
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.item, required this.isLast});

  final SbBreadcrumbItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final text = SbText.body(
      item.label,
      role: isLast ? SbColorRole.textPrimary : SbColorRole.textSecondary,
    );
    if (isLast || item.onTap == null) return text;
    return SbInteraction(
      onTap: item.onTap,
      builder: (context, _, child) => child!,
      child: text,
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 6,
        height: 10,
        child: CustomPaint(painter: _SeparatorPainter(color)),
      );
}

class _SeparatorPainter extends CustomPainter {
  const _SeparatorPainter(this.color);

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
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SeparatorPainter old) => old.color != color;
}
