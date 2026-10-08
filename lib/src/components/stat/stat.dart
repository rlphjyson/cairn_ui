import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A single headline figure with its label and context.
///
/// A [title] in muted small text, a [value] in 30px semibold with tight
/// tracking, and a [description] in muted extra-small text — the same type
/// roles a Card uses, stacked at a 4px rhythm. An optional [figure] (an icon or
/// avatar) sits at the trailing edge, and [actions] below the description.
///
/// Put several in a [CairnStats] to get the divided row.
///
/// ```dart
/// const CairnStat(
///   title: Text('Total revenue'),
///   value: Text('\$31,200'),
///   description: Text('+12% from last month'),
/// );
/// ```
class CairnStat extends StatelessWidget {
  /// Creates a stat.
  const CairnStat({
    super.key,
    required this.title,
    required this.value,
    this.description,
    this.figure,
    this.actions,
  });

  /// The label above the figure.
  final Widget title;

  /// The headline figure.
  final Widget value;

  /// A line of context beneath the figure.
  final Widget? description;

  /// A trailing icon or avatar.
  final Widget? figure;

  /// Controls shown under the description.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle muted = TextStyle(color: theme.mutedForeground);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CairnSpacing.s6,
        vertical: CairnSpacing.s4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: CairnSpacing.s1,
              children: <Widget>[
                DefaultTextStyle(
                  style: theme.textStyle(CairnTypography.sm).merge(muted),
                  child: title,
                ),
                DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.xl3)
                      .copyWith(
                        fontWeight: CairnTypography.semibold,
                        color: theme.foreground,
                        letterSpacing: CairnTypography.trackingTight(30),
                      ),
                  child: value,
                ),
                if (description != null)
                  DefaultTextStyle(
                    style: theme.textStyle(CairnTypography.xs).merge(muted),
                    child: description!,
                  ),
                if (actions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: CairnSpacing.s2),
                    child: actions,
                  ),
              ],
            ),
          ),
          if (figure != null)
            Padding(
              padding: const EdgeInsets.only(left: CairnSpacing.s4),
              child: IconTheme(
                data: IconThemeData(color: theme.mutedForeground, size: 32),
                child: figure!,
              ),
            ),
        ],
      ),
    );
  }
}

/// A bordered, divided row (or column) of [CairnStat]s.
///
/// `rounded-xl border` with a 1px [CairnTheme.border] hairline between
/// children, so it reads as one object — the same container treatment as a
/// Card, minus the shadow.
class CairnStats extends StatelessWidget {
  /// Creates a stat group.
  const CairnStats({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
  });

  /// The stats.
  final List<Widget> children;

  /// Whether stats sit side by side or stacked.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool horizontal = direction == Axis.horizontal;

    final List<Widget> items = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(
          horizontal
              ? Container(width: 1, color: theme.border)
              : Container(height: 1, color: theme.border),
        );
      }
      items.add(horizontal ? Expanded(child: children[i]) : children[i]);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: horizontal
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
    );
  }
}
