import 'package:flutter/widgets.dart';

import '../../primitives/sb_surface.dart';
import '../../primitives/sb_text.dart';
import '../../theme/sb_theme_extensions.dart';
import '../../tokens/sb_radius.dart';
import '../../tokens/sb_spacing.dart';
import '../../utils/context_extensions.dart';
import '../divider/sb_divider.dart';

/// Column definition for an [SbTable].
@immutable
class SbTableColumn {
  const SbTableColumn({
    required this.label,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final Alignment alignment;
}

/// Lightweight, token-driven data table with a header row and optional zebra
/// striping. Cells are arbitrary widgets supplied per row.
class SbTable extends StatelessWidget {
  const SbTable({
    super.key,
    required this.columns,
    required this.rows,
    this.striped = true,
    this.maxBodyHeight,
  });

  final List<SbTableColumn> columns;

  /// Each row is a list of cell widgets, aligned to [columns] by index.
  final List<List<Widget>> rows;
  final bool striped;

  /// When set, the body becomes a natively scrollable [ListView] capped at this
  /// height (the header stays pinned); otherwise the table sizes to its rows.
  final double? maxBodyHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.sbColors;

    // Body rows are a native ListView.separated — real scroll physics + lazy
    // building — with Supabase zebra striping and hairline row dividers.
    Widget body = ListView.separated(
      shrinkWrap: true,
      physics: maxBodyHeight == null
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      itemBuilder: (context, i) => DecoratedBox(
        decoration: BoxDecoration(
          color: striped && i.isOdd ? colors.surfaceHover : null,
        ),
        child: _Row(columns: columns, cells: rows[i]),
      ),
      separatorBuilder: (context, index) => const SbDivider(),
    );
    if (maxBodyHeight != null) {
      body = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxBodyHeight!),
        child: body,
      );
    }

    return SbSurface(
      color: colors.surface,
      borderColor: colors.border,
      borderRadius: SbRadius.all8,
      clipChildren: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header (pinned).
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceHover,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: _Row(
              columns: columns,
              cells: <Widget>[
                for (final c in columns)
                  SbText(
                    c.label,
                    variant: SbTextVariant.caption,
                    role: SbColorRole.textSecondary,
                  ),
              ],
            ),
          ),
          body,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.columns, required this.cells});

  final List<SbTableColumn> columns;
  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SbSpacing.s16,
        vertical: SbSpacing.s12,
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: SbSpacing.s16),
            Expanded(
              flex: columns[i].flex,
              child: Align(
                alignment: columns[i].alignment,
                child: i < cells.length ? cells[i] : const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
