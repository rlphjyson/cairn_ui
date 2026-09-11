import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The visual style of a [CairnButton].
///
/// Mirrors shadcn/ui's `buttonVariants` `variant` axis exactly.
enum CairnButtonVariant {
  /// `bg-primary text-primary-foreground hover:bg-primary/90`.
  primary,

  /// `bg-destructive text-white hover:bg-destructive/90`.
  ///
  /// In dark mode shadcn/ui softens the fill to `dark:bg-destructive/60`.
  destructive,

  /// `border bg-background shadow-xs hover:bg-accent`.
  ///
  /// The dark theme adds a translucent fill (`dark:bg-input/30`) that has no
  /// light-mode counterpart.
  outline,

  /// `bg-secondary text-secondary-foreground hover:bg-secondary/80`.
  secondary,

  /// `hover:bg-accent hover:text-accent-foreground`, no fill at rest.
  ghost,

  /// `text-primary underline-offset-4 hover:underline`.
  link,
}

/// The size of a [CairnButton].
///
/// Mirrors shadcn/ui's `size` axis, including the square icon-only sizes.
enum CairnButtonSize {
  /// `h-6 gap-1 px-2 text-xs` with 12px icons.
  xs,

  /// `h-8 gap-1.5 px-3`.
  sm,

  /// `h-9 px-4 py-2` — the default.
  md,

  /// `h-10 px-6`.
  lg,

  /// `size-6` — square, icon only.
  iconXs,

  /// `size-8` — square, icon only.
  iconSm,

  /// `size-9` — square, icon only.
  iconMd,

  /// `size-10` — square, icon only.
  iconLg;

  /// Whether this is one of the square icon-only sizes.
  bool get isIcon =>
      this == iconXs || this == iconSm || this == iconMd || this == iconLg;
}

