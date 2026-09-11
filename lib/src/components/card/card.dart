import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A content container with header, content and footer slots.
///
/// `flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground
/// shadow-sm` — a `rounded-xl` (14 logical pixel) radius, 24px of vertical
/// padding on the card itself, and a 24px gap between its slots.
///
/// The horizontal padding lives on the *children* (`px-6` on header, content
/// and footer), not the card, which is what lets a full-bleed element such as
/// an image or a [CairnSeparator] span edge to edge. Cairn preserves that
/// structure rather than collapsing it into one padded box.
///
/// ```dart
/// CairnCard(
///   children: [
///     const CairnCardHeader(
///       title: Text('Deploy'),
///       description: Text('Push to production.'),
///     ),
///     const CairnCardContent(child: Text('Body')),
///     CairnCardFooter(
///       children: [CairnButton(onPressed: () {}, child: const Text('Go'))],
///     ),
///   ],
/// );
/// ```
class CairnCard extends StatelessWidget {
  /// Creates a card.
  const CairnCard({
    super.key,
    required this.children,
    this.gap = CairnSpacing.s6,
    this.width,
  });

  /// The card's slots, typically [CairnCardHeader], [CairnCardContent] and
  /// [CairnCardFooter].
  final List<Widget> children;

  /// The gap between slots (`gap-6`).
  final double gap;

  /// An optional fixed width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      width: width,
      // `py-6` — vertical only; horizontal padding is per-slot.
      padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s6),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
        boxShadow: CairnShadows.sm,
      ),
      child: DefaultTextStyle(
        style: theme
            .textStyle(CairnTypography.sm)
            .copyWith(color: theme.cardForeground),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        ),
      ),
    );
  }
}

/// The title and description slot of a [CairnCard].
///
/// `grid auto-rows-min items-start gap-2 px-6`, with an optional [action]
/// pinned to the trailing edge (`col-start-2 row-span-2 justify-self-end`).
class CairnCardHeader extends StatelessWidget {
  /// Creates a card header.
  const CairnCardHeader({super.key, this.title, this.description, this.action});

  /// The card title — `leading-none font-semibold`.
  final Widget? title;

  /// The supporting description — `text-sm text-muted-foreground`.
  final Widget? description;

  /// An optional trailing action, such as a menu button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final Widget stack = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s2,
      children: <Widget>[
        if (title != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  fontWeight: CairnTypography.semibold,
                  height: CairnTypography.leadingNone,
                  color: theme.cardForeground,
                ),
            child: title!,
          ),
        if (description != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
            child: description!,
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s6),
      child: action == null
          ? stack
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: stack),
                action!,
              ],
            ),
    );
  }
}

/// The main body slot of a [CairnCard] — `px-6`.
class CairnCardContent extends StatelessWidget {
  /// Creates a card content slot.
  const CairnCardContent({super.key, required this.child});

  /// The body.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s6),
    child: child,
  );
}

/// The footer slot of a [CairnCard] — `flex items-center px-6`.
class CairnCardFooter extends StatelessWidget {
  /// Creates a card footer.
  const CairnCardFooter({
    super.key,
    required this.children,
    this.spacing = CairnSpacing.s2,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  /// The footer's children, typically buttons.
  final List<Widget> children;

  /// The gap between children.
  final double spacing;

  /// How to align the children horizontally.
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s6),
    child: Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: spacing,
      children: children,
    ),
  );
}
