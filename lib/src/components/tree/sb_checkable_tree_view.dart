import 'package:flutter/material.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../checkbox/sb_tristate_checkbox.dart';
import 'sb_tree_guides.dart';

/// A node in an [SbCheckableTreeView].
///
/// Branches carry [children]; leaves don't. [checked] is tri-state for
/// branches (`null` = mixed) and boolean for leaves. [id] is a stable identity
/// used to preserve expansion state across rebuilds — keep it unique.
@immutable
class SbCheckableTreeNode {
  const SbCheckableTreeNode({
    required this.id,
    required this.label,
    required this.checked,
    this.subtitle,
    this.children = const <SbCheckableTreeNode>[],
    this.onTap,
    this.trailing,
  });

  final String id;
  final String label;
  final bool? checked;
  final String? subtitle;
  final List<SbCheckableTreeNode> children;

  /// Invoked when a leaf row body is tapped. Branch bodies toggle expansion
  /// instead; the checkbox always toggles the checked state.
  final VoidCallback? onTap;

  /// Optional widget rendered at the end of the row, after the label
  /// column (e.g. a play affordance on a playable-video leaf). Never shown
  /// for branches.
  final Widget? trailing;

  bool get hasChildren => children.isNotEmpty;
}

/// Owns the expanded-id set for an [SbCheckableTreeView] and lets callers drive
/// expansion programmatically. Pass one in to share or persist tree state;
/// omit it and the view manages its own.
class SbCheckableTreeController extends ChangeNotifier {
  SbCheckableTreeController({Set<String>? collapsed})
    : _collapsed = <String>{...?collapsed};

  final Set<String> _collapsed;

  /// Currently-collapsed node ids (read-only view).
  Set<String> get collapsedIds => Set<String>.unmodifiable(_collapsed);

  bool isExpanded(String id) => !_collapsed.contains(id);

  void expand(String id) {
    if (_collapsed.remove(id)) notifyListeners();
  }

  void collapse(String id) {
    if (_collapsed.add(id)) notifyListeners();
  }

  void toggle(String id) {
    if (!_collapsed.remove(id)) _collapsed.add(id);
    notifyListeners();
  }

  void expandAll() {
    if (_collapsed.isEmpty) return;
    _collapsed.clear();
    notifyListeners();
  }

  /// Collapses every branch reachable from [nodes].
  void collapseAll(List<SbCheckableTreeNode> nodes) {
    final int before = _collapsed.length;
    void walk(List<SbCheckableTreeNode> ns) {
      for (final SbCheckableTreeNode n in ns) {
        if (n.hasChildren) {
          _collapsed.add(n.id);
          walk(n.children);
        }
      }
    }

    walk(nodes);
    if (_collapsed.length != before) notifyListeners();
  }
}

/// Hierarchical, expandable tree with tri-state checkboxes and classic
/// `├─ └─` connector guides.
///
/// There is no chevron affordance: tapping a **branch** body toggles its
/// expansion, tapping a **leaf** body invokes its [SbCheckableTreeNode.onTap],
/// and the checkbox always toggles the checked state via [onChanged]. Rows are
/// flattened and rendered lazily through a fixed-extent [ListView.builder], so
/// trees with thousands of nodes scroll smoothly; expansion is keyed by node
/// id so selection-driven rebuilds never collapse the tree.
class SbCheckableTreeView extends StatefulWidget {
  const SbCheckableTreeView({
    super.key,
    required this.nodes,
    required this.onChanged,
    this.controller,
    this.initiallyCollapsed = const <String>{},
    this.indent = SbSpacing.s20,
    this.rowHeight = kMinInteractiveDimension,
    this.showGuides = true,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.scrollController,
  });

  final List<SbCheckableTreeNode> nodes;

  /// Called with the toggled node and its resolved next value.
  final void Function(SbCheckableTreeNode node, bool value) onChanged;

  /// Optional external expansion controller. When omitted, the view creates an
  /// internal one seeded from [initiallyCollapsed].
  final SbCheckableTreeController? controller;

  /// Node ids that start collapsed. All other branches start expanded.
  final Set<String> initiallyCollapsed;

  /// Horizontal pixels added per depth level.
  final double indent;

  /// Fixed row height. A constant extent keeps the list virtualized cheaply.
  /// Slightly taller than the plain tree to fit an optional [subtitle].
  final double rowHeight;

  /// Whether to paint the `├─ └─ │` connector guides.
  final bool showGuides;

  final EdgeInsetsGeometry padding;

  /// Set true to embed inside another scrollable.
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  @override
  State<SbCheckableTreeView> createState() => _SbCheckableTreeViewState();
}

