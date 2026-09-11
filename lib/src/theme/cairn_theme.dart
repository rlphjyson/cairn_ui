import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';

/// Scales a colour's alpha, rather than replacing it.
///
/// Cairn expresses partial-strength tokens as a *fraction of what the token
/// already is* — "the primary colour at 90%" — which is the same semantics as
/// the `/N` opacity modifier in CSS utility frameworks, where `primary/90`
/// compiles to `color-mix(in oklab, var(--primary) 90%, transparent)`.
///
/// For a fully opaque token, scaling and replacing are indistinguishable, so
/// `withValues(alpha: 0.9)` looks correct — until the token already carries
/// alpha. That is exactly the case in Cairn's dark theme, where
/// [CairnTheme.input] is `oklch(1 0 0 / 15%)`: white at 15%. Taking 30% of it
/// should paint white at **4.5%**; `withValues(alpha: 0.3)` would paint it at
/// 30% — more than six times too strong, and plainly visible as a washed-out
/// grey fill across every dark-mode form control.
extension CairnOpacityModifier on Color {
  /// Returns this colour with its alpha scaled by [factor] (0..1).
  Color withOpacityModifier(double factor) =>
      withValues(alpha: a * factor.clamp(0.0, 1.0));
}

/// The design tokens every Cairn component reads from.
///
/// `CairnTheme` is a [ThemeExtension], which is the deliberate integration
/// choice for this library. The alternative — an inherited widget of Cairn's
/// own — would have forced host apps to nest two theme systems and would have
/// broken any Material widget they already use. Riding on
/// [ThemeData.extensions] instead means:
///
/// * Cairn composes inside an ordinary [MaterialApp]; nothing has to be
///   abandoned or wrapped.
/// * Flutter animates theme changes for free, because [ThemeExtension.lerp] is
///   driven by [AnimatedTheme] during a light/dark transition.
/// * `Theme.of(context)` stays the single lookup path developers already know.
///
/// ## Usage
///
/// The direct form:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(extensions: const <ThemeExtension<dynamic>>[CairnTheme.light]),
///   darkTheme: ThemeData(extensions: const <ThemeExtension<dynamic>>[CairnTheme.dark]),
/// );
/// ```
///
/// Or let [CairnTheme.materialTheme] build a [ThemeData] whose Material
/// defaults (scaffold background, text selection, splash behaviour) already
/// agree with the Cairn tokens:
///
/// ```dart
/// MaterialApp(
///   theme: CairnTheme.materialTheme(CairnTheme.light),
///   darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
/// );
/// ```
///
/// Components resolve tokens with [CairnTheme.of], which falls back to
/// [CairnTheme.light] rather than throwing, so a widget dropped into an app
/// with no extension registered still renders correctly.
@immutable
class CairnTheme extends ThemeExtension<CairnTheme> {
  /// Creates a theme from an explicit set of tokens.
  ///
  /// Prefer [CairnTheme.light] / [CairnTheme.dark] and [copyWith] for
  /// customisation; this constructor exists for themes built from scratch.
  const CairnTheme({
    required this.brightness,
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    this.radius = CairnRadius.base,
    this.fontFamily,
    this.fontFamilyFallback,
  });

  /// Whether this is a light or dark theme.
  ///
  /// A handful of components genuinely branch on brightness rather than on a
  /// token, because the dark theme asks for a treatment with no light-mode
  /// counterpart. The outline Button is the clearest case: on a dark page a
  /// hairline border alone barely separates the control from its background,
  /// so it takes a faint fill that would be redundant in light mode.
  final Brightness brightness;

  /// The page surface.
  final Color background;

  /// Default body text on [background].
  final Color foreground;

  /// Raised content surfaces.
  final Color card;

  /// Text on [card].
  final Color cardForeground;

  /// Floating surfaces: Popover, Dropdown Menu, Select, Tooltip bodies,
  /// Command palette.
  final Color popover;

  /// Text on [popover].
  final Color popoverForeground;

  /// High-emphasis fills — the default Button, the checked Checkbox and
  /// Switch, the Progress indicator.
  final Color primary;

  /// Text and icons on [primary].
  final Color primaryForeground;

  /// Low-emphasis fills — the secondary Button and Badge.
  final Color secondary;

  /// Text on [secondary].
  final Color secondaryForeground;

  /// De-emphasised backgrounds — Slider track, Table footer.
  final Color muted;

  /// Secondary text — descriptions, placeholders.
  final Color mutedForeground;

  /// Hover and keyboard-focus highlight for interactive rows.
  final Color accent;

  /// Text on [accent].
  final Color accentForeground;

  /// Danger fills and destructive text.
  final Color destructive;

