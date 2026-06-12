import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../divider/sb_divider.dart';

/// A single accordion section.
@immutable
class SbAccordionItem {
  const SbAccordionItem({required this.title, required this.content});

  final String title;
  final Widget content;
}

/// A vertical stack of expandable sections inside one bordered surface.
///
/// By default multiple sections may be open; set [single] for exclusive
/// (one-at-a-time) behavior.
class SbAccordion extends StatefulWidget {
  const SbAccordion({
    super.key,
    required this.items,
    this.single = false,
    this.initialOpen = const <int>{},
  });

  final List<SbAccordionItem> items;
  final bool single;
  final Set<int> initialOpen;

  @override
  State<SbAccordion> createState() => _SbAccordionState();
}

class _SbAccordionState extends State<SbAccordion> {
  late final Set<int> _open = <int>{...widget.initialOpen};

  void _toggle(int i) {
    setState(() {
      if (_open.contains(i)) {
        _open.remove(i);
      } else {
        if (widget.single) _open.clear();
        _open.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbSurface(
      color: colors.surface,
      borderColor: colors.border,
      borderRadius: SbRadius.all8,
      clipChildren: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < widget.items.length; i++) ...<Widget>[
            if (i > 0) const SbDivider(),
            _Section(
              item: widget.items[i],
              open: _open.contains(i),
              onTap: () => _toggle(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.item,
    required this.open,
    required this.onTap,
  });

  final SbAccordionItem item;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SbInteraction(
          onTap: onTap,
          builder: (context, states, _) {
            final hovered = states.contains(WidgetState.hovered);
            return SbSurface(
              color: hovered ? colors.surfaceHover : colors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.s16,
                vertical: SbSpacing.s12,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SbText(item.title, variant: SbTextVariant.bodyStrong),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: SbMotion.fast,
                    child: _Chevron(color: colors.textTertiary),
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedSize(
          duration: SbMotion.fast,
          curve: SbMotion.easeOut, // Supabase accordion: .15s ease-out
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SbSpacing.s16,
                    0,
                    SbSpacing.s16,
                    SbSpacing.s16,
                  ),
                  child: DefaultTextStyle.merge(
                    child: item.content,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// A small downward chevron drawn without an icon dependency.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 8,
      child: CustomPaint(painter: _ChevronPainter(color)),
    );
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
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
