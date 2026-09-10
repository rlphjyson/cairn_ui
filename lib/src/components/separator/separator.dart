import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';

/// A one-pixel rule matching shadcn/ui's `Separator`.
///
/// `shrink-0 bg-border`, `h-px w-full` when horizontal and `h-full w-px` when
/// vertical.
///
/// The thickness is a literal CSS `1px`, which is one *logical* pixel in
/// Flutter — so on a 3x device it rasterises to three physical pixels, exactly
/// as a browser would on the same display.
///
/// [decorative] mirrors Radix's prop of the same name: a decorative separator
/// is hidden from assistive technology, while a semantic one is announced.
///
/// ```dart
/// const CairnSeparator();
/// const CairnSeparator(axis: Axis.vertical);
/// ```
class CairnSeparator extends StatelessWidget {
  /// Creates a separator.
  const CairnSeparator({
    super.key,
    this.axis = Axis.horizontal,
    this.decorative = true,
    this.thickness = 1.0,
    this.color,
  });

  /// The orientation. Horizontal fills width; vertical fills height.
  final Axis axis;

  /// Whether to hide this from assistive technology.
  final bool decorative;

  /// The rule thickness in logical pixels (`h-px` / `w-px`).
  final double thickness;

  /// Overrides the `--border` token.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Widget rule = ColoredBox(
      color: color ?? theme.border,
      child: axis == Axis.horizontal
          ? SizedBox(height: thickness, width: double.infinity)
          : SizedBox(width: thickness, height: double.infinity),
    );

    if (decorative) return ExcludeSemantics(child: rule);
    return Semantics(container: true, child: rule);
  }
}
