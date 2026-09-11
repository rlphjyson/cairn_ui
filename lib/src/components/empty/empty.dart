import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// An empty-state placeholder.
///
/// `flex flex-col items-center justify-center gap-6 rounded-lg border-dashed
/// p-6 text-center md:p-12` with a `size-16 rounded-md bg-muted` media slot, a
/// `text-lg font-medium tracking-tight` title and a
/// `text-sm/relaxed text-muted-foreground` description.
///
/// Note the border is **dashed**, which Flutter's [Border] cannot draw — see
/// the custom painter below.
///
/// ```dart
/// CairnEmpty(
///   media: const CairnIcon(CairnIconData.search, size: 32),
///   title: 'No results',
///   description: 'Try adjusting your filters.',
///   actions: [CairnButton(onPressed: () {}, child: const Text('Reset'))],
/// );
/// ```
class CairnEmpty extends StatelessWidget {
  /// Creates an empty state.
  const CairnEmpty({
    super.key,
    this.title,
    this.description,
    this.media,
    this.actions = const <Widget>[],
    this.bordered = true,
  });

  /// The heading.
  final String? title;

  /// The supporting text.
  final String? description;

  /// An icon or illustration, shown in a `size-16 bg-muted` tile.
  final Widget? media;

  /// Actions below the text.
  final List<Widget> actions;

  /// Whether to draw the dashed border.
  final bool bordered;

  /// Tailwind's `md` breakpoint.
  static const double _mdBreakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= _mdBreakpoint;

    final Widget content = Padding(
      // `p-6 md:p-12`.
      padding: EdgeInsets.all(wide ? CairnSpacing.s12 : CairnSpacing.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: CairnSpacing.s6,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              if (media != null)
                Container(
                  // `size-16 rounded-md bg-muted`.
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: CairnSpacing.s2),
                  decoration: BoxDecoration(
                    color: theme.muted,
                    borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(
                        color: theme.mutedForeground,
                        size: 32,
                      ),
                      child: media!,
                    ),
                  ),
                ),
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme
                      .textStyle(CairnTypography.lg)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        letterSpacing: CairnTypography.trackingTight(18),
                        color: theme.foreground,
                      ),
                ),
              if (description != null)
                ConstrainedBox(
                  // `max-w-sm`.
                  constraints: const BoxConstraints(maxWidth: 384),
                  child: Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(
                          // `text-sm/relaxed`.
                          height: CairnTypography.leadingRelaxed,
                          color: theme.mutedForeground,
                        ),
                  ),
                ),
            ],
          ),
          if (actions.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: CairnSpacing.s2,
              runSpacing: CairnSpacing.s2,
              children: actions,
            ),
        ],
      ),
    );

    if (!bordered) return content;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: theme.border,
        radius: theme.radiusScale.lg,
      ),
      child: content,
    );
  }
}

/// Draws a dashed rounded rectangle.
///
/// Flutter's [Border] only paints solid strokes, so `border-dashed` has to be
/// drawn by hand. This walks the rounded-rect path with [PathMetric] and emits
/// alternating on/off segments, which keeps the dashes evenly spaced around the
/// corners rather than bunching at them.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  /// Tailwind's `border-dashed` renders roughly 4px on, 4px off at a 1px
  /// stroke, which these reproduce.
  static const double dash = 4.0;
  static const double gap = 4.0;
  static const double strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
