import 'package:flutter/widgets.dart';

/// shadcn/ui's border-radius scale, expressed in Flutter logical pixels.
///
/// shadcn/ui derives its whole radius scale from one CSS variable, `--radius`,
/// which defaults to `0.625rem` (10px). Tailwind's `rounded-*` utilities are
/// then remapped in the generated `@theme inline` block.
///
/// **This formula changed between shadcn/ui versions and is a common source of
/// stale values.** The older (Tailwind v3 era) theme used pixel offsets:
///
/// ```css
/// --radius-sm: calc(var(--radius) - 4px);
/// --radius-md: calc(var(--radius) - 2px);
/// --radius-lg: var(--radius);
/// --radius-xl: calc(var(--radius) + 4px);
/// ```
///
/// The current CLI (`packages/shadcn/src/utils/updaters/update-css-vars.ts`)
/// writes **multipliers** instead:
///
/// ```css
/// --radius-sm:  calc(var(--radius) * 0.6);
/// --radius-md:  calc(var(--radius) * 0.8);
/// --radius-lg:  var(--radius);
/// --radius-xl:  calc(var(--radius) * 1.4);
/// --radius-2xl: calc(var(--radius) * 1.8);
/// --radius-3xl: calc(var(--radius) * 2.2);
/// --radius-4xl: calc(var(--radius) * 2.6);
/// ```
///
/// At the default `--radius: 0.625rem` the two formulations happen to agree
/// exactly (6 / 8 / 10 / 14px) — the multipliers were chosen to preserve the
/// familiar defaults. They only diverge once `--radius` is customised, which is
/// why [CairnRadius.scaled] reproduces the multiplier form rather than baking
/// in the constants.
abstract final class CairnRadius {
  /// The base `--radius` value: `0.625rem` = 10 logical pixels.
  static const double base = 10.0;

  /// `rounded-none` — 0px.
  static const double none = 0.0;

  /// `rounded-xs` — 2px. A fixed Tailwind value, not derived from `--radius`.
  ///
  /// Used by the close-button affordance in Dialog and Sheet (`rounded-xs`).
  static const double xs = 2.0;

  /// `rounded-sm` — `--radius * 0.6` = 6px.
  static const double sm = 6.0;

  /// `rounded-md` — `--radius * 0.8` = 8px.
  ///
  /// The most common radius in the library: Button, Input, Textarea, Select
  /// trigger, Popover and Dropdown content all use it.
  static const double md = 8.0;

  /// `rounded-lg` — `--radius` = 10px. Used by Dialog, Alert and Tabs list.
  static const double lg = 10.0;

  /// `rounded-xl` — `--radius * 1.4` = 14px. Used by Card.
  static const double xl = 14.0;

  /// `rounded-2xl` — `--radius * 1.8` = 18px.
  static const double xl2 = 18.0;

  /// `rounded-3xl` — `--radius * 2.2` = 22px.
  static const double xl3 = 22.0;

  /// `rounded-4xl` — `--radius * 2.6` = 26px.
  static const double xl4 = 26.0;

  /// `rounded-full` — a very large radius that reads as a pill/circle.
  ///
  /// CSS uses `9999px`; Flutter clamps a [BorderRadius] to half the shorter
  /// side, so any sufficiently large number behaves identically.
  static const double full = 9999.0;

  /// Recomputes the scale for a custom `--radius` value, using shadcn/ui's
  /// current multiplier formula.
  ///
  /// ```dart
  /// // A tighter theme built on --radius: 0.375rem (6px).
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

/// A radius scale derived from a custom `--radius` base.
///
/// Produced by [CairnRadius.scaled]. Mirrors shadcn/ui's multiplier formula so
/// a themed app keeps proportional radii across every component.
@immutable
class CairnRadiusScale {
  /// Creates a scale from a `--radius` value in logical pixels.
  const CairnRadiusScale(this.base);

  /// The `--radius` base, in logical pixels.
  final double base;

  /// `calc(var(--radius) * 0.6)`.
  double get sm => base * 0.6;

  /// `calc(var(--radius) * 0.8)`.
  double get md => base * 0.8;

  /// `var(--radius)`.
  double get lg => base;

  /// `calc(var(--radius) * 1.4)`.
  double get xl => base * 1.4;

  /// `calc(var(--radius) * 1.8)`.
  double get xl2 => base * 1.8;

  /// `calc(var(--radius) * 2.2)`.
  double get xl3 => base * 2.2;

  /// `calc(var(--radius) * 2.6)`.
  double get xl4 => base * 2.6;

  @override
  bool operator ==(Object other) =>
      other is CairnRadiusScale && other.base == base;

  @override
  int get hashCode => base.hashCode;
}
