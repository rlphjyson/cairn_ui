import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Which side of the conversation a [CairnChatBubble] belongs to.
enum CairnChatSide {
  /// The other party — left-aligned, on a `secondary` fill.
  received,

  /// The current user — right-aligned, on a `primary` fill.
  sent,
}

/// A message bubble.
///
/// `rounded-xl px-3 py-2 text-sm` capped at 75% of the available width. The
/// corner nearest the sender is squared off to a small radius so the bubble
/// reads as speaking from that side. [CairnChatSide.sent] uses the `primary`
/// slot and [CairnChatSide.received] the `secondary` slot, so a chat re-themes
/// with everything else.
///
/// Compose a conversation by stacking bubbles in a [Column]; the bubble aligns
/// itself within its parent.
///
/// ```dart
/// const CairnChatBubble(
///   side: CairnChatSide.sent,
///   author: Text('You'),
///   footer: Text('Delivered'),
///   child: Text('Shipped!'),
/// );
/// ```
class CairnChatBubble extends StatelessWidget {
  /// Creates a chat bubble.
  const CairnChatBubble({
    super.key,
    required this.child,
    this.side = CairnChatSide.received,
    this.avatar,
    this.author,
    this.footer,
  });

  /// The message content.
  final Widget child;

  /// Which side the bubble speaks from.
  final CairnChatSide side;

  /// A leading (received) or trailing (sent) avatar, usually a [CairnAvatar].
  final Widget? avatar;

  /// A small name line above the bubble.
  final Widget? author;

  /// A small line below the bubble — a timestamp or delivery state.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool sent = side == CairnChatSide.sent;
    final Color fill = sent ? theme.primary : theme.secondary;
    final Color text = sent
        ? theme.primaryForeground
        : theme.secondaryForeground;
    final double big = theme.radiusScale.xl;
    final double small = theme.radiusScale.sm;

    final TextStyle meta = theme
        .textStyle(CairnTypography.xs)
        .copyWith(color: theme.mutedForeground);

    final Widget bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(big),
          topRight: Radius.circular(big),
          bottomLeft: Radius.circular(sent ? big : small),
          bottomRight: Radius.circular(sent ? small : big),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CairnSpacing.s3,
          vertical: CairnSpacing.s2,
        ),
        child: DefaultTextStyle(
          style: theme.textStyle(CairnTypography.sm).copyWith(color: text),
          child: child,
        ),
      ),
    );

    final Widget column = Column(
      crossAxisAlignment: sent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        if (author != null) DefaultTextStyle(style: meta, child: author!),
        bubble,
        if (footer != null) DefaultTextStyle(style: meta, child: footer!),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double max = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.75
            : double.infinity;
        final Widget capped = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: max),
          child: column,
        );
        return Align(
          alignment: sent ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              if (!sent && avatar != null) avatar!,
              Flexible(child: capped),
              if (sent && avatar != null) avatar!,
            ],
          ),
        );
      },
    );
  }
}
