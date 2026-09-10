import 'package:flutter/widgets.dart';

/// Tailwind CSS's type scale, expressed as Flutter [TextStyle]s.
///
/// ## Font size and line height
///
/// Tailwind's `text-*` utilities set a font size *and* a paired line height.
/// Both are authored in `rem`, which resolves against the 16px browser root
/// font size, so `text-sm` is `0.875rem / 1.25rem` = 14px text on a 20px line.
///
/// Flutter expresses line height as [TextStyle.height], a **multiple of the
/// font size**, not an absolute length. The conversion is therefore:
///
/// ```text
/// height = cssLineHeightPx / cssFontSizePx
/// text-sm -> 20 / 14 = 1.4285714...
/// ```
///
/// Baking the ratio rather than the pixel value is what keeps a component's
/// intrinsic height correct when a user scales text.
///
/// ## `leading-none`
///
/// Several shadcn/ui components (Card title, Dialog title, Label) use
/// `leading-none`, which is `line-height: 1`. Flutter's default when [height]
/// is null is *not* 1 — it is the font's own metric ascent+descent, typically
/// ~1.2 — so these must set `height: 1.0` explicitly or titles sit lower than
/// the reference. [leadingNone] exists for exactly that case.
///
/// ## Font family
///
/// shadcn/ui's own site ships Geist; the components themselves only ever say
/// `font-sans`, inheriting whatever the host app sets. Cairn matches that
/// behaviour: [CairnTypography] leaves [TextStyle.fontFamily] null so the
/// ambient font applies, and the golden tests pin a bundled font so rendering
/// is deterministic. See `README.md` for the golden-font setup.
abstract final class CairnTypography {
  /// `text-xs` — 0.75rem / 1rem (12px on a 16px line).
  ///
  /// Badge, Kbd, Tooltip content, menu shortcuts and Select group labels.
  static const TextStyle xs = TextStyle(
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: normal,
  );

  /// `text-sm` — 0.875rem / 1.25rem (14px on a 20px line).
  ///
  /// The library's workhorse size: Button, Input, Label, menu items, Table.
  static const TextStyle sm = TextStyle(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: normal,
  );

  /// `text-base` — 1rem / 1.5rem (16px on a 24px line).
  static const TextStyle base = TextStyle(
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: normal,
  );

  /// `text-lg` — 1.125rem / 1.75rem (18px on a 28px line).
  ///
  /// Dialog and Alert Dialog titles.
  static const TextStyle lg = TextStyle(
    fontSize: 18.0,
    height: 28.0 / 18.0,
    fontWeight: normal,
  );

  /// `text-xl` — 1.25rem / 1.75rem (20px on a 28px line).
  static const TextStyle xl = TextStyle(
    fontSize: 20.0,
    height: 28.0 / 20.0,
    fontWeight: normal,
  );

  /// `text-2xl` — 1.5rem / 2rem (24px on a 32px line).
  static const TextStyle xl2 = TextStyle(
    fontSize: 24.0,
    height: 32.0 / 24.0,
    fontWeight: normal,
  );

  /// `text-3xl` — 1.875rem / 2.25rem (30px on a 36px line).
  static const TextStyle xl3 = TextStyle(
    fontSize: 30.0,
    height: 36.0 / 30.0,
    fontWeight: normal,
  );

  /// `text-4xl` — 2.25rem / 2.5rem (36px on a 40px line).
  static const TextStyle xl4 = TextStyle(
    fontSize: 36.0,
    height: 40.0 / 36.0,
    fontWeight: normal,
  );

  /// `font-normal` — CSS weight 400.
  static const FontWeight normal = FontWeight.w400;

  /// `font-medium` — CSS weight 500.
  ///
  /// Button labels, Label, Alert titles, menu group labels.
  static const FontWeight medium = FontWeight.w500;

  /// `font-semibold` — CSS weight 600.
  ///
  /// Card, Dialog and Sheet titles.
  static const FontWeight semibold = FontWeight.w600;

  /// `font-bold` — CSS weight 700.
  static const FontWeight bold = FontWeight.w700;

  /// `leading-none` — `line-height: 1`.
  ///
  /// Must be applied explicitly; Flutter's default line height comes from font
  /// metrics (~1.2), not 1.0.
  static const double leadingNone = 1.0;

  /// `leading-relaxed` — `line-height: 1.625`.
  static const double leadingRelaxed = 1.625;

  /// `tracking-tight` — `letter-spacing: -0.025em`.
  ///
  /// Returns an absolute value in logical pixels, because Flutter's
  /// [TextStyle.letterSpacing] is absolute where CSS's `em` is relative.
  static double trackingTight(double fontSize) => fontSize * -0.025;

  /// `tracking-widest` — `letter-spacing: 0.1em`. Used by menu shortcuts.
  static double trackingWidest(double fontSize) => fontSize * 0.1;
}
