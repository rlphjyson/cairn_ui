import 'package:flutter/widgets.dart';

/// Cairn's semantic color tokens, as Flutter [Color] constants.
///
/// ## How the palette is built
///
/// Cairn ships one neutral base palette in two themes. Every value is authored
/// in the CSS `oklch()` color function rather than as hex, because OKLCH is
/// perceptually uniform: the light and dark themes are two readings of the same
/// lightness ramp, so a pair that is legible in one is legible in the other by
/// construction rather than by eye. Each constant below records the literal
/// `oklch()` string it was authored as, and `test/tokens/colors_test.dart`
/// re-derives every constant through [Oklch.toColor] to prove the baked value
/// still matches that source.
///
/// The achromatic steps land exactly on Tailwind's published `neutral` ramp —
/// `oklch(0.145 0 0)` is `#0A0A0A` (neutral-950), `oklch(0.922 0 0)` is
/// `#E5E5E5` (neutral-200). That is both an independent check that the OKLab
/// pipeline is correct and a convenience: Cairn's greys sit flush against a
/// Tailwind-flavoured design without a seam.
///
/// ## Roles, not shades
///
/// Tokens are named for the job they do — `primary`, `mutedForeground`,
/// `border` — never for how they look. A component asks for *the foreground
/// that belongs on a destructive surface*, not for white, which is what makes
/// overriding a single slot in [CairnTheme] re-theme every component that
/// reads it.
///
/// These raw constants are rarely used directly; consume them through
/// [CairnTheme], which exposes the same slots and supports overriding.
abstract final class CairnColors {
  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  /// `background` = `oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// `foreground` = `oklch(0.145 0 0)` — `#0A0A0A` (neutral-950).
  static const Color lightForeground = Color(0xFF0A0A0A);

  /// `card` = `oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// `cardForeground` = `oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color lightCardForeground = Color(0xFF0A0A0A);

  /// `popover` = `oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightPopover = Color(0xFFFFFFFF);

  /// `popoverForeground` = `oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color lightPopoverForeground = Color(0xFF0A0A0A);

  /// `primary` = `oklch(0.205 0 0)` — `#171717` (neutral-900).
  static const Color lightPrimary = Color(0xFF171717);

  /// `primaryForeground` = `oklch(0.985 0 0)` — `#FAFAFA` (neutral-50).
  static const Color lightPrimaryForeground = Color(0xFFFAFAFA);

  /// `secondary` = `oklch(0.97 0 0)` — `#F5F5F5` (neutral-100).
  static const Color lightSecondary = Color(0xFFF5F5F5);

  /// `secondaryForeground` = `oklch(0.205 0 0)` — `#171717`.
  static const Color lightSecondaryForeground = Color(0xFF171717);

  /// `muted` = `oklch(0.97 0 0)` — `#F5F5F5`.
  static const Color lightMuted = Color(0xFFF5F5F5);

  /// `mutedForeground` = `oklch(0.556 0 0)` — `#737373` (neutral-500).
  static const Color lightMutedForeground = Color(0xFF737373);

  /// `accent` = `oklch(0.97 0 0)` — `#F5F5F5`.
  static const Color lightAccent = Color(0xFFF5F5F5);

  /// `accentForeground` = `oklch(0.205 0 0)` — `#171717`.
  static const Color lightAccentForeground = Color(0xFF171717);

  /// `destructive` = `oklch(0.577 0.245 27.325)` — `#E7000B` (red-600).
  static const Color lightDestructive = Color(0xFFE7000B);