  /// The foreground paired with [destructive] fills.
  ///
  /// A slot of its own rather than a hardcoded white, so a theme that softens
  /// the destructive fill can move the text sitting on it as well.
  final Color destructiveForeground;

  /// Hairlines and component outlines.
  final Color border;

  /// The border color of form controls specifically.
  ///
  /// Tokenised separately from [border] so that inputs can read at a different
  /// weight from ordinary hairlines — which the dark theme uses, lifting form
  /// controls to 15% white where a plain border sits at 10%.
  final Color input;

  /// The focus ring color.
  ///
  /// Components draw it at 50% alpha and 3px thickness; see [focusRing].
  final Color ring;

  /// The base corner radius, in logical pixels. Defaults to
  /// [CairnRadius.base] (10.0).
  ///
  /// Change this to rescale every component's corners proportionally; see
  /// [radiusScale].
  final double radius;

  /// The font family applied to all Cairn text.
  ///
  /// Null means "inherit whatever the host app set". Cairn names no typeface
  /// of its own, so it adopts the host's rather than imposing one.
  final String? fontFamily;

  /// Fallback families for [fontFamily].
  final List<String>? fontFamilyFallback;

  /// The derived radius scale for this theme's [radius].
  CairnRadiusScale get radiusScale => CairnRadiusScale(radius);

  /// [ring] at the 50% alpha the focus ring is drawn with.
  Color get ringMuted => ring.withValues(alpha: 0.5);

  /// The scrim behind modal surfaces — black at 50%.
  Color get overlay => CairnColors.overlay;

  /// The focus ring as a box-shadow list.
  ///
  /// Tailwind implements `ring-[3px]` as `box-shadow: 0 0 0 3px <color>` — a
  /// hard, unblurred outset. The Flutter equivalent is a [BoxShadow] with zero
  /// offset, zero blur and a 3px spread, which is what this returns.
  List<BoxShadow> get focusRing => <BoxShadow>[
    BoxShadow(color: ringMuted, spreadRadius: 3.0),
  ];

  /// The focus ring tinted for invalid controls.
  ///
  /// [destructive] at 20% alpha, raised to 40% in the dark theme where the
  /// lower-contrast surface needs the extra weight to register.
  List<BoxShadow> get invalidRing => <BoxShadow>[
    BoxShadow(
      color: destructive.withValues(
        alpha: brightness == Brightness.dark ? 0.4 : 0.2,
      ),
      spreadRadius: 3.0,
    ),
  ];

