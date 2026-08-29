import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Which edge an [SbSideSheet] slides in from.
enum SbSheetSide { left, right }

/// Shows a token-styled side sheet (drawer/panel) sliding in from [side] with a
/// scrim, using Supabase's panel-slide motion (`cubic-bezier(.87,0,.13,1)`).
Future<T?> showSbSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SbSheetSide side = SbSheetSide.right,
  bool barrierDismissible = true,
}) {
  final overlayColor = context.sb.colors.overlay;
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SbSideSheetRoute<T>(
      builder: builder,
      side: side,
      barrierDismissible: barrierDismissible,
      barrierColor: overlayColor,
    ),
  );
}

class _SbSideSheetRoute<T> extends PopupRoute<T> {
  _SbSideSheetRoute({
    required this.builder,
    required this.side,
    required this.barrierDismissible,
    required Color barrierColor,
  }) : _barrierColor = barrierColor;
  // ignore_for_file: prefer_initializing_formals

  final WidgetBuilder builder;
  final SbSheetSide side;

  @override
  final bool barrierDismissible;

  final Color _barrierColor;

  @override
  Color get barrierColor => _barrierColor;

  @override
  String? get barrierLabel => 'Dismiss';

  // Supabase panel: .25s in (.2s out); use the longer for both directions.
  @override
  Duration get transitionDuration => SbMotion.panel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: side == SbSheetSide.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final dx = side == SbSheetSide.right ? 1.0 : -1.0;
    final curved = CurvedAnimation(
      parent: animation,
      curve: SbMotion.emphasized,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(dx, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

/// Default side-sheet container: a full-height surface (default 86% width,
/// capped at 420) with an optional [title] and [child] content.
class SbSideSheet extends StatelessWidget {
  const SbSideSheet({
    super.key,
    this.title,
    required this.child,
    this.width,
    this.leading,
  });

  final String? title;
  final Widget child;
  final double? width;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final media = MediaQuery.sizeOf(context);
    final w = width ?? (media.width * 0.86).clamp(280.0, 420.0);

    return SbSurface(
      width: w,
      color: colors.surface,
      borderColor: colors.border,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SbSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                spacing: SbSpacing.s16,
                children: [
                  ?leading,
                  if (title != null) ...<Widget>[
                    SbText(title!, variant: SbTextVariant.heading),
                    const SizedBox(height: SbSpacing.s16),
                  ],
                ],
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
