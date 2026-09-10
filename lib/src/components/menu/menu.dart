import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The panel that holds menu items.
///
/// `min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1
/// text-popover-foreground shadow-md` — a 128 logical pixel minimum width and,
/// importantly, only **4px** of padding (`p-1`), unlike a Popover's 16px.
///
/// Shared by Dropdown Menu, Context Menu, Menubar and Select so their metrics
/// cannot drift apart.
class CairnMenuPanel extends StatelessWidget {
  /// Creates a menu panel.
  const CairnMenuPanel({
    super.key,
    required this.children,
    this.minWidth = 128.0,
    this.maxHeight,
    this.elevated = false,
  });

  /// The menu's items.
  final List<Widget> children;

  /// `min-w-[8rem]`.
  final double minWidth;

  /// An optional scroll cap for long menus.
  final double? maxHeight;

  /// Whether to use `shadow-lg` (submenus, context menus) over `shadow-md`.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        color: theme.popover,
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
        border: Border.all(color: theme.border),
        boxShadow: elevated ? CairnShadows.lg : CairnShadows.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
        child: DefaultTextStyle(
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(color: theme.popoverForeground),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget list = SingleChildScrollView(
                // Only the vertical half of `p-1` lives here. The horizontal
                // 4px is applied by each item instead, so that
                // CairnMenuSeparator — which CSS pulls back out with `-mx-1` —
                // can span the full panel width without fighting a parent
                // padding.
                padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Items stretch so their highlight fills the panel width
                  // rather than hugging each label.
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              );

              // Inside an overlay the popover layer supplies a bounded width.
              // Used standalone — in a Row, or straight in a page — the width
              // can be unbounded, and stretching to infinity throws. Sizing to
              // the widest item keeps the stretch bounded.
              return constraints.hasBoundedWidth
                  ? list
                  : IntrinsicWidth(child: list);
            },
          ),
        ),
      ),
    );
  }
}

/// The visual style of a [CairnMenuItem].
enum CairnMenuItemVariant {
  /// The default appearance.
  normal,

  /// `text-destructive`, with a `bg-destructive/10` highlight on focus
  /// (`/20` in dark mode).
  destructive,
}

