import 'package:flutter/widgets.dart';

import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_spacing.dart';

/// A centered placeholder for empty screens/lists: an optional [icon], a
/// [title], an optional [description], and an optional [action] (e.g. a button).
class SbEmptyState extends StatelessWidget {
  const SbEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SbSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              SizedBox(width: 40, height: 40, child: icon),
              const SizedBox(height: SbSpacing.s16),
            ],
            SbText(
              title,
              variant: SbTextVariant.title,
              align: TextAlign.center,
            ),
            if (description != null) ...<Widget>[
              const SizedBox(height: SbSpacing.s8),
              SbText.body(
                description!,
                role: SbColorRole.textSecondary,
                align: TextAlign.center,
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: SbSpacing.s24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
