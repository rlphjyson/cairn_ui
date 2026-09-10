/// Tailwind CSS's spacing scale, expressed in Flutter logical pixels.
///
/// Tailwind v4 defines a single spacing base — `--spacing: 0.25rem` — and every
/// numeric spacing utility is a multiple of it. With the browser default root
/// font size of 16px, `0.25rem` is 4px, so `p-4` is `4 * 4px = 16px`.
///
/// Flutter's logical pixel is the same unit as a CSS px at `devicePixelRatio`
/// 1, so the conversion is 1:1 with no scaling factor.
///
/// ```text
/// Tailwind class   rem      css px   CairnSpacing
/// gap-1            0.25rem  4px      CairnSpacing.s1
/// px-3             0.75rem  12px     CairnSpacing.s3
/// p-6              1.5rem   24px     CairnSpacing.s6
/// ```
abstract final class CairnSpacing {
  /// The Tailwind spacing base, `--spacing: 0.25rem` = 4 logical pixels.
  ///
  /// Prefer the named steps below; use this directly only when translating a
  /// class Tailwind expresses as a raw multiple of `--spacing`.
  static const double base = 4.0;

  /// `0` — zero spacing.
  static const double s0 = 0.0;

  /// `0.5` — 0.125rem / 2px.
  static const double s0p5 = 2.0;

  /// `1` — 0.25rem / 4px.
  static const double s1 = 4.0;

  /// `1.5` — 0.375rem / 6px.
  static const double s1p5 = 6.0;

  /// `2` — 0.5rem / 8px.
  static const double s2 = 8.0;

  /// `2.5` — 0.625rem / 10px.
  static const double s2p5 = 10.0;

  /// `3` — 0.75rem / 12px.
  static const double s3 = 12.0;

  /// `3.5` — 0.875rem / 14px.
  static const double s3p5 = 14.0;

  /// `4` — 1rem / 16px.
  static const double s4 = 16.0;

  /// `5` — 1.25rem / 20px.
  static const double s5 = 20.0;

  /// `6` — 1.5rem / 24px.
  static const double s6 = 24.0;

  /// `7` — 1.75rem / 28px.
  static const double s7 = 28.0;

  /// `8` — 2rem / 32px.
  static const double s8 = 32.0;

  /// `9` — 2.25rem / 36px.
  static const double s9 = 36.0;

  /// `10` — 2.5rem / 40px.
  static const double s10 = 40.0;

  /// `11` — 2.75rem / 44px.
  static const double s11 = 44.0;

  /// `12` — 3rem / 48px.
  static const double s12 = 48.0;

  /// `16` — 4rem / 64px.
  static const double s16 = 64.0;

  /// `20` — 5rem / 80px.
  static const double s20 = 80.0;

  /// `24` — 6rem / 96px.
  static const double s24 = 96.0;

  /// Resolves an arbitrary Tailwind spacing step to logical pixels.
  ///
  /// `CairnSpacing.step(3.5)` is `14.0`, matching `p-3.5`.
  static double step(double multiplier) => base * multiplier;
}
