import 'package:flutter/widgets.dart';
import 'package:supabase_ui/src/utils/context_extensions.dart';

import '../../tokens/sb_radius.dart';
import '../divider/sb_divider.dart';
import 'sb_list_tile.dart';

/// A bordered list backed by a native [ListView.separated] — so it gets real
/// scroll physics and lazy item building, with Supabase styling (rounded
/// bordered surface, hairline dividers).
///
/// - Default ([SbList.new]): pass a fixed [children] list.
/// - [SbList.builder]: lazily build [itemCount] rows for long/virtualized lists.
///
/// [shrinkWrap] (default true) lets the list size to its content inside another
/// scrollable; set it false with a bounded height to scroll natively.
///
/// [borderRadius] rounds the entire list container via a single [ClipRRect],
/// and its top/bottom corners are mirrored onto the first/last tiles via
/// [SbListTileBorderRadius] so hover highlights clip correctly. Middle items
/// are returned as-is — no wrapper, no allocation. The corner radii are
/// computed once per [build] call and captured by the item-builder closure,
/// not recomputed per visible item.
class SbList extends StatelessWidget {
  const SbList({
    super.key,
    required List<Widget> this._children,
    this.borderRadius = SbRadius.all8,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shrinkWrap = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.controller,
  }) : itemBuilder = null,
       itemCount = null;

  const SbList.builder({
    super.key,
    required IndexedWidgetBuilder this.itemBuilder,
    required int this.itemCount,
    this.borderRadius = SbRadius.all8,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shrinkWrap = true,
    this.physics,
    this.padding = EdgeInsets.zero,
    this.controller,
  }) : _children = null;

  final List<Widget>? _children;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;

  /// Rounds the outer list container and the matching tile corners.
  /// Defaults to [SbRadius.all8]. Pass [BorderRadius.zero] to disable.
  final BorderRadius borderRadius;

  /// Outline color drawn on top of the list container. Null for no border.
  final Color? borderColor;

  /// Stroke width of the outer border. Has no effect when [borderColor] is null.
  final double borderWidth;

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final count = itemCount ?? _children!.length;
    final builder = itemBuilder ?? (_, i) => _children![i];
    final bColor = borderColor ?? context.sbColors.border;

    // Derived radii computed once per build and captured by the closure below.
    // BorderRadius.== value-compares, so SbListTileBorderRadius.updateShouldNotify
    // correctly returns false on stable lists without needing pointer equality.
    final topRadius = BorderRadius.only(
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
    );
    final bottomRadius = BorderRadius.only(
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    Widget list = ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: EdgeInsets.zero,
      itemCount: count,
      itemBuilder: (context, index) {
        final child = builder(context, index);
        final BorderRadius? radius;
        if (count == 1) {
          radius = borderRadius;
        } else if (index == 0) {
          radius = topRadius;
        } else if (index == count - 1) {
          radius = bottomRadius;
        } else {
          radius = null; // middle items: no wrapper, no allocation
        }
        if (radius == null) return child;
        return SbListTileBorderRadius(borderRadius: radius, child: child);
      },
      separatorBuilder: (_, _) => const SbDivider(),
    );

    if (borderRadius != BorderRadius.zero) {
      list = ClipRRect(borderRadius: borderRadius, child: list);
    }

    // Foreground border is applied after the clip so the stroke is never
    // cut off by ClipRRect and always sits flush with the container edge.
    list = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius != BorderRadius.zero ? borderRadius : null,
        border: Border.all(color: bColor, width: borderWidth),
      ),
      position: DecorationPosition.foreground,
      child: list,
    );

    if (padding != EdgeInsets.zero) {
      list = Padding(padding: padding, child: list);
    }

    return list;
  }
}
