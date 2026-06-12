import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_elevation.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// Supabase's semantic set: neutral, brand (positive), warning, destructive.
enum SbToastVariant { neutral, brand, warning, destructive }

/// Shows a transient toast anchored to the bottom of the nearest [Overlay].
/// Multiple toasts stack; each animates in and auto-dismisses.
void showSbToast(
  BuildContext context, {
  required String message,
  SbToastVariant variant = SbToastVariant.neutral,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _SbToastHost.of(overlay).push(
    message: message,
    variant: variant,
    duration: duration,
  );
}

class _ToastModel {
  _ToastModel({
    required this.id,
    required this.message,
    required this.variant,
  });

  final int id;
  final String message;
  final SbToastVariant variant;
  final GlobalKey<_ToastTileState> key = GlobalKey<_ToastTileState>();
}

/// One persistent overlay entry per [OverlayState] that renders the live toast
/// stack. Toasts are added/removed through it.
class _SbToastHost {
  _SbToastHost._(this._overlay) {
    _entry = OverlayEntry(
      builder: (context) => _ToastStack(notifier: _toasts),
    );
    _overlay.insert(_entry);
  }

  static final Map<OverlayState, _SbToastHost> _hosts =
      <OverlayState, _SbToastHost>{};

  static _SbToastHost of(OverlayState overlay) =>
      _hosts.putIfAbsent(overlay, () => _SbToastHost._(overlay));

  final OverlayState _overlay;
  late final OverlayEntry _entry;
  final ValueNotifier<List<_ToastModel>> _toasts =
      ValueNotifier<List<_ToastModel>>(<_ToastModel>[]);
  int _nextId = 0;

  void push({
    required String message,
    required SbToastVariant variant,
    required Duration duration,
  }) {
    final model =
        _ToastModel(id: _nextId++, message: message, variant: variant);
    _toasts.value = <_ToastModel>[..._toasts.value, model];
    Timer(duration, () => _dismiss(model));
  }

  Future<void> _dismiss(_ToastModel model) async {
    await model.key.currentState?.animateOut();
    final next = _toasts.value.where((m) => m.id != model.id).toList();
    _toasts.value = next;
    if (next.isEmpty) {
      _entry.remove();
      _hosts.remove(_overlay);
      _toasts.dispose();
    }
  }
}

class _ToastStack extends StatelessWidget {
  const _ToastStack({required this.notifier});

  final ValueNotifier<List<_ToastModel>> notifier;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: SbSpacing.s24,
      child: SafeArea(
        child: ValueListenableBuilder<List<_ToastModel>>(
          valueListenable: notifier,
          builder: (context, toasts, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final t in toasts)
                Padding(
                  key: ValueKey<int>(t.id),
                  padding: const EdgeInsets.only(top: SbSpacing.s8),
                  child: _ToastTile(key: t.key, model: t),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastTile extends StatefulWidget {
  const _ToastTile({super.key, required this.model});

  final _ToastModel model;

  @override
  State<_ToastTile> createState() => _ToastTileState();
}

class _ToastTileState extends State<_ToastTile>
    with SingleTickerProviderStateMixin {
  // Supabase toast (Sonner): fade-in .3s.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SbMotion.slow,
  )..forward();

  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: SbMotion.standard);

  Future<void> animateOut() => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _accent(SbColorScheme c) {
    switch (widget.model.variant) {
      case SbToastVariant.neutral:
        return c.textSecondary;
      case SbToastVariant.brand:
        return c.primary;
      case SbToastVariant.warning:
        return c.warning;
      case SbToastVariant.destructive:
        return c.destructive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final accent = _accent(colors);

    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_anim),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SbSurface(
            color: colors.surface,
            borderColor: colors.border,
            borderRadius: SbRadius.all8,
            boxShadow: SbElevation.e3,
            padding: const EdgeInsets.symmetric(
              horizontal: SbSpacing.s16,
              vertical: SbSpacing.s12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SbSurface(
                  width: 4,
                  height: 20,
                  color: accent,
                  borderRadius: SbRadius.full,
                ),
                const SizedBox(width: SbSpacing.s12),
                Flexible(child: SbText.body(widget.model.message)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