class _SbCheckableTreeViewState extends State<SbCheckableTreeView> {
  late SbCheckableTreeController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _attach(
      widget.controller ??
          SbCheckableTreeController(collapsed: widget.initiallyCollapsed),
    );
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(SbCheckableTreeView old) {
    super.didUpdateWidget(old);
    if (widget.controller == old.controller) return;
    _detach();
    _attach(
      widget.controller ??
          SbCheckableTreeController(collapsed: widget.initiallyCollapsed),
    );
    _ownsController = widget.controller == null;
  }

  void _attach(SbCheckableTreeController c) {
    _controller = c..addListener(_onControllerChanged);
  }

  void _detach() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _onTap(SbCheckableTreeNode node) {
    if (node.hasChildren) {
      _controller.toggle(node.id);
    } else {
      node.onTap?.call();
    }
  }

  /// Depth-first flatten of the visible rows. [ancestorIsLast] records, for
  /// each ancestor level, whether that ancestor was its parent's last child —
  /// all the connector painter needs to place its vertical guides.
  void _flatten(
    List<SbCheckableTreeNode> nodes,
    List<bool> ancestorIsLast,
    List<_Row> out,
  ) {
    final int last = nodes.length - 1;
    for (int i = 0; i < nodes.length; i++) {
      final SbCheckableTreeNode node = nodes[i];
      final bool isLast = i == last;
      final bool open = node.hasChildren && _controller.isExpanded(node.id);
      out.add(
        _Row(
          node: node,
          ancestorIsLast: ancestorIsLast,
          isLast: isLast,
          open: open,
        ),
      );
      if (open) {
        _flatten(node.children, <bool>[...ancestorIsLast, isLast], out);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_Row> rows = <_Row>[];
    _flatten(widget.nodes, const <bool>[], rows);

    return ListView.builder(
      controller: widget.scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemExtent: widget.rowHeight,
      itemCount: rows.length,
      itemBuilder: (BuildContext context, int index) {
        final _Row row = rows[index];
        return _TreeTile(
          row: row,
          indent: widget.indent,
          rowHeight: widget.rowHeight,
          showGuides: widget.showGuides,
          onToggleExpand: () => _onTap(row.node),
          onChanged: (bool value) => widget.onChanged(row.node, value),
        );
      },
    );
  }
}

/// A flattened, ready-to-paint row.
class _Row {
  const _Row({
    required this.node,
    required this.ancestorIsLast,
    required this.isLast,
    required this.open,
  });

  final SbCheckableTreeNode node;

  /// `isLast` flag for each ancestor, depth 0 → parent. Length equals depth.
  final List<bool> ancestorIsLast;
  final bool isLast;
  final bool open;

  int get depth => ancestorIsLast.length;
}

class _TreeTile extends StatelessWidget {
  const _TreeTile({
    required this.row,
    required this.indent,
    required this.rowHeight,
    required this.showGuides,
    required this.onToggleExpand,
    required this.onChanged,
  });

  final _Row row;
  final double indent;
  final double rowHeight;
  final bool showGuides;
  final VoidCallback onToggleExpand;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final SbCheckableTreeNode node = row.node;

    return SbInteraction(
      onTap: onToggleExpand,
      builder: (BuildContext context, Set<WidgetState> states, _) {
        final bool hovered = states.contains(WidgetState.hovered);
        return SbSurface(
          color: hovered ? colors.surfaceHover : null,
          borderRadius: SbRadius.all6,
          padding: const EdgeInsets.only(
            left: SbSpacing.s4,
            right: SbSpacing.s8,
          ),
          child: Row(
            children: <Widget>[
              if (showGuides && row.depth > 0)
                CustomPaint(
                  size: Size(row.depth * indent, rowHeight),
                  painter: SbTreeGuidePainter(
                    depth: row.depth,
                    ancestorIsLast: row.ancestorIsLast,
                    isLast: row.isLast,
                    indent: indent,
                    color: colors.border,
                  ),
                )
              else
                SizedBox(width: row.depth * indent),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(node.checked != true),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SbSpacing.s4,
                    SbSpacing.s8,
                    SbSpacing.s12,
                    SbSpacing.s8,
                  ),
                  child: SbTriStateCheckbox(
                    value: node.checked,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SbText.body(
                      node.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (node.subtitle case final String s)
                      SbText.caption(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        role: SbColorRole.textTertiary,
                      ),
                  ],
                ),
              ),
              if (node.trailing case final Widget t when !node.hasChildren) t,
            ],
          ),
        );
      },
    );
  }
}
