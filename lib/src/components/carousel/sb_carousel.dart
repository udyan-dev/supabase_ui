import 'package:flutter/widgets.dart';

import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// A swipeable, paged carousel with dot indicators. [items] are laid out
/// horizontally; the active page is reflected in the indicator row.
class SbCarousel extends StatefulWidget {
  const SbCarousel({
    super.key,
    required this.items,
    this.height = 180,
    this.onPageChanged,
    this.showIndicators = true,
  }) : assert(items.length > 0);

  final List<Widget> items;
  final double height;
  final ValueChanged<int>? onPageChanged;
  final bool showIndicators;

  @override
  State<SbCarousel> createState() => _SbCarouselState();
}

class _SbCarouselState extends State<SbCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  void _onChanged(int i) {
    setState(() => _page = i);
    widget.onPageChanged?.call(i);
  }

  void _goTo(int i) => _controller.animateToPage(
        i,
        duration: SbMotion.slow,
        curve: SbMotion.emphasized,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: widget.height,
          child: PageView(
            controller: _controller,
            onPageChanged: _onChanged,
            children: widget.items,
          ),
        ),
        if (widget.showIndicators && widget.items.length > 1) ...<Widget>[
          const SizedBox(height: SbSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < widget.items.length; i++)
                _Dot(active: i == _page, onTap: () => _goTo(i)),
            ],
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SbSpacing.s4),
        child: AnimatedContainer(
          duration: SbMotion.fast,
          curve: SbMotion.standard,
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? colors.primary : colors.surfaceActive,
            borderRadius: SbRadius.full,
          ),
        ),
      ),
    );
  }
}
