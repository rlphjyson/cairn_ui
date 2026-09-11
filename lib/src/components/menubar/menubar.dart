import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/interaction.dart';
import '../../internal/popover_layer.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../menu/menu.dart';

/// One top-level menu in a [CairnMenubar].
@immutable
class CairnMenubarMenu {
  /// Creates a menubar menu.
  const CairnMenubarMenu({
    required this.label,
    required this.items,
    this.enabled = true,
  });

  /// The trigger's text, e.g. `File`.
  final String label;

  /// The menu's rows, typically [CairnMenuItem]s.
  final List<Widget> items;

  /// Whether the menu can be opened.
  final bool enabled;
}

/// A desktop-style menu bar matching shadcn/ui's `Menubar`.
///
/// The bar is `flex h-9 items-center gap-1 rounded-md border bg-background p-1
/// shadow-xs`; triggers are `rounded-sm px-2 py-1 text-sm font-medium` and
/// highlight with `data-[state=open]:bg-accent`. Panels are `min-w-[12rem]`
/// (192 logical pixels) — wider than a Dropdown Menu's `min-w-[8rem]`.
///
/// ## The hover-to-switch behaviour
///
/// Once any menu in the bar is open, hovering a sibling trigger switches to it
/// without a click — the behaviour every native menu bar has. Radix implements
/// this by sharing open state across the bar, and Cairn does the same via a
/// single active-index in the parent rather than per-menu controllers.
///
/// ```dart
/// CairnMenubar(
///   menus: [
///     CairnMenubarMenu(
///       label: 'File',
///       items: [CairnMenuItem(onPressed: () {}, child: const Text('New'))],
///     ),
///   ],
/// );
/// ```
class CairnMenubar extends StatefulWidget {
  /// Creates a menu bar.
  const CairnMenubar({
    super.key,
    required this.menus,
    this.minPanelWidth = 192.0,
  });

  /// The top-level menus.
  final List<CairnMenubarMenu> menus;

  /// `min-w-[12rem]`.
  final double minPanelWidth;

  @override
  State<CairnMenubar> createState() => _CairnMenubarState();
}

class _CairnMenubarState extends State<CairnMenubar> {
  /// Which menu is open, or null.
  int? _open;

  /// One controller per menu, kept in step with [_open].
  late final List<CairnOverlayController> _controllers =
      List<CairnOverlayController>.generate(
        widget.menus.length,
        (_) => CairnOverlayController(),
      );

