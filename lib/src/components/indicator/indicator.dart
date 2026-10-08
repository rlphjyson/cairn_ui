import 'package:flutter/widgets.dart';

/// Where a [CairnIndicator]'s badge sits on its child.
enum CairnIndicatorPlacement {
  /// Top-left corner.
  topStart,

  /// Top-right corner.
  topEnd,

  /// Bottom-left corner.
  bottomStart,

  /// Bottom-right corner.
  bottomEnd,
}

/// Pins a small badge to a corner of [child] — an unread count on an icon, a
/// status dot on an avatar.
///
/// The [indicator] is centred on the corner of the child's box, so it straddles
/// the edge rather than sitting inside it. It does not take part in layout: the
/// indicator can overflow the child without changing the child's size, which is
/// what you want when the child is already positioned in a row.
///
/// Use a [CairnBadge] or [CairnStatus] as the indicator — both are sized for
/// this.
///
/// ```dart
/// CairnIndicator(
///   indicator: const CairnBadge(label: Text('3')),
///   child: const CairnAvatar(fallback: Text('RB')),
/// );
/// ```
class CairnIndicator extends StatelessWidget {
  /// Creates an indicator.
  const CairnIndicator({
    super.key,
    required this.child,
    required this.indicator,
    this.placement = CairnIndicatorPlacement.topEnd,
    this.offset = Offset.zero,
  });

  /// The widget being annotated.
  final Widget child;

  /// The badge.
  final Widget indicator;

  /// Which corner.
  final CairnIndicatorPlacement placement;

  /// A nudge applied after placement, for example to tuck a dot inside the
  /// edge of a circular avatar.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final bool top =
        placement == CairnIndicatorPlacement.topStart ||
        placement == CairnIndicatorPlacement.topEnd;
    final bool end =
        placement == CairnIndicatorPlacement.topEnd ||
        placement == CairnIndicatorPlacement.bottomEnd;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: AlignmentDirectional(end ? 1 : -1, top ? -1 : 1),
              // Translating by half the indicator's own size, as a fraction,
              // centres it on the corner without needing to measure it.
              child: FractionalTranslation(
                translation: Offset(end ? 0.5 : -0.5, top ? -0.5 : 0.5),
                child: Transform.translate(offset: offset, child: indicator),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
