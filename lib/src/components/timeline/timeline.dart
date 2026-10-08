import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/tones.dart';
import '../../tokens/typography.dart';

/// One event on a [CairnTimeline].
@immutable
class CairnTimelineItem {
  /// Creates a timeline event.
  const CairnTimelineItem({
    required this.title,
    this.description,
    this.time,
    this.icon,
    this.tone = CairnTone.neutral,
  });

  /// What happened.
  final Widget title;

  /// Detail beneath the title.
  final Widget? description;

  /// When it happened — rendered in muted text beside the title.
  final Widget? time;

  /// A glyph inside the marker. Without one the marker is a plain dot.
  final Widget? icon;

  /// The marker colour.
  final CairnTone tone;
}

/// A vertical sequence of events joined by a line.
///
/// Each event has a marker on a shared left rail with a 1px [CairnTheme.border]
/// line running through to the next. A marker with an [CairnTimelineItem.icon]
/// is a 24px filled circle; without one it is an 8px dot centred on the same
/// rail, so mixed timelines stay aligned.
///
/// ```dart
/// const CairnTimeline(items: [
///   CairnTimelineItem(
///     tone: CairnTone.success,
///     title: Text('Deployed'),
///     time: Text('2m ago'),
///   ),
/// ]);
/// ```
class CairnTimeline extends StatelessWidget {
  /// Creates a timeline.
  const CairnTimeline({super.key, required this.items});

  /// The events, top to bottom.
  final List<CairnTimelineItem> items;

  /// The marker rail width — wide enough for the 24px icon marker.
  static const double _rail = 24.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: _rail,
                  child: Column(
                    children: <Widget>[
                      _marker(theme, items[i]),
                      if (i < items.length - 1)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: CairnSpacing.s1,
                            ),
                            child: Container(width: 1, color: theme.border),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: CairnSpacing.s3),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < items.length - 1 ? CairnSpacing.s6 : 0,
                    ),
                    child: _content(theme, items[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _marker(CairnTheme theme, CairnTimelineItem item) {
    final CairnToneColor colors = CairnToneColors.resolve(theme, item.tone);
    if (item.icon == null) {
      return SizedBox(
        width: _rail,
        height: _rail,
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.fill,
            ),
          ),
        ),
      );
    }
    return Container(
      width: _rail,
      height: _rail,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.fill),
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: colors.onFill, size: 14),
          child: item.icon!,
        ),
      ),
    );
  }

  Widget _content(CairnTheme theme, CairnTimelineItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The title line is 24px tall (matching the marker) so the text's
        // optical centre lines up with the marker's centre.
        SizedBox(
          height: _rail,
          child: Row(
            spacing: CairnSpacing.s2,
            children: <Widget>[
              Flexible(
                child: DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        color: theme.foreground,
                      ),
                  child: item.title,
                ),
              ),
              if (item.time != null)
                DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.xs)
                      .copyWith(color: theme.mutedForeground),
                  child: item.time!,
                ),
            ],
          ),
        ),
        if (item.description != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
            child: item.description!,
          ),
      ],
    );
  }
}
