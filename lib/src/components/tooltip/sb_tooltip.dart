import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Lightweight tooltip shown on hover (desktop) or long-press (touch).
/// Mounts its overlay only while visible via [OverlayPortal].
class SbTooltip extends StatefulWidget {
  const SbTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 400),
  });

  final String message;
  final Widget child;
  final Duration waitDuration;

  @override
  State<SbTooltip> createState() => _SbTooltipState();
}

class _SbTooltipState extends State<SbTooltip> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();
  Timer? _timer;

  void _scheduleShow() {
    _timer?.cancel();
    _timer = Timer(widget.waitDuration, _controller.show);
  }

  void _hide() {
    _timer?.cancel();
    _controller.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _hide(),
        child: GestureDetector(
          onLongPress: _controller.show,
          onLongPressUp: _hide,
          child: OverlayPortal(
            controller: _controller,
            overlayChildBuilder: (context) =>
                _TooltipBubble(link: _link, message: widget.message),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.link, required this.message});

  final LayerLink link;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return CompositedTransformFollower(
      link: link,
      targetAnchor: Alignment.topCenter,
      followerAnchor: Alignment.bottomCenter,
      offset: const Offset(0, -SbSpacing.s8),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: IgnorePointer(
            child: SbSurface(
              color: colors.textPrimary,
              borderRadius: SbRadius.all6,
              boxShadow: SbElevation.e2,
              padding: const EdgeInsets.symmetric(
                horizontal: SbSpacing.s8,
                vertical: SbSpacing.s4,
              ),
              child: SbText.caption(message, role: SbColorRole.textInverse),
            ),
          ),
        ),
      ),
    );
  }
}