  /// The foreground that sits on destructive surfaces.
  ///
  /// Kept as its own slot rather than hardcoding white into destructive
  /// Buttons and Badges: a theme that softens the destructive fill needs to
  /// move the text on it too, and a hardcoded colour would leave that
  /// unreachable. The default is white, which is what the default red needs.
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF);

  /// `border` = `oklch(0.922 0 0)` — `#E5E5E5` (neutral-200).
  static const Color lightBorder = Color(0xFFE5E5E5);

  /// `input` = `oklch(0.922 0 0)` — `#E5E5E5`.
  static const Color lightInput = Color(0xFFE5E5E5);

  /// `ring` = `oklch(0.708 0 0)` — `#A1A1A1` (neutral-400).
  static const Color lightRing = Color(0xFFA1A1A1);

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  /// `background` = `oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color darkBackground = Color(0xFF0A0A0A);

  /// `foreground` = `oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkForeground = Color(0xFFFAFAFA);

  /// `card` = `oklch(0.205 0 0)` — `#171717`.
  ///
  /// Dark cards sit *lighter* than the page, inverting the light theme's
  /// relationship where the card is white on a near-white page.
  static const Color darkCard = Color(0xFF171717);

  /// `cardForeground` = `oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkCardForeground = Color(0xFFFAFAFA);

  /// `popover` = `oklch(0.205 0 0)` — `#171717`.
  static const Color darkPopover = Color(0xFF171717);

  /// `popoverForeground` = `oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkPopoverForeground = Color(0xFFFAFAFA);

  /// `primary` = `oklch(0.922 0 0)` — `#E5E5E5` (neutral-200).
  static const Color darkPrimary = Color(0xFFE5E5E5);

  /// `primaryForeground` = `oklch(0.205 0 0)` — `#171717`.
  static const Color darkPrimaryForeground = Color(0xFF171717);

  /// `secondary` = `oklch(0.269 0 0)` — `#262626` (neutral-800).
  static const Color darkSecondary = Color(0xFF262626);

  /// `secondaryForeground` = `oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkSecondaryForeground = Color(0xFFFAFAFA);

  /// `muted` = `oklch(0.269 0 0)` — `#262626`.
  static const Color darkMuted = Color(0xFF262626);

  /// `mutedForeground` = `oklch(0.708 0 0)` — `#A1A1A1`.
  static const Color darkMutedForeground = Color(0xFFA1A1A1);

  /// `accent` = `oklch(0.269 0 0)` — `#262626`.
  static const Color darkAccent = Color(0xFF262626);

  /// `accentForeground` = `oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkAccentForeground = Color(0xFFFAFAFA);

  /// `destructive` = `oklch(0.704 0.191 22.216)` — `#FF6467` (red-400).
  static const Color darkDestructive = Color(0xFFFF6467);

  /// White. The destructive fill stays saturated in the dark theme, so the
  /// foreground pairing does not change between themes.
  static const Color darkDestructiveForeground = Color(0xFFFFFFFF);

  /// `border` = `oklch(1 0 0 / 10%)` — white at 10% alpha.
  ///
  /// The dark theme switches borders from an opaque grey to a translucent
  /// white so they lift correctly over both the page and raised card surfaces.
  static const Color darkBorder = Color(0x1AFFFFFF);

  /// `input` = `oklch(1 0 0 / 15%)` — white at 15% alpha.
  static const Color darkInput = Color(0x26FFFFFF);

  /// `ring` = `oklch(0.556 0 0)` — `#737373`.
  static const Color darkRing = Color(0xFF737373);

  // ---------------------------------------------------------------------------
  // Chart ramp (shared by both themes)
  // ---------------------------------------------------------------------------

  /// `chart1` = `oklch(0.87 0 0)` — `#D4D4D4`.
  static const Color chart1 = Color(0xFFD4D4D4);

  /// `chart2` = `oklch(0.556 0 0)` — `#737373`.
  static const Color chart2 = Color(0xFF737373);

  /// `chart3` = `oklch(0.439 0 0)` — `#525252`.
  static const Color chart3 = Color(0xFF525252);

  /// `chart4` = `oklch(0.371 0 0)` — `#404040`.
  static const Color chart4 = Color(0xFF404040);

  /// `chart5` = `oklch(0.269 0 0)` — `#262626`.
  static const Color chart5 = Color(0xFF262626);

  // ---------------------------------------------------------------------------
  // Fixed values that are identical in both themes and deliberately not slots
  // ---------------------------------------------------------------------------

  /// The scrim behind Dialog, Alert Dialog, Sheet and Drawer.
  ///
  /// Black at 50%, and deliberately not a theme slot: a scrim's job is to
  /// darken whatever happens to be behind it, which is the same job in both
  /// themes.
  static const Color overlay = Color(0x80000000);

  /// Pure white, for text on destructive fills and for the Slider thumb, which
  /// stays white in both themes.
  static const Color white = Color(0xFFFFFFFF);
}
