import 'package:flutter/widgets.dart';

import '../theme/cairn_theme.dart';
import 'oklch.dart';

/// A semantic intent a component can be tinted with.
///
/// shadcn/ui's palette stops at `primary`, `secondary` and `destructive`.
/// Components that communicate *state* — a Status dot, a Steps indicator, a
/// Timeline marker — need a few more intents than that, so Cairn adds three
/// (`success`, `warning`, `info`) as an extension of the token layer rather
/// than as colours hardcoded into each component.
enum CairnTone {
  /// A de-emphasised grey — the `mutedForeground` token.
  neutral,

  /// The theme's `primary` slot.
  primary,

  /// Something completed or healthy.
  success,

  /// Something that needs attention.
  warning,

  /// Something informational.
  info,

  /// The theme's `destructive` slot.
  destructive,
}

/// A fill and the foreground that belongs on it.
@immutable
class CairnToneColor {
  /// Creates a fill/foreground pair.
  const CairnToneColor(this.fill, this.onFill);

  /// The solid colour for dots, markers and filled shapes.
  final Color fill;

  /// The colour for text and icons placed on [fill].
  final Color onFill;
}

/// Resolves a [CairnTone] to concrete colours for a [CairnTheme].
///
/// Like every other Cairn colour, the additions are authored in OKLCH and
/// converted by the package, so their provenance is checkable. The light
/// values sit at Tailwind's 600 step (500 for warning, which needs the extra
/// lightness to read as amber rather than brown) and the dark values at the
/// 400 step, mirroring how `destructive` is lifted in the dark theme.
abstract final class CairnToneColors {
  // `oklch(0.627 0.194 149.214)` — green-600.
  static final Color _successLight = Oklch.toColor(0.627, 0.194, 149.214);
  // `oklch(0.792 0.209 151.711)` — green-400.
  static final Color _successDark = Oklch.toColor(0.792, 0.209, 151.711);
  // `oklch(0.769 0.188 70.08)` — amber-500.
  static final Color _warningLight = Oklch.toColor(0.769, 0.188, 70.08);
  // `oklch(0.828 0.189 84.429)` — amber-400.
  static final Color _warningDark = Oklch.toColor(0.828, 0.189, 84.429);
  // `oklch(0.546 0.245 262.881)` — blue-600.
  static final Color _infoLight = Oklch.toColor(0.546, 0.245, 262.881);
  // `oklch(0.707 0.165 254.624)` — blue-400.
  static final Color _infoDark = Oklch.toColor(0.707, 0.165, 254.624);

  static const Color _white = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF0A0A0A);

  /// The colours for [tone] under [theme].
  static CairnToneColor resolve(CairnTheme theme, CairnTone tone) {
    final bool dark = theme.brightness == Brightness.dark;
    return switch (tone) {
      CairnTone.neutral => CairnToneColor(
        theme.mutedForeground,
        theme.background,
      ),
      CairnTone.primary => CairnToneColor(
        theme.primary,
        theme.primaryForeground,
      ),
      CairnTone.success => CairnToneColor(
        dark ? _successDark : _successLight,
        dark ? _ink : _white,
      ),
      CairnTone.warning => CairnToneColor(
        dark ? _warningDark : _warningLight,
        _ink,
      ),
      CairnTone.info => CairnToneColor(
        dark ? _infoDark : _infoLight,
        dark ? _ink : _white,
      ),
      CairnTone.destructive => CairnToneColor(
        theme.destructive,
        theme.destructiveForeground,
      ),
    };
  }
}
