import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The visual style of a [CairnBadge].
enum CairnBadgeVariant {
  /// `bg-primary text-primary-foreground`.
  primary,

  /// `bg-secondary text-secondary-foreground`.
  secondary,

  /// `bg-destructive text-white`.
  destructive,

  /// `border-border text-foreground` with no fill.
  outline,

  /// No fill and no border.
  ghost,
}

/// A small status pill.
///
/// `inline-flex w-fit items-center gap-1 rounded-full border border-transparent
/// px-2 py-0.5 text-xs font-medium` — a fully rounded pill with 8px horizontal
/// and 2px vertical padding and 12px medium text.
///
/// The transparent 1px border on filled variants is deliberate: it keeps the
/// outer dimensions identical between the filled and [CairnBadgeVariant.outline]
/// variants, so badges of different variants line up in a row.
///
/// ```dart
/// const CairnBadge(label: Text('Beta'));
/// const CairnBadge(
///   variant: CairnBadgeVariant.destructive,
///   label: Text('Failed'),
/// );
/// ```
class CairnBadge extends StatelessWidget {
  /// Creates a badge.
  const CairnBadge({
    super.key,
    required this.label,
    this.variant = CairnBadgeVariant.primary,
    this.leading,
    this.trailing,
  });

  /// The badge's content.
  final Widget label;

  /// The visual style.
  final CairnBadgeVariant variant;

  /// An icon before the label. Forced to `size-3` (12px).
  final Widget? leading;

  /// An icon after the label. Forced to `size-3` (12px).
  final Widget? trailing;

  /// `[&>svg]:size-3`.
  static const double _iconSize = 12.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final (
      Color background,
      Color foreground,
      Color border,
    ) = switch (variant) {
      CairnBadgeVariant.primary => (
        theme.primary,
        theme.primaryForeground,
        const Color(0x00000000),
      ),
      CairnBadgeVariant.secondary => (
        theme.secondary,
        theme.secondaryForeground,
        const Color(0x00000000),
      ),
      // `dark:bg-destructive/60` softens the fill in dark mode.
      CairnBadgeVariant.destructive => (
        isDark ? theme.destructive.withValues(alpha: 0.6) : theme.destructive,
        theme.destructiveForeground,
        const Color(0x00000000),
      ),
      CairnBadgeVariant.outline => (
        const Color(0x00000000),
        theme.foreground,
        theme.border,
      ),
      CairnBadgeVariant.ghost => (
        const Color(0x00000000),
        theme.foreground,
        const Color(0x00000000),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CairnSpacing.s2,
        vertical: CairnSpacing.s0p5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: CairnRadius.brFull,
        border: Border.all(color: border),
      ),
      child: IconTheme(
        data: IconThemeData(color: foreground, size: _iconSize),
        child: DefaultTextStyle(
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(fontWeight: CairnTypography.medium, color: foreground),
          maxLines: 1,
          softWrap: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s1,
            children: <Widget>[
              if (leading != null)
                SizedBox.square(dimension: _iconSize, child: leading),
              label,
              if (trailing != null)
                SizedBox.square(dimension: _iconSize, child: trailing),
            ],
          ),
        ),
      ),
    );
  }
}
