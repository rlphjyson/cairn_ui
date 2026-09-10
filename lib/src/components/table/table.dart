import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// One column in a [CairnTable].
@immutable
class CairnColumn<T> {
  /// Creates a column.
  const CairnColumn({
    required this.label,
    required this.cell,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.sortKey,
  });

  /// The header label.
  final String label;

  /// Builds a cell for one row.
  final Widget Function(T row) cell;

  /// A fixed width. Null uses [flex] instead.
  final double? width;

  /// The flex factor when [width] is null.
  final int flex;

  /// How the cell's content is aligned.
  final Alignment alignment;

  /// An optional comparator key, enabling sorting on this column in a
  /// [CairnDataTable].
  final Comparable<Object> Function(T row)? sortKey;
}

/// A data table matching shadcn/ui's `Table`.
///
/// Header cells are `h-10 px-2 text-left align-middle font-medium
/// whitespace-nowrap text-foreground`; body cells are `p-2 align-middle`.
/// Rows carry `border-b transition-colors hover:bg-muted/50`, and the selected
/// state is `data-[state=selected]:bg-muted`.
///
/// Note the 8px cell padding — considerably tighter than a Material `DataTable`
/// — and the 40px header row height.
///
/// ```dart
/// CairnTable<Invoice>(
///   rows: invoices,
///   columns: [
///     CairnColumn(label: 'Invoice', cell: (r) => Text(r.id)),
///     CairnColumn(label: 'Amount', cell: (r) => Text(r.amount)),
///   ],
/// );
/// ```
class CairnTable<T> extends StatelessWidget {
  /// Creates a table.
  const CairnTable({
    super.key,
    required this.columns,
    required this.rows,
    this.selected = const <int>{},
    this.onRowTap,
    this.caption,
    this.showHeader = true,
  });

  /// The columns.
  final List<CairnColumn<T>> columns;

  /// The row data.
  final List<T> rows;

  /// Indices of selected rows (`data-[state=selected]:bg-muted`).
  final Set<int> selected;

  /// Called when a row is tapped.
  final void Function(int index, T row)? onRowTap;

  /// An optional caption below the table
  /// (`mt-4 text-sm text-muted-foreground`).
  final Widget? caption;

  /// Whether to render the header row.
  final bool showHeader;

  /// `h-10` — the header row height.
  static const double headerHeight = 40.0;

  /// `p-2` — cell padding.
  static const double cellPadding = CairnSpacing.s2;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showHeader)
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              children: <Widget>[
                for (final CairnColumn<T> column in columns)
                  _cellShell(
                    column: column,
                    child: Text(
                      column.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme
                          .textStyle(CairnTypography.sm)
                          .copyWith(
                            fontWeight: CairnTypography.medium,
                            color: theme.foreground,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        for (int i = 0; i < rows.length; i++)
          _TableRow<T>(
            columns: columns,
            row: rows[i],
            selected: selected.contains(i),
            isLast: i == rows.length - 1,
            onTap: onRowTap == null ? null : () => onRowTap!(i, rows[i]),
          ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: CairnSpacing.s4),
            child: DefaultTextStyle(
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
              child: caption!,
            ),
          ),
      ],
    );
  }

  /// Wraps a cell in its column's sizing and padding.
  static Widget _cellShell<R>({
    required CairnColumn<R> column,
    required Widget child,
  }) {
    final Widget padded = Padding(
      padding: const EdgeInsets.all(cellPadding),
      child: Align(alignment: column.alignment, child: child),
    );
    return column.width == null
        ? Expanded(flex: column.flex, child: padded)
        : SizedBox(width: column.width, child: padded);
  }
}

/// One body row.
class _TableRow<T> extends StatefulWidget {
  const _TableRow({
    required this.columns,
    required this.row,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  final List<CairnColumn<T>> columns;
  final T row;
  final bool selected;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  State<_TableRow<T>> createState() => _TableRowState<T>();
}

class _TableRowState<T> extends State<_TableRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final Color background = widget.selected
        ? theme.muted
        : _hovered
        // `hover:bg-muted/50`.
        ? theme.muted.withValues(alpha: 0.5)
        : const Color(0x00000000);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            border: widget.isLast
                // `[&_tr:last-child]:border-0`.
                ? null
                : Border(bottom: BorderSide(color: theme.border)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final CairnColumn<T> column in widget.columns)
                  CairnTable._cellShell<T>(
                    column: column,
                    child: DefaultTextStyle(
                      style: theme
                          .textStyle(CairnTypography.sm)
                          .copyWith(color: theme.foreground),
                      child: column.cell(widget.row),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
