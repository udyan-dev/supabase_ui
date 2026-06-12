import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Shows a centered, token-styled modal with a scrim and scale/fade transition.
Future<T?> showSbModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final overlayColor = context.sb.colors.overlay;
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SbModalRoute<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: overlayColor,
    ),
  );
}

class _SbModalRoute<T> extends PopupRoute<T> {
  // `_barrierColor` is private to back the `barrierColor` getter override.
  _SbModalRoute({
    required this.builder,
    required this.barrierDismissible,
    required Color barrierColor,
  }) : _barrierColor = barrierColor;
  // ignore_for_file: prefer_initializing_formals

  final WidgetBuilder builder;

  @override
  final bool barrierDismissible;

  final Color _barrierColor;

  @override
  Color get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => SbMotion.slow;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SbSpacing.s24),
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Supabase `overlayContentShow`: fade in + slide down from translateY(-2%).
    final curved = CurvedAnimation(parent: animation, curve: SbMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Standard modal scaffold: title, content, and an actions row.
class SbModal extends StatelessWidget {
  const SbModal({
    super.key,
    this.title,
    required this.child,
    this.actions = const <Widget>[],
    this.width = 420,
  });

  final String? title;
  final Widget child;
  final List<Widget> actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: SbSurface(
        color: context.sbColors.surface,
        borderColor: context.sbColors.border,
        borderRadius: SbRadius.all12,
        boxShadow: SbElevation.e4,
        padding: const EdgeInsets.all(SbSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SbSpacing.s16,
          children: <Widget>[
            if (title != null) ...[SbText.title(title!)],
            // Long content scrolls natively within the modal's max height.
            Flexible(child: SingleChildScrollView(child: child)),
            if (actions.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: SbSpacing.s8),
                    actions[i],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
