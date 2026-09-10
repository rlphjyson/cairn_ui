import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../input/input.dart';
import '../pagination/pagination.dart';
import '../table/table.dart';

/// The sort direction of a [CairnDataTable] column.
enum CairnSortDirection {
  /// Smallest first.
  ascending,

  /// Largest first.
  descending;

  /// The opposite direction.
  CairnSortDirection get inverted => this == ascending ? descending : ascending;
}

/// A sortable, filterable, paginated table built on [CairnTable].
///
/// shadcn/ui's Data Table is a *recipe* rather than a component — it wires
/// TanStack Table to the Table primitives. Cairn takes the same approach:
/// [CairnDataTable] adds behaviour on top of [CairnTable] rather than being a
/// separate rendering path, so the two cannot drift visually.
///
/// Sorting is opt-in per column, enabled by giving a [CairnColumn] a `sortKey`.
/// Sortable headers become interactive and show a directional arrow.
///
/// ```dart
/// CairnDataTable<Payment>(
///   rows: payments,
///   columns: [
///     CairnColumn(
///       label: 'Email',
///       cell: (p) => Text(p.email),
///       sortKey: (p) => p.email,
///     ),
///     CairnColumn(
///       label: 'Amount',
///       cell: (p) => Text(p.amount.toStringAsFixed(2)),
///       sortKey: (p) => p.amount,
///     ),
///   ],
///   searchBy: (p) => p.email,
/// );
/// ```
class CairnDataTable<T> extends StatefulWidget {
  /// Creates a data table.
  const CairnDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.searchBy,
    this.searchPlaceholder = 'Filter...',
    this.pageSize,
    this.onRowTap,
    this.emptyMessage = 'No results.',
  });

  /// The columns. Any with a `sortKey` becomes sortable.
  final List<CairnColumn<T>> columns;

  /// The full row set, before filtering, sorting and pagination.
  final List<T> rows;

  /// Extracts the text a row is matched against by the filter field.
  ///
  /// Null hides the filter field entirely.
  final String Function(T row)? searchBy;

  /// The filter field's placeholder.
  final String searchPlaceholder;

  /// Rows per page. Null disables pagination.
  final int? pageSize;

  /// Called when a row is tapped.
  final void Function(int index, T row)? onRowTap;

  /// Shown when no rows survive filtering.
  final String emptyMessage;

  @override
  State<CairnDataTable<T>> createState() => _CairnDataTableState<T>();
}