/// A button matching shadcn/ui's `Button`.
///
/// Six variants ([CairnButtonVariant]) and eight sizes ([CairnButtonSize]),
/// with dimensions taken from shadcn/ui's Tailwind classes: the default size is
/// `h-9 px-4` — 36 logical pixels tall with 16px of horizontal padding — and
/// text is `text-sm font-medium` (14px, weight 500).
///
/// ```dart
/// CairnButton(
///   onPressed: () => print('tapped'),
///   child: const Text('Continue'),
/// );
///
/// CairnButton(
///   variant: CairnButtonVariant.outline,
///   size: CairnButtonSize.sm,
///   leading: const Icon(Icons.add),
///   onPressed: () {},
///   child: const Text('Add item'),
/// );
/// ```
///
/// ## Accessibility
///
/// The button is a focusable [Semantics] button, activates on both Space and
/// Enter (matching Radix), and shows its focus ring only on keyboard focus —
/// see [CairnInteractive] for how `:focus-visible` is reproduced. Passing null
/// to [onPressed] disables it, which removes it from focus traversal and drops
/// its opacity to 50% (`disabled:opacity-50`).
class CairnButton extends StatelessWidget {
  /// Creates a button.
  const CairnButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.variant = CairnButtonVariant.primary,
    this.size = CairnButtonSize.md,
    this.leading,
    this.trailing,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.expand = false,
  });

  /// Creates an icon-only button.
  ///
  /// Uses a square size and applies [semanticLabel] as the accessible name,
  /// which is required because there is no visible text — this is the direct
  /// equivalent of shadcn/ui pairing `size="icon"` with an `sr-only` label.
  const CairnButton.icon({
    super.key,
    required Widget icon,
    required String this.semanticLabel,
    this.onPressed,
    this.onLongPress,
    this.variant = CairnButtonVariant.primary,
    this.size = CairnButtonSize.iconMd,
    this.focusNode,
    this.autofocus = false,
  }) : child = icon,
       leading = null,
       trailing = null,
       expand = false;

  /// The button's label, or its icon when built with [CairnButton.icon].
  final Widget child;

  /// Called when the button is activated. Null disables the button.
  final VoidCallback? onPressed;

  /// Called on long press.
  final VoidCallback? onLongPress;

  /// The visual style.
  final CairnButtonVariant variant;

  /// The size.
  final CairnButtonSize size;

  /// An icon placed before [child], separated by the size's `gap`.
  final Widget? leading;

  /// An icon placed after [child], separated by the size's `gap`.
  final Widget? trailing;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// The accessible name. Required for [CairnButton.icon].
  final String? semanticLabel;

  /// Whether to stretch to the available width.
  ///
  /// shadcn/ui achieves this with `w-full` on the element rather than a
  /// variant, so it is a flag here rather than a size.
  final bool expand;

  /// Whether the button is interactive.
  bool get _enabled => onPressed != null || onLongPress != null;

  /// `h-*` — the fixed height for this size.
  double get _height => switch (size) {
    CairnButtonSize.xs || CairnButtonSize.iconXs => 24.0,
    CairnButtonSize.sm || CairnButtonSize.iconSm => 32.0,
    CairnButtonSize.md || CairnButtonSize.iconMd => 36.0,
    CairnButtonSize.lg || CairnButtonSize.iconLg => 40.0,
  };

  /// `px-*` — horizontal padding. Icon sizes are square, so zero.
  double get _paddingX => switch (size) {
    CairnButtonSize.xs => CairnSpacing.s2,
    CairnButtonSize.sm => CairnSpacing.s3,
    CairnButtonSize.md => CairnSpacing.s4,
    CairnButtonSize.lg => CairnSpacing.s6,
    _ => 0.0,
  };

  /// `gap-*` — spacing between icon and label.
  double get _gap => switch (size) {
    CairnButtonSize.xs => CairnSpacing.s1,
    CairnButtonSize.sm => CairnSpacing.s1p5,
    _ => CairnSpacing.s2,
  };

  /// `[&_svg]:size-*` — the icon size shadcn/ui forces on child SVGs.
  double get _iconSize => switch (size) {
    CairnButtonSize.xs || CairnButtonSize.iconXs => 12.0,
    _ => 16.0,
  };

  /// `text-*` — the label style.
  TextStyle get _textStyle =>
      size == CairnButtonSize.xs ? CairnTypography.xs : CairnTypography.sm;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return CairnInteractive(
      enabled: _enabled,
      onTap: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, CairnStates states) {
        final _ButtonPaint paint = _resolvePaint(theme, states, isDark);

        Widget content = _buildContent(theme, paint);

        // `disabled:opacity-50`.
        if (states.disabled) {
          content = Opacity(opacity: 0.5, child: content);
        }

        return content;
      },
    );
  }

  Widget _buildContent(CairnTheme theme, _ButtonPaint paint) {
    final TextStyle labelStyle = theme
        .textStyle(_textStyle)
        .copyWith(
          fontWeight: CairnTypography.medium,
          color: paint.foreground,
          decoration: paint.underline ? TextDecoration.underline : null,
          // `underline-offset-4`.
          decorationColor: paint.foreground,
          decorationThickness: paint.underline ? 1.0 : null,
        );

    final List<Widget> children = <Widget>[
      if (leading != null) _sizedIcon(leading!, paint.foreground),
      Flexible(
        child: DefaultTextStyle(
          style: labelStyle,
          maxLines: 1,
          // `whitespace-nowrap`.
          softWrap: false,
          overflow: TextOverflow.clip,
          child: IconTheme(
            data: IconThemeData(color: paint.foreground, size: _iconSize),
            child: child,
          ),
        ),
      ),
      if (trailing != null) _sizedIcon(trailing!, paint.foreground),
    ];

    final Widget row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: _gap,
      children: children,
    );

    final BorderRadius radius = BorderRadius.circular(theme.radiusScale.md);

    // The ghost, link and (light-mode) outline variants have no opaque fill,
    // so the focus ring and shadow must be clipped to the outside of the box —
    // otherwise a 3px ring paints across the whole button. See CairnShadowed.
    return CairnShadowed(
      borderRadius: radius,
      shadows: paint.shadow,
      child: AnimatedContainer(
        duration: CairnMotion.d150,
        curve: CairnMotion.standard,
        height: _height,
        width: size.isIcon ? _height : null,
        padding: size.isIcon
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: _paddingX),
        // Deliberately no `alignment`. A Container with a non-null alignment
        // expands to fill its bounded constraints, which would make every button
        // stretch to the width of its parent — the opposite of shadcn/ui's
        // `inline-flex` (width-of-content) behaviour. Centring is handled by the
        // Row's own mainAxisAlignment instead.
        decoration: BoxDecoration(
          color: paint.background,
          borderRadius: radius,
          border: paint.border == null
              ? null
              : Border.all(color: paint.border!, width: 1.0),
        ),
        child: row,
      ),
    );
  }

  Widget _sizedIcon(Widget icon, Color color) => IconTheme(
    data: IconThemeData(color: color, size: _iconSize),
    child: SizedBox(width: _iconSize, height: _iconSize, child: icon),
  );

  /// Resolves fill, foreground, border and shadow for the current state.
  ///
  /// Hover colours use CSS alpha semantics — `hover:bg-primary/90` is the
  /// primary colour at 90% alpha composited over whatever is behind it, which
  /// is exactly what [Color.withValues] produces when painted.
  _ButtonPaint _resolvePaint(
    CairnTheme theme,
    CairnStates states,
    bool isDark,
  ) {
    final bool hovered = states.hovered;
    final List<BoxShadow> focus = states.focused
        ? (variant == CairnButtonVariant.destructive
              ? theme.invalidRing
              : theme.focusRing)
        : const <BoxShadow>[];
    final Color? focusBorder = states.focused ? theme.ring : null;

    switch (variant) {
      case CairnButtonVariant.primary:
        return _ButtonPaint(
          background: hovered
              ? theme.primary.withValues(alpha: 0.9)
              : theme.primary,
          foreground: theme.primaryForeground,
          border: focusBorder,
          shadow: focus,
        );

      case CairnButtonVariant.destructive:
        // `dark:bg-destructive/60` softens the fill in dark mode.
        final Color base = isDark
            ? theme.destructive.withValues(alpha: 0.6)
            : theme.destructive;
        return _ButtonPaint(
          background: hovered ? base.withValues(alpha: 0.9) : base,
          foreground: theme.destructiveForeground,
          border: focusBorder,
          shadow: focus,
        );

      case CairnButtonVariant.outline:
        // Light: transparent over background. Dark: `bg-input/30`, hovering to
        // `bg-input/50`.
        final Color fill = isDark
            ? theme.input.withOpacityModifier(hovered ? 0.5 : 0.3)
            : (hovered ? theme.accent : theme.background);
        return _ButtonPaint(
          background: fill,
          foreground: hovered && !isDark
              ? theme.accentForeground
              : theme.foreground,
          border: focusBorder ?? (isDark ? theme.input : theme.border),
          shadow: <BoxShadow>[...CairnShadows.xs, ...focus],
        );

      case CairnButtonVariant.secondary:
        return _ButtonPaint(
          background: hovered
              ? theme.secondary.withValues(alpha: 0.8)
              : theme.secondary,
          foreground: theme.secondaryForeground,
          border: focusBorder,
          shadow: focus,
        );

      case CairnButtonVariant.ghost:
        // `dark:hover:bg-accent/50`.
        final Color fill = hovered
            ? (isDark ? theme.accent.withValues(alpha: 0.5) : theme.accent)
            : const Color(0x00000000);
        return _ButtonPaint(
          background: fill,
          foreground: hovered ? theme.accentForeground : theme.foreground,
          border: focusBorder,
          shadow: focus,
        );

      case CairnButtonVariant.link:
        return _ButtonPaint(
          background: const Color(0x00000000),
          foreground: theme.primary,
          border: focusBorder,
          shadow: focus,
          underline: hovered,
        );
    }
  }
}

/// Resolved paint properties for one button state.
@immutable
class _ButtonPaint {
  const _ButtonPaint({
    required this.background,
    required this.foreground,
    this.border,
    this.shadow = const <BoxShadow>[],
    this.underline = false,
  });

  final Color background;
  final Color foreground;
  final Color? border;
  final List<BoxShadow> shadow;
  final bool underline;
}
