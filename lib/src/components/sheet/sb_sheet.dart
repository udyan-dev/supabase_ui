import 'package:flutter/material.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

const double _maxHeightFraction = 0.75;

Future<T?> showSbSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: barrierDismissible,
    enableDrag: barrierDismissible,
    backgroundColor: const Color(0x00000000),
    barrierColor: context.sb.colors.overlay,
    elevation: 0,
    clipBehavior: Clip.none,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFraction,
    ),
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        duration: SbMotion.slow,
        curve: SbMotion.standard,
        child: Builder(builder: builder),
      );
    },
  );
}

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
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