class _CairnDataTableState<T> extends State<CairnDataTable<T>> {
  final TextEditingController _filter = TextEditingController();
  int? _sortColumn;
  CairnSortDirection _sortDirection = CairnSortDirection.ascending;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _filter.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _filter.removeListener(_onFilterChanged);
    _filter.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    // Any change to the filter invalidates the current page.
    setState(() => _page = 1);
  }

  /// Applies filtering then sorting.
  List<T> get _processed {
    List<T> result = widget.rows;

    final String query = _filter.text.trim().toLowerCase();
    if (widget.searchBy != null && query.isNotEmpty) {
      result = result
          .where((T r) => widget.searchBy!(r).toLowerCase().contains(query))
          .toList(growable: false);
    }

    final int? sortIndex = _sortColumn;
    if (sortIndex != null) {
      final Comparable<Object> Function(T)? key =
          widget.columns[sortIndex].sortKey;
      if (key != null) {
        // Copy before sorting: the caller's list must not be mutated.
        result = List<T>.of(result)
          ..sort((T a, T b) {
            final int cmp = key(a).compareTo(key(b));
            return _sortDirection == CairnSortDirection.ascending ? cmp : -cmp;
          });
      }
    }

    return result;
  }

  int get _pageCount {
    final int size = widget.pageSize ?? 0;
    if (size <= 0) return 1;
    final int total = _processed.length;
    return total == 0 ? 1 : ((total - 1) ~/ size) + 1;
  }

  List<T> get _visible {
    final int? size = widget.pageSize;
    if (size == null || size <= 0) return _processed;
    final List<T> all = _processed;
    final int start = (_page - 1) * size;
    if (start >= all.length) return const <Never>[];
    return all.sublist(start, (start + size).clamp(0, all.length));
  }

  void _toggleSort(int index) {
    setState(() {
      if (_sortColumn == index) {
        _sortDirection = _sortDirection.inverted;
      } else {
        _sortColumn = index;
        _sortDirection = CairnSortDirection.ascending;
      }
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<T> visible = _visible;

    // Wrap each sortable column's header in an interactive sort control by
    // rewriting its label into the cell builder of a header-only column.
    final List<CairnColumn<T>> columns = <CairnColumn<T>>[
      for (int i = 0; i < widget.columns.length; i++) widget.columns[i],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s4,
      children: <Widget>[
        if (widget.searchBy != null)
          SizedBox(
            width: 280,
            child: CairnInput(
              controller: _filter,
              placeholder: widget.searchPlaceholder,
              semanticLabel: widget.searchPlaceholder,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.border),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SortableHeader<T>(
                  columns: columns,
                  sortColumn: _sortColumn,
                  sortDirection: _sortDirection,
                  onSort: _toggleSort,
                ),
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: CairnSpacing.s8,
                    ),
                    child: Text(
                      widget.emptyMessage,
                      textAlign: TextAlign.center,
                      style: theme
                          .textStyle(CairnTypography.sm)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  )
                else
                  CairnTable<T>(
                    columns: columns,
                    rows: visible,
                    showHeader: false,
                    onRowTap: widget.onRowTap,
                  ),
              ],
            ),
          ),
        ),
        if (widget.pageSize != null && _pageCount > 1)
          Align(
            alignment: Alignment.centerRight,
            child: CairnPagination(
              page: _page,
              pageCount: _pageCount,
              onChanged: (int p) => setState(() => _page = p),
            ),
          ),
      ],
    );
  }
}

/// The header row, with sort affordances on sortable columns.
class _SortableHeader<T> extends StatelessWidget {
  const _SortableHeader({
    required this.columns,
    required this.sortColumn,
    required this.sortDirection,
    required this.onSort,
  });

  final List<CairnColumn<T>> columns;
  final int? sortColumn;
  final CairnSortDirection sortDirection;
  final ValueChanged<int> onSort;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Container(
      height: CairnTable.headerHeight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < columns.length; i++)
            _headerCell(context, theme, i),
        ],
      ),
    );
  }

  Widget _headerCell(BuildContext context, CairnTheme theme, int i) {
    final CairnColumn<T> column = columns[i];
    final bool sortable = column.sortKey != null;
    final bool active = sortColumn == i;

    final TextStyle style = theme
        .textStyle(CairnTypography.sm)
        .copyWith(fontWeight: CairnTypography.medium, color: theme.foreground);

    Widget content = Text(
      column.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );

    if (sortable) {
      content = CairnInteractive(
        onTap: () => onSort(i),
        semanticLabel:
            'Sort by ${column.label}, currently '
            '${active ? sortDirection.name : "unsorted"}',
        builder: (BuildContext context, CairnStates states) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s1,
          children: <Widget>[
            Text(
              column.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(
                color: states.hovered ? theme.foreground : theme.foreground,
              ),
            ),
            Opacity(
              // The arrow is dim until the column is the active sort.
              opacity: active ? 1.0 : 0.4,
              child: CairnIcon(
                active && sortDirection == CairnSortDirection.descending
                    ? CairnIconData.arrowDown
                    : CairnIconData.arrowUp,
                size: 14,
                color: theme.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    final Widget padded = Padding(
      padding: const EdgeInsets.all(CairnTable.cellPadding),
      child: Align(alignment: column.alignment, child: content),
    );

    return column.width == null
        ? Expanded(flex: column.flex, child: padded)
        : SizedBox(width: column.width, child: padded);
  }
}
