import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_typography.dart';
import '../../utils/context_extensions.dart';

enum SbAvatarSize { sm, md, lg, xl }

enum SbAvatarShape { circle, square }

extension on SbAvatarSize {
  double get dimension {
    switch (this) {
      case SbAvatarSize.sm:
        return 24;
      case SbAvatarSize.md:
        return 32;
      case SbAvatarSize.lg:
        return 40;
      case SbAvatarSize.xl:
        return 56;
    }
  }
}

/// User avatar: renders an image when [image] is supplied, otherwise the
/// initials derived from [name], otherwise a neutral fallback.
class SbAvatar extends StatelessWidget {
  const SbAvatar({
    super.key,
    this.image,
    this.name,
    this.size = SbAvatarSize.md,
    this.shape = SbAvatarShape.circle,
  });

  final ImageProvider? image;
  final String? name;
  final SbAvatarSize size;
  final SbAvatarShape shape;

  String get _initials {
    final n = name?.trim() ?? '';
    if (n.isEmpty) return '';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1).toString() +
            parts.last.characters.take(1).toString())
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final dim = size.dimension;
    final radius =
        shape == SbAvatarShape.circle ? SbRadius.full : SbRadius.all8;

    final fallback = Center(
      child: Text(
        _initials,
        style: SbTypography.caption.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w500, // CustomFont Medium (no 600 face)
          fontSize: dim * 0.4,
          height: 1,
        ),
      ),
    );

    final Widget child;
    if (image != null) {
      // Native Image with built-in error/loading handling: fall back to
      // initials if the image fails, and fade in once decoded.
      child = Image(
        image: image!,
        fit: BoxFit.cover,
        width: dim,
        height: dim,
        errorBuilder: (context, error, stackTrace) => fallback,
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync || frame != null) return child;
          return fallback;
        },
      );
    } else {
      child = fallback;
    }

    return SbSurface(
      width: dim,
      height: dim,
      color: colors.surfaceActive,
      borderColor: colors.border,
      borderRadius: radius,
      clipChildren: true,
      child: child,
    );
  }
}
