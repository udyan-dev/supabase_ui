import 'package:flutter/widgets.dart';

import '../../primitives/sb_interaction.dart';
import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import 'sb_tree_guides.dart';

/// A node in an [SbTreeView].
///
/// Branches carry [children]; leaves don't. [id] is a stable identity used to
/// preserve expansion state across rebuilds — keep it unique within the tree.
@immutable
class SbTreeNode {
  const SbTreeNode({
    required this.id,
    required this.label,
    this.children = const <SbTreeNode>[],
    this.leading,
    this.trailing,
    this.onTap,
  });

  /// Stable identity. Expansion/selection are tracked by [id], so list
  /// rebuilds never lose tree state.
  final String id;
  final String label;
  final List<SbTreeNode> children;

  /// Static per-node leading/trailing widgets. For state-dependent leading
  /// (e.g. open vs. closed folder icons) use [SbTreeView.leadingBuilder].
  final Widget? leading;
  final Widget? trailing;

  /// Fired when the row is tapped, for both branches and leaves. Branches also
  /// toggle their expansion.
  final VoidCallback? onTap;

  bool get hasChildren => children.isNotEmpty;
}

/// Owns the collapsed-id set for an [SbTreeView] and lets callers drive
/// expansion programmatically. All branches are **expanded by default** — only
/// explicitly collapsed nodes are tracked. Pass a controller in to share or
/// persist tree state; omit it and the view manages its own.
class SbTreeController extends ChangeNotifier {
  SbTreeController({Set<String>? collapsed})
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
  void collapseAll(List<SbTreeNode> nodes) {
    final int before = _collapsed.length;
    void walk(List<SbTreeNode> ns) {
      for (final SbTreeNode n in ns) {
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

/// Builds a state-dependent leading widget for a node (e.g. a folder icon that
/// flips between open and closed). Return `null` to fall back to
/// [SbTreeNode.leading].
typedef SbTreeLeadingBuilder =
    Widget? Function(BuildContext context, SbTreeNode node, bool isExpanded);

/// A hierarchical, expandable tree with classic `├─ └─` connector guides.
///
/// There is no chevron affordance: tapping a **branch** row toggles its
/// expansion, tapping a **leaf** invokes its [SbTreeNode.onTap]. Rows are
/// flattened and rendered lazily through a fixed-extent [ListView.builder], so
/// trees with thousands of nodes scroll smoothly; expansion is keyed by node
/// id so selection-driven rebuilds never collapse the tree.
class SbTreeView extends StatefulWidget {
  const SbTreeView({
    super.key,
    required this.nodes,
    this.controller,
    this.initiallyCollapsed = const <String>{},
    this.selectedId,
    this.onNodeSelected,
    this.leadingBuilder,
    this.indent = SbSpacing.s20,
    this.rowHeight = 32,
    this.showGuides = true,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
    this.scrollController,
  });

  final List<SbTreeNode> nodes;

  /// Optional external expansion controller. When omitted, the view creates an
  /// internal one seeded from [initiallyCollapsed].
  final SbTreeController? controller;

  /// Node ids that start collapsed. All other branches start expanded.
  final Set<String> initiallyCollapsed;

  /// Id of the highlighted row, if any (purely visual — pair with
  /// [onNodeSelected]).
  final String? selectedId;

  /// Fired for every row tap (branch or leaf), after expansion toggling.
  final ValueChanged<SbTreeNode>? onNodeSelected;

  final SbTreeLeadingBuilder? leadingBuilder;

  /// Horizontal pixels added per depth level.
  final double indent;

  /// Fixed row height. A constant extent keeps the list virtualized cheaply.
  final double rowHeight;

  /// Whether to paint the `├─ └─ │` connector guides.
  final bool showGuides;

  final EdgeInsetsGeometry padding;

  /// Set true to embed inside another scrollable.
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  @override
  State<SbTreeView> createState() => _SbTreeViewState();
}

class _SbTreeViewState extends State<SbTreeView> {
  late SbTreeController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _attach(
      widget.controller ?? SbTreeController(collapsed: widget.initiallyCollapsed),
    );
    _ownsController = widget.controller == null;
  }

  @override
  void didUpdateWidget(SbTreeView old) {
    super.didUpdateWidget(old);
    if (widget.controller == old.controller) return;
    _detach();
    _attach(
      widget.controller ?? SbTreeController(collapsed: widget.initiallyCollapsed),
    );
    _ownsController = widget.controller == null;
  }

  void _attach(SbTreeController c) {
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

  void _onTap(SbTreeNode node) {
    if (node.hasChildren) _controller.toggle(node.id);
    widget.onNodeSelected?.call(node);
    node.onTap?.call();
  }

  /// Depth-first flatten of the visible rows. [ancestorIsLast] records, for
  /// each ancestor level, whether that ancestor was its parent's last child —
  /// which is all the connector painter needs to decide where vertical guides
  /// continue.
  void _flatten(
    List<SbTreeNode> nodes,
    List<bool> ancestorIsLast,
    List<_Row> out,
  ) {
    final int last = nodes.length - 1;
    for (int i = 0; i < nodes.length; i++) {
      final SbTreeNode node = nodes[i];
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
          selected: row.node.id == widget.selectedId,
          leadingBuilder: widget.leadingBuilder,
          onTap: () => _onTap(row.node),
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

  final SbTreeNode node;

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
    required this.selected,
    required this.leadingBuilder,
    required this.onTap,
  });

  final _Row row;
  final double indent;
  final double rowHeight;
  final bool showGuides;
  final bool selected;
  final SbTreeLeadingBuilder? leadingBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;
    final SbTreeNode node = row.node;

    final Widget? leading =
        leadingBuilder?.call(context, node, row.open) ?? node.leading;

    return SbInteraction(
      onTap: onTap,
      builder: (BuildContext context, Set<WidgetState> states, _) {
        final bool hovered = states.contains(WidgetState.hovered);
        final Color? fill = selected
            ? colors.surfaceActive
            : hovered
            ? colors.surfaceHover
            : null;

        return SbSurface(
          color: fill,
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
              if (leading != null) ...<Widget>[
                leading,
                const SizedBox(width: SbSpacing.s8),
              ],
              Expanded(
                child: SbText.body(
                  node.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  role: selected
                      ? SbColorRole.textPrimary
                      : SbColorRole.textSecondary,
                ),
              ),
              if (node.trailing != null) ...<Widget>[
                const SizedBox(width: SbSpacing.s8),
                node.trailing!,
              ],
            ],
          ),
        );
      },
    );
  }
}
