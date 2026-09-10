import 'package:flutter/widgets.dart';

/// shadcn/ui's default semantic color tokens, as Flutter [Color] constants.
///
/// ## Provenance
///
/// These are shadcn/ui's **Neutral** base colors — the current CLI default —
/// taken from the registry endpoint `https://ui.shadcn.com/r/colors/neutral.json`
/// and cross-checked against `apps/v4/app/globals.css` in `shadcn-ui/ui`.
///
/// shadcn/ui authors them in the CSS `oklch()` color function (it moved off HSL
/// during the Tailwind v4 / "v4 registry" rework). Each constant below records
/// the literal `oklch()` string it came from, and
/// `test/tokens/colors_test.dart` re-derives every constant through
/// [Oklch.toColor] to prove the baked value matches its source.
///
/// The conversion lands exactly on Tailwind's published `neutral` ramp — e.g.
/// `oklch(0.145 0 0)` is `#0A0A0A` (neutral-950) and `oklch(0.922 0 0)` is
/// `#E5E5E5` (neutral-200) — which is a useful independent check that the
/// OKLab pipeline is right.
///
/// ## A note on the docs site
///
/// `apps/v4/app/globals.css` is the **documentation site's** theme, and it
/// overrides a couple of tokens for its own branding (`--foreground` and
/// `--primary` are pure black there, `oklch(0% 0 0)`, rather than the
/// registry's `0.145` / `0.205`). Cairn follows the **registry** values, which
/// are what `npx shadcn init` actually writes into a consumer's project.
///
/// These raw constants are rarely used directly — consume them through
/// [CairnTheme], which maps them onto semantic slots and supports overriding.
abstract final class CairnColors {
  // ---------------------------------------------------------------------------
  // Light theme (`:root`)
  // ---------------------------------------------------------------------------

  /// `--background: oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// `--foreground: oklch(0.145 0 0)` — `#0A0A0A` (neutral-950).
  static const Color lightForeground = Color(0xFF0A0A0A);

  /// `--card: oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// `--card-foreground: oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color lightCardForeground = Color(0xFF0A0A0A);

  /// `--popover: oklch(1 0 0)` — `#FFFFFF`.
  static const Color lightPopover = Color(0xFFFFFFFF);

  /// `--popover-foreground: oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color lightPopoverForeground = Color(0xFF0A0A0A);

  /// `--primary: oklch(0.205 0 0)` — `#171717` (neutral-900).
  static const Color lightPrimary = Color(0xFF171717);

  /// `--primary-foreground: oklch(0.985 0 0)` — `#FAFAFA` (neutral-50).
  static const Color lightPrimaryForeground = Color(0xFFFAFAFA);

  /// `--secondary: oklch(0.97 0 0)` — `#F5F5F5` (neutral-100).
  static const Color lightSecondary = Color(0xFFF5F5F5);

  /// `--secondary-foreground: oklch(0.205 0 0)` — `#171717`.
  static const Color lightSecondaryForeground = Color(0xFF171717);

  /// `--muted: oklch(0.97 0 0)` — `#F5F5F5`.
  static const Color lightMuted = Color(0xFFF5F5F5);

  /// `--muted-foreground: oklch(0.556 0 0)` — `#737373` (neutral-500).
  static const Color lightMutedForeground = Color(0xFF737373);

  /// `--accent: oklch(0.97 0 0)` — `#F5F5F5`.
  static const Color lightAccent = Color(0xFFF5F5F5);

  /// `--accent-foreground: oklch(0.205 0 0)` — `#171717`.
  static const Color lightAccentForeground = Color(0xFF171717);

  /// `--destructive: oklch(0.577 0.245 27.325)` — `#E7000B` (red-600).
  static const Color lightDestructive = Color(0xFFE7000B);

  /// The foreground shadcn/ui pairs with destructive surfaces.
  ///
  /// Note that current shadcn/ui hardcodes `text-white` on destructive Buttons
  /// and Badges rather than reading a `--destructive-foreground` variable — the
  /// variable was dropped from the registry. Cairn keeps the slot so themes can
  /// override it, defaulting to the white shadcn/ui hardcodes.
  static const Color lightDestructiveForeground = Color(0xFFFFFFFF);

  /// `--border: oklch(0.922 0 0)` — `#E5E5E5` (neutral-200).
  static const Color lightBorder = Color(0xFFE5E5E5);

  /// `--input: oklch(0.922 0 0)` — `#E5E5E5`.
  static const Color lightInput = Color(0xFFE5E5E5);