  /// Applies [fontFamily] and [fontFamilyFallback] to a token text style.
  TextStyle textStyle(TextStyle base) => base.copyWith(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  /// Cairn's default light theme.
  static const CairnTheme light = CairnTheme(
    brightness: Brightness.light,
    background: CairnColors.lightBackground,
    foreground: CairnColors.lightForeground,
    card: CairnColors.lightCard,
    cardForeground: CairnColors.lightCardForeground,
    popover: CairnColors.lightPopover,
    popoverForeground: CairnColors.lightPopoverForeground,
    primary: CairnColors.lightPrimary,
    primaryForeground: CairnColors.lightPrimaryForeground,
    secondary: CairnColors.lightSecondary,
    secondaryForeground: CairnColors.lightSecondaryForeground,
    muted: CairnColors.lightMuted,
    mutedForeground: CairnColors.lightMutedForeground,
    accent: CairnColors.lightAccent,
    accentForeground: CairnColors.lightAccentForeground,
    destructive: CairnColors.lightDestructive,
    destructiveForeground: CairnColors.lightDestructiveForeground,
    border: CairnColors.lightBorder,
    input: CairnColors.lightInput,
    ring: CairnColors.lightRing,
  );

  /// Cairn's default dark theme.
  static const CairnTheme dark = CairnTheme(
    brightness: Brightness.dark,
    background: CairnColors.darkBackground,
    foreground: CairnColors.darkForeground,
    card: CairnColors.darkCard,
    cardForeground: CairnColors.darkCardForeground,
    popover: CairnColors.darkPopover,
    popoverForeground: CairnColors.darkPopoverForeground,
    primary: CairnColors.darkPrimary,
    primaryForeground: CairnColors.darkPrimaryForeground,
    secondary: CairnColors.darkSecondary,
    secondaryForeground: CairnColors.darkSecondaryForeground,
    muted: CairnColors.darkMuted,
    mutedForeground: CairnColors.darkMutedForeground,
    accent: CairnColors.darkAccent,
    accentForeground: CairnColors.darkAccentForeground,
    destructive: CairnColors.darkDestructive,
    destructiveForeground: CairnColors.darkDestructiveForeground,
    border: CairnColors.darkBorder,
    input: CairnColors.darkInput,
    ring: CairnColors.darkRing,
  );

  /// Resolves the ambient theme, falling back to [CairnTheme.light].
  ///
  /// The fallback is intentional: a Cairn widget used in an app that never
  /// registered the extension still renders with correct tokens instead of
  /// throwing. Register the extension to control which theme is used.
  static CairnTheme of(BuildContext context) =>
      Theme.of(context).extension<CairnTheme>() ?? CairnTheme.light;

  /// Builds a [ThemeData] whose Material defaults agree with [cairn].
  ///
  /// This does not replace Material — it aligns it, so a host app mixing Cairn
  /// widgets with Material ones does not get two clashing palettes. It sets the
  /// scaffold and canvas colors, a matching [ColorScheme], the text selection
  /// colors, and disables Material's ink splash (Cairn has no ripple; its
  /// interactions are colour and shadow transitions only).
  static ThemeData materialTheme(CairnTheme cairn) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: cairn.primary,
          brightness: cairn.brightness,
        ).copyWith(
          surface: cairn.background,
          onSurface: cairn.foreground,
          primary: cairn.primary,
          onPrimary: cairn.primaryForeground,
          secondary: cairn.secondary,
          onSecondary: cairn.secondaryForeground,
          error: cairn.destructive,
          onError: cairn.destructiveForeground,
          outline: cairn.border,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: cairn.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: cairn.background,
      canvasColor: cairn.background,
      dividerColor: cairn.border,
      fontFamily: cairn.fontFamily,
      fontFamilyFallback: cairn.fontFamilyFallback,
      splashFactory: NoSplash.splashFactory,
      highlightColor: const Color(0x00000000),
      // Material 3's TextField is a *filled* field by default, painting
      // `surfaceContainerHighest` behind the text. Cairn inputs are
      // transparent with the border doing the work, so the fill is switched
      // off here rather than fought per-component.
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Color(0x00000000),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cairn.foreground,
        selectionColor: cairn.primary.withValues(alpha: 0.25),
        selectionHandleColor: cairn.primary,
      ),
      extensions: <ThemeExtension<dynamic>>[cairn],
    );
  }

  @override
  CairnTheme copyWith({
    Brightness? brightness,
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? border,
    Color? input,
    Color? ring,
    double? radius,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    return CairnTheme(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      radius: radius ?? this.radius,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
    );
  }

  @override
  CairnTheme lerp(covariant ThemeExtension<CairnTheme>? other, double t) {
    if (other is! CairnTheme) return this;
    return CairnTheme(
      // Brightness is discrete; snap at the midpoint rather than interpolating.
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      popover: Color.lerp(popover, other.popover, t)!,
      popoverForeground: Color.lerp(
        popoverForeground,
        other.popoverForeground,
        t,
      )!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(
        primaryForeground,
        other.primaryForeground,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground: Color.lerp(
        secondaryForeground,
        other.secondaryForeground,
        t,
      )!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(
        accentForeground,
        other.accentForeground,
        t,
      )!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveForeground: Color.lerp(
        destructiveForeground,
        other.destructiveForeground,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      radius: lerpDouble(radius, other.radius, t),
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontFamilyFallback: t < 0.5
          ? fontFamilyFallback
          : other.fontFamilyFallback,
    );
  }

  /// Linearly interpolates two non-null doubles.
  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CairnTheme &&
        other.brightness == brightness &&
        other.background == background &&
        other.foreground == foreground &&
        other.card == card &&
        other.cardForeground == cardForeground &&
        other.popover == popover &&
        other.popoverForeground == popoverForeground &&
        other.primary == primary &&
        other.primaryForeground == primaryForeground &&
        other.secondary == secondary &&
        other.secondaryForeground == secondaryForeground &&
        other.muted == muted &&
        other.mutedForeground == mutedForeground &&
        other.accent == accent &&
        other.accentForeground == accentForeground &&
        other.destructive == destructive &&
        other.destructiveForeground == destructiveForeground &&
        other.border == border &&
        other.input == input &&
        other.ring == ring &&
        other.radius == radius &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode => Object.hash(
    brightness,
    background,
    foreground,
    card,
    cardForeground,
    popover,
    popoverForeground,
    primary,
    primaryForeground,
    secondary,
    secondaryForeground,
    muted,
    mutedForeground,
    accent,
    accentForeground,
    destructive,
    Object.hash(destructiveForeground, border, input, ring, radius, fontFamily),
  );

  /// The default text style for this theme: `text-sm` in [foreground].
  TextStyle get defaultTextStyle =>
      textStyle(CairnTypography.sm).copyWith(color: foreground);
}
