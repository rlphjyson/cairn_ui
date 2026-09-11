import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The visual style of a [CairnAlert].
enum CairnAlertVariant {
  /// `bg-card text-card-foreground`.
  normal,

  /// `bg-card text-destructive`, with the description at
  /// `text-destructive/90`.
  destructive,
}

/// A callout for a short, prominent message.
///
/// `relative grid w-full items-start rounded-lg border px-4 py-3 text-sm`.
///
/// The layout is a CSS grid whose first column collapses to zero width when
/// there is no icon (`grid-cols-[0_1fr]`) and becomes 16px wide with a 12px
/// gap when there is (`has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr]
/// has-[>svg]:gap-x-3`). The icon is also nudged down 2px
/// (`[&>svg]:translate-y-0.5`) so it optically aligns with the title's cap
/// height rather than its line box. Both details are reproduced here.
///
/// ```dart
/// const CairnAlert(
///   icon: CairnIcon(CairnIconData.alert),
///   title: Text('Heads up!'),
///   description: Text('Your trial ends in three days.'),
/// );
/// ```
class CairnAlert extends StatelessWidget {
  /// Creates an alert.
  const CairnAlert({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.variant = CairnAlertVariant.normal,
  });

  /// The alert heading — `font-medium tracking-tight`.
  final Widget? title;

  /// The supporting body — `text-sm text-muted-foreground`.
  final Widget? description;

  /// An optional leading icon, forced to `size-4` (16px).
  final Widget? icon;

  /// The visual style.
  final CairnAlertVariant variant;

  /// `[&>svg]:size-4`.
  static const double _iconSize = 16.0;

  /// `has-[>svg]:gap-x-3`.
  static const double _iconGap = CairnSpacing.s3;

  /// `[&>svg]:translate-y-0.5` — optical alignment nudge.
  static const double _iconNudge = 2.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool destructive = variant == CairnAlertVariant.destructive;

    final Color titleColor = destructive
        ? theme.destructive
        : theme.cardForeground;
    final Color descriptionColor = destructive
        ? theme.destructive.withValues(alpha: 0.9)
        : theme.mutedForeground;

    final Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      // `gap-y-0.5`.
      spacing: CairnSpacing.s0p5,
      children: <Widget>[
        if (title != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  fontWeight: CairnTypography.medium,
                  letterSpacing: CairnTypography.trackingTight(14),
                  color: titleColor,
                  height: CairnTypography.leadingNone,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: title!,
          ),
        if (description != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: descriptionColor),
            child: description!,
          ),
      ],
    );

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: CairnSpacing.s4,
          vertical: CairnSpacing.s3,
        ),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(theme.radiusScale.lg),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(top: _iconNudge),
                child: IconTheme(
                  data: IconThemeData(color: titleColor, size: _iconSize),
                  child: SizedBox.square(dimension: _iconSize, child: icon),
                ),
              ),
              const SizedBox(width: _iconGap),
            ],
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