  /// `--ring: oklch(0.708 0 0)` — `#A1A1A1` (neutral-400).
  static const Color lightRing = Color(0xFFA1A1A1);

  // ---------------------------------------------------------------------------
  // Dark theme (`.dark`)
  // ---------------------------------------------------------------------------

  /// `--background: oklch(0.145 0 0)` — `#0A0A0A`.
  static const Color darkBackground = Color(0xFF0A0A0A);

  /// `--foreground: oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkForeground = Color(0xFFFAFAFA);

  /// `--card: oklch(0.205 0 0)` — `#171717`.
  ///
  /// Dark cards sit *lighter* than the page, inverting the light theme's
  /// relationship where the card is white on a near-white page.
  static const Color darkCard = Color(0xFF171717);

  /// `--card-foreground: oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkCardForeground = Color(0xFFFAFAFA);

  /// `--popover: oklch(0.205 0 0)` — `#171717`.
  static const Color darkPopover = Color(0xFF171717);

  /// `--popover-foreground: oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkPopoverForeground = Color(0xFFFAFAFA);

  /// `--primary: oklch(0.922 0 0)` — `#E5E5E5` (neutral-200).
  static const Color darkPrimary = Color(0xFFE5E5E5);

  /// `--primary-foreground: oklch(0.205 0 0)` — `#171717`.
  static const Color darkPrimaryForeground = Color(0xFF171717);

  /// `--secondary: oklch(0.269 0 0)` — `#262626` (neutral-800).
  static const Color darkSecondary = Color(0xFF262626);

  /// `--secondary-foreground: oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkSecondaryForeground = Color(0xFFFAFAFA);

  /// `--muted: oklch(0.269 0 0)` — `#262626`.
  static const Color darkMuted = Color(0xFF262626);

  /// `--muted-foreground: oklch(0.708 0 0)` — `#A1A1A1`.
  static const Color darkMutedForeground = Color(0xFFA1A1A1);

  /// `--accent: oklch(0.269 0 0)` — `#262626`.
  static const Color darkAccent = Color(0xFF262626);

  /// `--accent-foreground: oklch(0.985 0 0)` — `#FAFAFA`.
  static const Color darkAccentForeground = Color(0xFFFAFAFA);

  /// `--destructive: oklch(0.704 0.191 22.216)` — `#FF6467` (red-400).
  static const Color darkDestructive = Color(0xFFFF6467);

  /// White, matching shadcn/ui's hardcoded `text-white` on destructive fills.
  static const Color darkDestructiveForeground = Color(0xFFFFFFFF);

  /// `--border: oklch(1 0 0 / 10%)` — white at 10% alpha.
  ///
  /// The dark theme switches borders from an opaque grey to a translucent
  /// white so they lift correctly over both the page and raised card surfaces.
  static const Color darkBorder = Color(0x1AFFFFFF);

  /// `--input: oklch(1 0 0 / 15%)` — white at 15% alpha.
  static const Color darkInput = Color(0x26FFFFFF);

  /// `--ring: oklch(0.556 0 0)` — `#737373`.
  static const Color darkRing = Color(0xFF737373);

  // ---------------------------------------------------------------------------
  // Chart ramp (shared by both themes in the Neutral base)
  // ---------------------------------------------------------------------------

  /// `--chart-1: oklch(0.87 0 0)` — `#D4D4D4`.
  static const Color chart1 = Color(0xFFD4D4D4);

  /// `--chart-2: oklch(0.556 0 0)` — `#737373`.
  static const Color chart2 = Color(0xFF737373);

  /// `--chart-3: oklch(0.439 0 0)` — `#525252`.
  static const Color chart3 = Color(0xFF525252);

  /// `--chart-4: oklch(0.371 0 0)` — `#404040`.
  static const Color chart4 = Color(0xFF404040);

  /// `--chart-5: oklch(0.269 0 0)` — `#262626`.
  static const Color chart5 = Color(0xFF262626);

  // ---------------------------------------------------------------------------
  // Fixed values shadcn/ui hardcodes rather than tokenising
  // ---------------------------------------------------------------------------

  /// The scrim behind Dialog, Alert Dialog, Sheet and Drawer.
  ///
  /// shadcn/ui writes this as the literal utility `bg-black/50`, not a token,
  /// and it is the same in both themes.
  static const Color overlay = Color(0x80000000);

  /// Pure white, for `text-white` on destructive fills and the Slider thumb
  /// (`bg-white`, which stays white in both themes).
  static const Color white = Color(0xFFFFFFFF);
}
