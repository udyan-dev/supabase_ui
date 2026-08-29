import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_motion.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';

/// A single tab definition.
@immutable
class SbTab {
  const SbTab({required this.label, this.icon});

  final String label;
  final Widget? icon;
}

/// Underlined tab bar. Controlled when [selectedIndex] is provided, otherwise
/// it manages its own selection. The active panel from [children] (if given) is
/// shown below the bar.
///
/// When [isScrollable] is true, tabs size to their content and lay out in a
/// horizontally scrollable row instead of splitting the width evenly — the
/// same switch `TabBar.isScrollable` makes — and selecting a tab that sits
/// outside the viewport auto-scrolls it into view, centered when there's
/// room, exactly as `TabBar` does via its internal `_scrollToCurrentIndex`.
class SbTabs extends StatefulWidget {
  const SbTabs({
    super.key,
    required this.tabs,
    this.selectedIndex,
    this.onChanged,
    this.children,
    this.initialIndex = 0,
    this.isScrollable = false,
  }) : assert(children == null || children.length == tabs.length);

  final List<SbTab> tabs;
  final int? selectedIndex;
  final ValueChanged<int>? onChanged;
  final List<Widget>? children;
  final int initialIndex;
  final bool isScrollable;

  @override
  State<SbTabs> createState() => _SbTabsState();
}

class _SbTabsState extends State<SbTabs> {
  static const Duration _tabScrollDuration = SbMotion.slow;

  late int _internalIndex = widget.initialIndex;
  ScrollController? _scrollController;
  List<GlobalKey>? _tabKeys;

  int get _index => widget.selectedIndex ?? _internalIndex;

  @override
  void initState() {
    super.initState();
    if (widget.isScrollable) _initScrollable();
  }

  void _initScrollable() {
    _scrollController = ScrollController();
    _tabKeys = List<GlobalKey>.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(SbTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScrollable && _scrollController == null) {
      _initScrollable();
    } else if (!widget.isScrollable && _scrollController != null) {
      _scrollController!.dispose();
      _scrollController = null;
      _tabKeys = null;
    } else if (widget.isScrollable &&
        widget.tabs.length != oldWidget.tabs.length) {
      _tabKeys = List<GlobalKey>.generate(
        widget.tabs.length,
        (_) => GlobalKey(),
      );
    }
    if (widget.isScrollable &&
        _index != (widget.selectedIndex ?? oldWidget.initialIndex)) {
      _scrollToIndex(_index);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (widget.selectedIndex == null) setState(() => _internalIndex = i);
    widget.onChanged?.call(i);
    if (widget.isScrollable) _scrollToIndex(i);
  }

  void _scrollToIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _scrollController;
      final keys = _tabKeys;
      if (controller == null || keys == null || !controller.hasClients) return;
      if (index < 0 || index >= keys.length) return;
      final tabBox =
          keys[index].currentContext?.findRenderObject() as RenderBox?;
      final viewportBox = context.findRenderObject() as RenderBox?;
      if (tabBox == null || viewportBox == null) return;

      final tabOffset = tabBox
          .localToGlobal(Offset.zero, ancestor: viewportBox)
          .dx;
      final viewportWidth = viewportBox.size.width;
      final tabCenter = controller.offset + tabOffset + tabBox.size.width / 2;
      final targetOffset = tabCenter - viewportWidth / 2;
      final clamped = targetOffset.clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );

      controller.animateTo(
        clamped,
        duration: _tabScrollDuration,
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final tabBar = widget.isScrollable
        ? _buildScrollableBar()
        : _buildFixedBar();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: tabBar,
        ),
        if (widget.children != null) ...[
          Expanded(
            child: _SbLazyTabStack(index: _index, children: widget.children!),
          ),
        ],
      ],
    );
  }

  Widget _buildFixedBar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < widget.tabs.length; i++)
          Expanded(
            child: _TabButton(
              tab: widget.tabs[i],
              selected: i == _index,
              onTap: () => _select(i),
            ),
          ),
      ],
    );
  }

  Widget _buildScrollableBar() {
    final keys = _tabKeys!;
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < widget.tabs.length; i++)
            _TabButton(
              key: keys[i],
              tab: widget.tabs[i],
              selected: i == _index,
              onTap: () => _select(i),
              isScrollable: true,
            ),
        ],
      ),
    );
  }
}

class _SbLazyTabStack extends StatefulWidget {
  const _SbLazyTabStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_SbLazyTabStack> createState() => _SbLazyTabStackState();
}

class _SbLazyTabStackState extends State<_SbLazyTabStack> {
  late List<Widget?> _live = List<Widget?>.filled(widget.children.length, null);

  @override
  void didUpdateWidget(_SbLazyTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != _live.length) {
      _live = List<Widget?>.filled(widget.children.length, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    _live[widget.index] = widget.children[widget.index];
    return IndexedStack(
      index: widget.index,
      children: <Widget>[
        for (final Widget? child in _live) child ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    super.key,
    required this.tab,
    required this.selected,
    required this.onTap,
    this.isScrollable = false,
  });

  final SbTab tab;
  final bool selected;
  final VoidCallback onTap;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    return SbInteraction(
      onTap: onTap,
      builder: (context, states, _) {
        final hovered = states.contains(WidgetState.hovered);
        return AnimatedContainer(
          duration: SbMotion.fast,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: selected ? colors.primary : const Color(0x00000000),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: SbSpacing.s8,
              horizontal: isScrollable ? SbSpacing.s16 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SbSpacing.s8,
              children: <Widget>[
                if (tab.icon != null) ...[tab.icon!],
                SbText(
                  tab.label,
                  variant: SbTextVariant.bodyStrong,
                  role: selected || hovered
                      ? SbColorRole.textPrimary
                      : SbColorRole.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
