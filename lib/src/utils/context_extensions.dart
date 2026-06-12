import 'package:flutter/material.dart';

import '../theme/sb_theme.dart';
import '../theme/sb_theme_extensions.dart';

/// Ergonomic theme access: `context.sb` and `context.sbColors`.
extension SbContext on BuildContext {
  /// The active [SbTheme]. Asserts the extension is installed (use
  /// `SbAppTheme.light()/dark()` on your `MaterialApp`).
  SbTheme get sb {
    final theme = Theme.of(this).extension<SbTheme>();
    assert(
      theme != null,
      'SbTheme is missing. Use SbAppTheme.light()/dark() in your MaterialApp.',
    );
    return theme!;
  }

  /// Shortcut to the active color roles.
  SbColorScheme get sbColors => sb.colors;
}
