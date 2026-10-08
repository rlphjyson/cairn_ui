import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A vertical list of rows — contacts, files, settings, a playlist.
///
/// Rows are separated by a 1px [CairnTheme.border] hairline (no hairline after
/// the last), and the list itself is unbordered so it can sit inside a Card or
/// directly on the page. Set [bordered] to wrap it in the Card-style container.
///
/// Use [CairnListItem] for the usual leading / title / subtitle / trailing
/// shape, or put any widget in [children].
///
/// ```dart
/// CairnList(children: [
///   CairnListItem(
///     leading: CairnAvatar(fallback: Text('RB')),
///     title: Text('Ralph'),
///     subtitle: Text('Owner'),
///     trailing: CairnBadge(label: Text('Admin')),
///     onTap: () {},
///   ),
/// ]);
/// ```
class CairnList extends StatelessWidget {
  /// Creates a list.
  const CairnList({super.key, required this.children, this.bordered = false});

  /// The rows.
  final List<Widget> children;

  /// Whether to wrap the list in a `rounded-xl border` container.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) Container(height: 1, color: theme.border),
          children[i],
        ],
      ],
    );

    return Semantics(
      container: true,
      child: bordered
          ? Container(
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(theme.radiusScale.xl),
                border: Border.all(color: theme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: column,
            )
          : column,
    );
  }
}

/// A row in a [CairnList].
///
/// `px-4 py-3`, a 12px gap between slots, and a [title] in 14px medium over a
/// [subtitle] in 12px muted. When [onTap] is set the row hovers to the `accent`
/// fill and takes focus like any other Cairn control; without it the row is
/// static.
class CairnListItem extends StatelessWidget {
  /// Creates a list row.
  const CairnListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  /// The primary line.
  final Widget title;

  /// The secondary line.
  final Widget? subtitle;

  /// A leading avatar or icon.
  final Widget? leading;

  /// A trailing badge, button or value.
  final Widget? trailing;

  /// Makes the row tappable.
  final VoidCallback? onTap;

  /// Whether to fill the row with `accent`, for a current selection.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    Widget row(CairnStates states) => Container(
      color: (selected || states.hovered) ? theme.accent : null,
      padding: const EdgeInsets.symmetric(
        horizontal: CairnSpacing.s4,
        vertical: CairnSpacing.s3,
      ),
      child: Row(
        spacing: CairnSpacing.s3,
        children: <Widget>[
          ?leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        color: theme.foreground,
                      ),
                  child: title,
                ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style: theme
                        .textStyle(CairnTypography.xs)
                        .copyWith(color: theme.mutedForeground),
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          if (trailing != null)
            DefaultTextStyle(
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
              child: trailing!,
            ),
        ],
      ),
    );

    if (onTap == null) return row(const CairnStates());

    return CairnInteractive(
      onTap: onTap,
      builder: (BuildContext context, CairnStates states) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: states.focused
              ? Border.all(color: theme.ring, width: 2)
              : null,
        ),
        child: row(states),
      ),
    );
  }
}
