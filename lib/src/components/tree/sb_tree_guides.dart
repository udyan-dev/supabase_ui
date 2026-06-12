import 'package:flutter/widgets.dart';

/// Paints the `├─ └─ │` connector guides for one tree row. Shared by
/// [SbTreeView] and [SbCheckableTreeView]; not part of the public API.
///
/// Geometry: each depth occupies an [indent]-wide band whose line sits at the
/// band's horizontal centre. Ancestor bands draw a full-height vertical where
/// the branch continues to a later sibling; the deepest band draws the
/// connector itself — a top→centre stem, a centre→content horizontal arm, and
/// (unless this is the last child) a centre→bottom continuation.
///
/// [ancestorIsLast] records, for each ancestor level (depth 0 → parent),
/// whether that ancestor was its parent's last child. That single bit per
/// level is everything the painter needs.
class SbTreeGuidePainter extends CustomPainter {
  const SbTreeGuidePainter({
    required this.depth,
    required this.ancestorIsLast,
    required this.isLast,
    required this.indent,
    required this.color,
  });

  final int depth;
  final List<bool> ancestorIsLast;
  final bool isLast;
  final double indent;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final double half = indent / 2;
    final double cy = size.height / 2;

    for (int band = 0; band < depth; band++) {
      final double x = band * indent + half;
      if (band == depth - 1) {
        canvas.drawLine(Offset(x, 0), Offset(x, cy), paint); // stem
        canvas.drawLine(Offset(x, cy), Offset(x + half, cy), paint); // arm
        if (!isLast) {
          canvas.drawLine(Offset(x, cy), Offset(x, size.height), paint);
        }
      } else if (!ancestorIsLast[band + 1]) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(SbTreeGuidePainter old) =>
      depth != old.depth ||
      isLast != old.isLast ||
      indent != old.indent ||
      color != old.color ||
      !_listEquals(ancestorIsLast, old.ancestorIsLast);

  static bool _listEquals(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
