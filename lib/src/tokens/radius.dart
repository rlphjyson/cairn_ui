import 'package:flutter/widgets.dart';

/// Cairn's border-radius scale, expressed in Flutter logical pixels.
///
/// The entire scale derives from a single base value, [base], which defaults to
/// 10 logical pixels. Every step is a fixed **multiple** of that base:
///
/// ```text
/// xs  = 2 (fixed)
/// sm  = base * 0.6   ->  6
/// md  = base * 0.8   ->  8
/// lg  = base         -> 10
/// xl  = base * 1.4   -> 14
/// 2xl = base * 1.8   -> 18
/// 3xl = base * 2.2   -> 22
/// 4xl = base * 2.6   -> 26
/// ```
///
/// Multipliers rather than offsets is a deliberate choice. The obvious
/// alternative — fixed pixel offsets from the base (`base - 4`, `base - 2`,
/// `base + 4`) — produces identical numbers at the default base, but falls
/// apart the moment the base is retuned: a compact 4px theme would give a
/// *negative* small radius, and a generous 24px theme would compress the whole
/// scale into a narrow band. A proportional scale holds its shape at any base,
/// so changing `CairnTheme.radius` rescales every corner in the library
/// coherently instead of requiring a per-component audit. [CairnRadius.scaled]
/// is that computation.
abstract final class CairnRadius {
  /// The base radius: 10 logical pixels.
  static const double base = 10.0;

  /// No rounding — 0px.
  static const double none = 0.0;

  /// 2px. A fixed step rather than a multiple of [base].
  ///
  /// Used by the close-button affordance in Dialog and Sheet, where the target
  /// is small enough that a proportional radius would read as a circle.
  static const double xs = 2.0;

  /// `base * 0.6` = 6px.
  static const double sm = 6.0;

  /// `base * 0.8` = 8px.
  ///
  /// The most common radius in the library: Button, Input, Textarea, Select
  /// trigger, Popover and Dropdown content all use it.
  static const double md = 8.0;

  /// `base` = 10px. Used by Dialog, Alert and Tabs list.
  static const double lg = 10.0;

  /// `base * 1.4` = 14px. Used by Card.
  static const double xl = 14.0;

  /// `base * 1.8` = 18px.
  static const double xl2 = 18.0;

  /// `base * 2.2` = 22px.
  static const double xl3 = 22.0;

  /// `base * 2.6` = 26px.
  static const double xl4 = 26.0;

  /// A very large radius that reads as a pill or circle.
  ///
  /// CSS uses `9999px`; Flutter clamps a [BorderRadius] to half the shorter
  /// side, so any sufficiently large number behaves identically.
  static const double full = 9999.0;

  /// Recomputes the whole scale for a custom base radius.
  ///
  /// ```dart
  /// // A tighter theme built on a 6px base.
  /// CairnRadius.scaled(6).md; // 4.8
  /// ```
  static CairnRadiusScale scaled(double radius) => CairnRadiusScale(radius);

  /// `BorderRadius.circular(CairnRadius.sm)`.
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));

  /// `BorderRadius.circular(CairnRadius.md)`.
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));

  /// `BorderRadius.circular(CairnRadius.lg)`.
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));

  /// `BorderRadius.circular(CairnRadius.xl)`.
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));

  /// `BorderRadius.circular(CairnRadius.full)`.
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}

/// A radius scale derived from a custom base radius.
///
/// Produced by [CairnRadius.scaled]. Applies the same multipliers as the
/// default scale, so a retuned theme keeps proportional radii across every
/// component.
@immutable
class CairnRadiusScale {
  /// Creates a scale from a base radius in logical pixels.
  const CairnRadiusScale(this.base);

  /// The base radius, in logical pixels.
  final double base;

  /// `base * 0.6`.
  double get sm => base * 0.6;

  /// `base * 0.8`.
  double get md => base * 0.8;

  /// `base`.
  double get lg => base;

  /// `base * 1.4`.
  double get xl => base * 1.4;

  /// `base * 1.8`.
  double get xl2 => base * 1.8;

  /// `base * 2.2`.
  double get xl3 => base * 2.2;

  /// `base * 2.6`.
  double get xl4 => base * 2.6;

  @override
  bool operator ==(Object other) =>
      other is CairnRadiusScale && other.base == base;

  @override
  int get hashCode => base.hashCode;
}
