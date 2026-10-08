import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';

/// A top application bar with start, centre and end regions.
///
/// A 56px bar on the `background` surface with a 1px bottom [CairnTheme.border]
/// hairline and 16px side padding — the shell most apps put a logo, primary
/// navigation and an account menu into. Regions are optional: with only
/// [start] and [end] the bar justifies them to the edges; a [center] is truly
/// centred on the bar, not merely between its neighbours, so a logo does not
/// drift when the two sides have different widths.
///
/// Wrap with `SafeArea` yourself on mobile; the navbar draws only its own box.
///
/// ```dart
/// CairnNavbar(
///   start: Text('Cairn'),
///   center: CairnTabs(...),
///   end: CairnAvatar(...),
/// );
/// ```
class CairnNavbar extends StatelessWidget {
  /// Creates a navbar.
  const CairnNavbar({
    super.key,
    this.start,
    this.center,
    this.end,
    this.height = 56.0,
    this.bordered = true,
    this.color,
  });

  /// Leading content — logo, back button, menu toggle.
  final Widget? start;

  /// Centred content.
  final Widget? center;

  /// Trailing content — actions, account menu.
  final Widget? end;

  /// The bar height (`h-14`).
  final double height;

  /// Whether to draw the bottom hairline.
  final bool bordered;

  /// Overrides the `background` fill — for example `theme.card` for a raised
  /// bar.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s4),
        decoration: BoxDecoration(
          color: color ?? theme.background,
          border: bordered
              ? Border(bottom: BorderSide(color: theme.border))
              : null,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.foreground),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Align(alignment: AlignmentDirectional.centerStart, child: start),
              if (center != null) Center(child: center),
              Align(alignment: AlignmentDirectional.centerEnd, child: end),
            ],
          ),
        ),
      ),
    );
  }
}