/// A selectable row in a menu.
///
/// `relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5
/// text-sm select-none focus:bg-accent focus:text-accent-foreground` — 8px
/// horizontal and 6px vertical padding with a `rounded-sm` (6px) highlight.
///
/// Note `cursor-default`: Radix menu items deliberately do **not** show a
/// pointer cursor, which is a small detail that reads as wrong if missed.
///
/// Highlighting follows the pointer as well as the keyboard, matching how a
/// native menu behaves — Radix drives this with `data-highlighted` rather than
/// CSS `:hover`.
class CairnMenuItem extends StatelessWidget {
  /// Creates a menu item.
  const CairnMenuItem({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.shortcut,
    this.variant = CairnMenuItemVariant.normal,
    this.inset = false,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The item's label.
  final Widget child;

  /// Called when the item is chosen. Null disables it.
  final VoidCallback? onPressed;

  /// An icon before the label, forced to `size-4`.
  final Widget? leading;

  /// A widget after the label, before any [shortcut].
  final Widget? trailing;

  /// A keyboard hint pinned to the trailing edge
  /// (`ml-auto text-xs tracking-widest text-muted-foreground`).
  final String? shortcut;

  /// The visual style.
  final CairnMenuItemVariant variant;

  /// `data-[inset]:pl-8` — indents to line up with items that have icons.
  final bool inset;

  /// Whether the item can be chosen.
  final bool enabled;

  /// The accessible name.
  final String? semanticLabel;

  bool get _enabled => enabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool destructive = variant == CairnMenuItemVariant.destructive;

    return CairnInteractive(
      enabled: _enabled,
      onTap: onPressed,
      semanticLabel: semanticLabel,
      // Menus own focus themselves via roving highlight.
      canRequestFocus: false,
      mouseCursor: CairnCursors.menuItem,
      builder: (BuildContext context, CairnStates states) {
        final bool highlighted = states.hovered || states.focused;

        final Color foreground = destructive
            ? theme.destructive
            : (highlighted ? theme.accentForeground : theme.popoverForeground);

        final Color background = !highlighted
            ? const Color(0x00000000)
            : destructive
            ? theme.destructive.withValues(alpha: isDark ? 0.2 : 0.1)
            : theme.accent;

        return Opacity(
          opacity: states.disabled ? 0.5 : 1.0,
          child: Container(
            // The horizontal half of the panel's `p-1`.
            margin: const EdgeInsets.symmetric(horizontal: CairnSpacing.s1),
            padding: EdgeInsets.only(
              left: inset ? CairnSpacing.s8 : CairnSpacing.s2,
              right: CairnSpacing.s2,
              top: CairnSpacing.s1p5,
              bottom: CairnSpacing.s1p5,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(theme.radiusScale.sm),
            ),
            child: Row(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                if (leading != null)
                  IconTheme(
                    data: IconThemeData(
                      // Menu icons are muted unless the item is destructive.
                      color: destructive
                          ? theme.destructive
                          : theme.mutedForeground,
                      size: 16,
                    ),
                    child: SizedBox.square(dimension: 16, child: leading),
                  ),
                Expanded(
                  child: DefaultTextStyle(
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: child,
                  ),
                ),
                if (trailing != null)
                  IconTheme(
                    data: IconThemeData(color: theme.mutedForeground, size: 16),
                    child: trailing!,
                  ),
                if (shortcut != null)
                  Text(
                    shortcut!,
                    style: theme
                        .textStyle(CairnTypography.xs)
                        .copyWith(
                          color: theme.mutedForeground,
                          letterSpacing: CairnTypography.trackingWidest(12),
                        ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A menu row with a check indicator, matching `DropdownMenuCheckboxItem`.
///
/// `py-1.5 pr-2 pl-8` with the indicator absolutely positioned at `left-2` in
/// a `size-3.5` box — the 32px left padding is what reserves room for it.
class CairnMenuCheckboxItem extends StatelessWidget {
  /// Creates a checkable menu item.
  const CairnMenuCheckboxItem({
    super.key,
    required this.value,
    required this.child,
    this.onChanged,
    this.shortcut,
    this.enabled = true,
  });

  /// Whether the item is checked.
  final bool value;

  /// The item's label.
  final Widget child;

  /// Called with the next value.
  final ValueChanged<bool>? onChanged;

  /// A trailing keyboard hint.
  final String? shortcut;

  /// Whether the item can be chosen.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Stack(
      children: <Widget>[
        CairnMenuItem(
          inset: true,
          enabled: enabled,
          shortcut: shortcut,
          onPressed: onChanged == null ? null : () => onChanged!(!value),
          child: child,
        ),
        if (value)
          Positioned(
            // `left-2` plus the item's own 4px margin.
            left: CairnSpacing.s2 + CairnSpacing.s1,
            top: 0,
            bottom: 0,
            child: Center(
              child: CairnIcon(
                CairnIconData.check,
                size: 14,
                color: theme.popoverForeground,
              ),
            ),
          ),
      ],
    );
  }
}

/// A non-interactive heading in a menu.
///
/// `px-2 py-1.5 text-sm font-medium`.
class CairnMenuLabel extends StatelessWidget {
  /// Creates a menu label.
  const CairnMenuLabel(this.text, {super.key, this.inset = false});

  /// The heading text.
  final String text;

  /// Whether to indent to align with items that have icons.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: (inset ? CairnSpacing.s8 : CairnSpacing.s2) + CairnSpacing.s1,
        right: CairnSpacing.s2 + CairnSpacing.s1,
        top: CairnSpacing.s1p5,
        bottom: CairnSpacing.s1p5,
      ),
      child: Text(
        text,
        style: theme
            .textStyle(CairnTypography.sm)
            .copyWith(
              fontWeight: CairnTypography.medium,
              color: theme.popoverForeground,
            ),
      ),
    );
  }
}

/// A divider between menu groups.
///
/// `-mx-1 my-1 h-px bg-border` — the negative horizontal margin cancels the
/// panel's `p-1` so the rule spans the full panel width.
class CairnMenuSeparator extends StatelessWidget {
  /// Creates a menu separator.
  const CairnMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      // `my-1`. The `-mx-1` is unnecessary here because the panel applies no
      // horizontal padding — see CairnMenuPanel — so this already spans edge
      // to edge.
      margin: const EdgeInsets.symmetric(vertical: CairnSpacing.s1),
      width: double.infinity,
      height: 1,
      color: theme.border,
    );
  }
}
