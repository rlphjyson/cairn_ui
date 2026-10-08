import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A landing-page header block: headline, supporting copy and actions.
///
/// A centred column — [title] in 36px semibold with tight tracking (`text-4xl
/// font-semibold tracking-tight`), [description] in 18px muted text capped at
/// 36rem for a comfortable measure, and [actions] in a wrapping row beneath. An
/// [eyebrow] (a [CairnBadge], typically) sits above the headline.
///
/// By default the hero is transparent so it inherits the page surface. Pass
/// [muted] for a `muted` filled band, or [background] for any other widget
/// (an image, a gradient) painted behind the content.
///
/// ```dart
/// CairnHero(
///   eyebrow: CairnBadge(label: Text('New')),
///   title: Text('Build faster'),
///   description: Text('Everything you need to ship.'),
///   actions: [CairnButton(onPressed: () {}, child: Text('Get started'))],
/// );
/// ```
class CairnHero extends StatelessWidget {
  /// Creates a hero.
  const CairnHero({
    super.key,
    required this.title,
    this.description,
    this.eyebrow,
    this.actions = const <Widget>[],
    this.alignment = CrossAxisAlignment.center,
    this.muted = false,
    this.background,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CairnSpacing.s6,
      vertical: CairnSpacing.s20,
    ),
  });

  /// The headline.
  final Widget title;

  /// Supporting copy.
  final Widget? description;

  /// A small element above the headline.
  final Widget? eyebrow;

  /// Calls to action.
  final List<Widget> actions;

  /// Horizontal alignment of the content.
  final CrossAxisAlignment alignment;

  /// Whether to fill the band with the `muted` token.
  final bool muted;

  /// A widget painted behind the content.
  final Widget? background;

  /// Space around the content.
  final EdgeInsetsGeometry padding;

  /// `max-w-xl` — the line length for the description.
  static const double _measure = 576.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool centered = alignment == CrossAxisAlignment.center;
    final TextAlign textAlign = centered ? TextAlign.center : TextAlign.start;
    final WrapAlignment wrapAlign = centered
        ? WrapAlignment.center
        : WrapAlignment.start;

    final Widget content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignment,
        spacing: CairnSpacing.s4,
        children: <Widget>[
          ?eyebrow,
          DefaultTextStyle(
            textAlign: textAlign,
            style: theme
                .textStyle(CairnTypography.xl4)
                .copyWith(
                  fontWeight: CairnTypography.semibold,
                  letterSpacing: CairnTypography.trackingTight(36),
                  color: theme.foreground,
                ),
            child: title,
          ),
          if (description != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _measure),
              child: DefaultTextStyle(
                textAlign: textAlign,
                style: theme
                    .textStyle(CairnTypography.lg)
                    .copyWith(color: theme.mutedForeground),
                child: description!,
              ),
            ),
          if (actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: CairnSpacing.s2),
              child: Wrap(
                alignment: wrapAlign,
                spacing: CairnSpacing.s3,
                runSpacing: CairnSpacing.s3,
                children: actions,
              ),
            ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      color: muted ? theme.muted : null,
      child: Stack(
        children: <Widget>[
          if (background != null) Positioned.fill(child: background!),
          Align(
            alignment: centered ? Alignment.center : Alignment.centerLeft,
            child: content,
          ),
        ],
      ),
    );
  }
}
