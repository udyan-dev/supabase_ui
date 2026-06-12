import 'package:flutter/material.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Shows a single transient snackbar pinned to the bottom: a high-contrast bar
/// with a [message] and an optional action. Slides up + fades in
/// (native [ScaffoldMessenger] motion) and auto-dismisses after [duration].
///
/// Requires a [Scaffold] ancestor, as provided by [MaterialApp].
void showSbSnackbar(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final colors = context.sbColors;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(SbSpacing.s16),
      shape: const RoundedRectangleBorder(borderRadius: SbRadius.all8),
      content: SbSurface(
        // Inverted high-contrast bar (classic snackbar look).
        color: colors.textPrimary,
        borderRadius: SbRadius.all8,
        boxShadow: SbElevation.e3,
        padding: const EdgeInsets.symmetric(
          horizontal: SbSpacing.s16,
          vertical: SbSpacing.s12,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: SbText.body(message, role: SbColorRole.background)),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(width: SbSpacing.s16),
              SbInteraction(
                onTap: () {
                  onAction?.call();
                  messenger.hideCurrentSnackBar();
                },
                builder: (context, _, _) => SbText(
                  actionLabel,
                  variant: SbTextVariant.bodyStrong,
                  role: SbColorRole.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
