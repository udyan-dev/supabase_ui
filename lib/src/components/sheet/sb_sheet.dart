import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Shows a token-styled bottom sheet that slides up from the bottom edge with a
/// scrim — the standard mobile modal surface. Returns the value the sheet is
/// popped with.
Future<T?> showSbSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final overlayColor = context.sb.colors.overlay;
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SbSheetRoute<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: overlayColor,
    ),
  );
}

class _SbSheetRoute<T> extends PopupRoute<T> {
  _SbSheetRoute({
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
  Duration get transitionDuration => SbMotion.panel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
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
    // Supabase `panelSlide` easing for the slide-up.
    final curved = CurvedAnimation(
      parent: animation,
      curve: SbMotion.emphasized,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

/// The default sheet container: a top-rounded surface with a drag handle, an
/// optional [title], and [child] content. Use inside [showSbSheet]'s builder.
class SbSheet extends StatelessWidget {
  const SbSheet({super.key, this.title, required this.child, this.textAlign});

  final String? title;
  final Widget child;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbSurface(
      color: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.all(SbSpacing.s16),
      borderRadius: const BorderRadius.vertical(top: SbRadius.r16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SbSpacing.s16,
          children: <Widget>[
            Center(
              child: SbSurface(
                width: 36,
                height: 4,
                color: colors.borderStrong,
                borderRadius: SbRadius.full,
              ),
            ),
            if (title != null)
              SbText(
                title!,
                variant: SbTextVariant.title,
                align: textAlign ?? TextAlign.center,
              ),
            // Long content scrolls natively within the sheet.
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
