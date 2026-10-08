import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A window frame with three title-bar dots — the base for the other mockups.
///
/// `rounded-xl border` with a 40px title bar on a `muted` fill, three 10px
/// dots (drawn in neutral grey rather than the macOS red/amber/green, so the
/// frame sits in the theme instead of fighting it) and an optional [title]
/// centred in the bar. [child] fills the body on the `card` surface.
///
/// ```dart
/// const CairnMockupWindow(
///   title: Text('Untitled'),
///   child: Padding(padding: EdgeInsets.all(16), child: Text('Hello')),
/// );
/// ```
class CairnMockupWindow extends StatelessWidget {
  /// Creates a window mockup.
  const CairnMockupWindow({super.key, required this.child, this.title});

  /// The window body.
  final Widget child;

  /// Text in the title bar.
  final Widget? title;

  @override
  Widget build(BuildContext context) => _Frame(title: title, child: child);
}

/// A browser frame: window dots plus a pill-shaped address bar.
///
/// [url] is shown in the address bar in muted small text. [child] is the
/// "page" beneath it.
///
/// ```dart
/// const CairnMockupBrowser(
///   url: 'https://cairn.dev',
///   child: SizedBox(height: 160),
/// );
/// ```
class CairnMockupBrowser extends StatelessWidget {
  /// Creates a browser mockup.
  const CairnMockupBrowser({super.key, required this.child, this.url});

  /// The page content.
  final Widget child;

  /// The address shown in the bar.
  final String? url;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return _Frame(
      title: url == null
          ? null
          : Container(
              height: 24,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s3),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(theme.radiusScale.sm),
                border: Border.all(color: theme.border),
              ),
              child: Text(
                url!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textStyle(CairnTypography.xs)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
      stretchTitle: true,
      child: child,
    );
  }
}

/// A terminal-style code block.
///
/// Each of [lines] is drawn on its own row with a muted [prefix] gutter
/// (`$` by default) in the theme's foreground on a `muted` fill, in a
/// fixed-pitch face. Lines in [highlight] take the `accent` fill and full
/// foreground colour — for pointing at the line that matters.
///
/// This is a mockup, not a syntax highlighter; it displays text as given.
///
/// ```dart
/// const CairnMockupCode(lines: ['flutter pub add cairn_ui', 'flutter run']);
/// ```
class CairnMockupCode extends StatelessWidget {
  /// Creates a code mockup.
  const CairnMockupCode({
    super.key,
    required this.lines,
    this.prefix = r'$',
    this.highlight = const <int>{},
  });

  /// The code, one entry per line.
  final List<String> lines;

  /// The gutter marker, repeated on every line.
  final String prefix;

  /// Zero-based indexes of lines to emphasise.
  final Set<int> highlight;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle mono = theme
        .textStyle(CairnTypography.sm)
        .copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const <String>[
            'Menlo',
            'Consolas',
            'Courier New',
          ],
        );

    return Container(
      decoration: BoxDecoration(
        color: theme.muted,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < lines.length; i++)
            Container(
              color: highlight.contains(i) ? theme.accent : null,
              padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s5),
              child: Row(
                spacing: CairnSpacing.s3,
                children: <Widget>[
                  Text(
                    prefix,
                    style: mono.copyWith(
                      color: theme.mutedForeground.withValues(alpha: 0.7),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lines[i],
                      style: mono.copyWith(
                        color: highlight.isEmpty || highlight.contains(i)
                            ? theme.foreground
                            : theme.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A phone frame: a thick rounded bezel with a notch.
///
/// A 280px-wide device (override with [width]) at a 9:19.5 aspect ratio with a
/// 10px bezel in the `foreground` colour, a 36px-radius outer corner, and a
/// small pill notch. [child] fills the screen, clipped to its inner radius.
///
/// ```dart
/// const CairnMockupPhone(child: Center(child: Text('Hello')));
/// ```
class CairnMockupPhone extends StatelessWidget {
  /// Creates a phone mockup.
  const CairnMockupPhone({super.key, required this.child, this.width = 280.0});

  /// The screen content.
  final Widget child;

  /// The device width.
  final double width;

  /// `border-[10px]`.
  static const double _bezel = 10.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    const double outer = 36.0;

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 9 / 19.5,
        child: Container(
          padding: const EdgeInsets.all(_bezel),
          decoration: BoxDecoration(
            color: theme.foreground,
            borderRadius: BorderRadius.circular(outer),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(outer - _bezel),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ColoredBox(color: theme.background, child: child),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 72,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.foreground,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child, this.title, this.stretchTitle = false});

  final Widget child;
  final Widget? title;
  final bool stretchTitle;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    Widget dot() => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.mutedForeground.withValues(alpha: 0.4),
      ),
    );

    final Widget? titleWidget = title == null
        ? null
        : DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(color: theme.mutedForeground),
            child: title!,
          );

    return Container(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        border: Border.all(color: theme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40,
            color: theme.muted,
            padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s4),
            child: Row(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                dot(),
                dot(),
                dot(),
                if (titleWidget != null)
                  stretchTitle
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: CairnSpacing.s2,
                            ),
                            child: titleWidget,
                          ),
                        )
                      : Expanded(child: Center(child: titleWidget))
                else
                  const Spacer(),
              ],
            ),
          ),
          Container(height: 1, color: theme.border),
          child,
        ],
      ),
    );
  }
}