  @override
  void dispose() {
    for (final CairnOverlayController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _setOpen(int? index) {
    if (_open == index) return;
    setState(() {
      if (_open != null) _controllers[_open!].close();
      _open = index;
      if (index != null) _controllers[index].open();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Container(
      height: 36.0,
      padding: const EdgeInsets.all(CairnSpacing.s1),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
        border: Border.all(color: theme.border),
        boxShadow: CairnShadows.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s1,
        children: <Widget>[
          for (int i = 0; i < widget.menus.length; i++)
            CairnAnchoredOverlay(
              controller: _controllers[i],
              side: CairnSide.bottom,
              align: CairnAlign.start,
              offset: 6.0,
              onClosed: () {
                if (_open == i) setState(() => _open = null);
              },
              anchor: MouseRegion(
                // Hovering a sibling while any menu is open switches to it.
                onEnter: (_) {
                  if (_open != null && widget.menus[i].enabled) _setOpen(i);
                },
                child: CairnInteractive(
                  enabled: widget.menus[i].enabled,
                  onTap: () => _setOpen(_open == i ? null : i),
                  builder: (BuildContext context, CairnStates states) {
                    final bool active = _open == i;
                    return Opacity(
                      opacity: states.disabled ? 0.5 : 1.0,
                      child: AnimatedContainer(
                        duration: CairnMotion.d100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: CairnSpacing.s2,
                          vertical: CairnSpacing.s1,
                        ),
                        decoration: BoxDecoration(
                          color: active || states.hovered
                              ? theme.accent
                              : const Color(0x00000000),
                          borderRadius: BorderRadius.circular(
                            theme.radiusScale.sm,
                          ),
                        ),
                        child: Text(
                          widget.menus[i].label,
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(
                                fontWeight: CairnTypography.medium,
                                color: active || states.hovered
                                    ? theme.accentForeground
                                    : theme.foreground,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              overlayBuilder: (BuildContext context) => CairnMenuPanel(
                minWidth: widget.minPanelWidth,
                children: <Widget>[
                  for (final Widget item in widget.menus[i].items)
                    Listener(
                      onPointerUp: (_) => WidgetsBinding.instance
                          .addPostFrameCallback((_) => _setOpen(null)),
                      child: item,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A horizontal navigation bar matching shadcn/ui's `NavigationMenu`.
///
/// Triggers are `h-9 w-max rounded-md bg-background px-4 py-2 text-sm
/// font-medium` with `hover:bg-accent`, and the open state is
/// `data-[state=open]:bg-accent/50`. Content panels are `rounded-md border
/// bg-popover p-2 shadow`.
///
/// Distinct from [CairnMenubar]: a navigation menu's panels hold arbitrary
/// content (link grids, promos), not just menu rows, and it is a site-navigation
/// pattern rather than an application menu bar.
class CairnNavigationMenu extends StatefulWidget {
  /// Creates a navigation menu.
  const CairnNavigationMenu({super.key, required this.items});

  /// The top-level entries.
  final List<CairnNavigationItem> items;

  @override
  State<CairnNavigationMenu> createState() => _CairnNavigationMenuState();
}

/// One entry in a [CairnNavigationMenu].
@immutable
class CairnNavigationItem {
  /// Creates a plain link that fires [onPressed].
  const CairnNavigationItem({
    required this.label,
    this.onPressed,
    this.content,
  });

  /// The trigger's text.
  final String label;

  /// Called when a link-style entry is activated.
  final VoidCallback? onPressed;

  /// A panel shown on activation. Non-null makes this a disclosure trigger
  /// rather than a link.
  final Widget? content;
}

class _CairnNavigationMenuState extends State<CairnNavigationMenu> {
  int? _open;

  late final List<CairnOverlayController> _controllers =
      List<CairnOverlayController>.generate(
        widget.items.length,
        (_) => CairnOverlayController(),
      );

  @override
  void dispose() {
    for (final CairnOverlayController c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _setOpen(int? index) {
    if (_open == index) return;
    setState(() {
      if (_open != null) _controllers[_open!].close();
      _open = index;
      if (index != null) _controllers[index].open();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    Widget trigger(int i, CairnStates states) {
      final bool active = _open == i;
      return AnimatedContainer(
        duration: CairnMotion.d150,
        curve: CairnMotion.standard,
        height: 36.0,
        padding: const EdgeInsets.symmetric(
          horizontal: CairnSpacing.s4,
          vertical: CairnSpacing.s2,
        ),
        // No `alignment`: it would stretch this trigger to the full row width.
        // `w-max` means width-of-content, which is what Center(widthFactor: 1)
        // preserves while still centring vertically.
        decoration: BoxDecoration(
          color: states.hovered
              ? theme.accent
              : active
              // `data-[state=open]:bg-accent/50`.
              ? theme.accent.withValues(alpha: 0.5)
              : theme.background,
          borderRadius: BorderRadius.circular(theme.radiusScale.md),
          boxShadow: states.focused ? theme.focusRing : null,
        ),
        child: Center(
          widthFactor: 1.0,
          child: Text(
            widget.items[i].label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  fontWeight: CairnTypography.medium,
                  color: states.hovered || active
                      ? theme.accentForeground
                      : theme.foreground,
                ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        for (int i = 0; i < widget.items.length; i++)
          if (widget.items[i].content == null)
            CairnInteractive(
              onTap: widget.items[i].onPressed,
              isButton: false,
              semanticLabel: widget.items[i].label,
              builder: (BuildContext context, CairnStates states) =>
                  trigger(i, states),
            )
          else
            CairnAnchoredOverlay(
              controller: _controllers[i],
              side: CairnSide.bottom,
              align: CairnAlign.start,
              offset: 6.0,
              onClosed: () {
                if (_open == i) setState(() => _open = null);
              },
              anchor: CairnInteractive(
                onTap: () => _setOpen(_open == i ? null : i),
                isButton: false,
                semanticLabel: widget.items[i].label,
                builder: (BuildContext context, CairnStates states) =>
                    trigger(i, states),
              ),
              overlayBuilder: (BuildContext context) => Container(
                padding: const EdgeInsets.all(CairnSpacing.s2),
                decoration: BoxDecoration(
                  color: theme.popover,
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  border: Border.all(color: theme.border),
                  boxShadow: CairnShadows.md,
                ),
                child: DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(color: theme.popoverForeground),
                  child: widget.items[i].content!,
                ),
              ),
            ),
      ],
    );
  }
}
