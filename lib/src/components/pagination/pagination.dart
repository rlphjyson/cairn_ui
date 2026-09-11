import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../button/button.dart';

/// A page navigator.
///
/// `flex flex-row items-center gap-1` — page links reuse the Button styles:
/// the current page is the `outline` variant and the rest are `ghost`, all at
/// the `size-9` icon size. Previous and Next are wider (`px-2.5`) because they
/// carry a label alongside the chevron.
///
/// Renders a windowed range with ellipses so the control stays a fixed width
/// regardless of page count.
///
/// ```dart
/// CairnPagination(
///   page: page,
///   pageCount: 20,
///   onChanged: (p) => setState(() => page = p),
/// );
/// ```
class CairnPagination extends StatelessWidget {
  /// Creates a pagination control.
  const CairnPagination({
    super.key,
    required this.page,
    required this.pageCount,
    this.onChanged,
    this.siblingCount = 1,
    this.showLabels = true,
  }) : assert(page >= 1, 'page is 1-based'),
       assert(pageCount >= 1, 'pageCount must be at least 1');

  /// The current page, 1-based.
  final int page;

  /// The total number of pages.
  final int pageCount;

  /// Called with the requested page.
  final ValueChanged<int>? onChanged;

  /// How many pages to show either side of the current one.
  final int siblingCount;

  /// Whether Previous and Next show text labels.
  final bool showLabels;

  /// Builds the visible page numbers, inserting nulls where an ellipsis goes.
  List<int?> _window() {
    // Show everything when it already fits.
    final int maxSlots = siblingCount * 2 + 5;
    if (pageCount <= maxSlots) {
      return <int?>[for (int i = 1; i <= pageCount; i++) i];
    }

    final int left = (page - siblingCount).clamp(1, pageCount);
    final int right = (page + siblingCount).clamp(1, pageCount);
    final bool gapLeft = left > 2;
    final bool gapRight = right < pageCount - 1;

    return <int?>[
      1,
      if (gapLeft) null,
      for (
        int i = gapLeft ? left : 2;
        i <= (gapRight ? right : pageCount - 1);
        i++
      )
        i,
      if (gapRight) null,
      pageCount,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool canPrev = page > 1 && onChanged != null;
    final bool canNext = page < pageCount && onChanged != null;

    return Semantics(
      container: true,
      label: 'Pagination',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s1,
        children: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.ghost,
            onPressed: canPrev ? () => onChanged!(page - 1) : null,
            leading: const CairnIcon(CairnIconData.chevronLeft),
            semanticLabel: 'Previous page',
            child: showLabels
                ? const Text('Previous')
                : const SizedBox.shrink(),
          ),
          for (final int? p in _window())
            if (p == null)
              SizedBox.square(
                dimension: 36.0,
                child: Center(
                  child: CairnIcon(
                    CairnIconData.moreHorizontal,
                    color: theme.mutedForeground,
                  ),
                ),
              )
            else
              CairnButton(
                // The current page is `outline`; the rest are `ghost`.
                variant: p == page
                    ? CairnButtonVariant.outline
                    : CairnButtonVariant.ghost,
                size: CairnButtonSize.iconMd,
                onPressed: onChanged == null ? null : () => onChanged!(p),
                semanticLabel: 'Page $p',
                child: Text('$p'),
              ),
          CairnButton(
            variant: CairnButtonVariant.ghost,
            onPressed: canNext ? () => onChanged!(page + 1) : null,
            trailing: const CairnIcon(CairnIconData.chevronRight),
            semanticLabel: 'Next page',
            child: showLabels ? const Text('Next') : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
