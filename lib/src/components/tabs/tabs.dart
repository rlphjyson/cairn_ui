import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The visual style of a [CairnTabs] bar.
enum CairnTabsVariant {
  /// `bg-muted` — a filled pill track with a raised active tab.
  filled,

  /// `gap-1 bg-transparent` — no track; the active tab gets a 2px underline.
  line,
}

/// One tab in a [CairnTabs].
@immutable
class CairnTab<T> {
  /// Creates a tab.
  const CairnTab({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// The value this tab selects.
  final T value;

  /// The tab's label.
  final Widget label;

  /// An optional leading icon, forced to `size-4`.
  final Widget? icon;

  /// Whether the tab can be selected.
  final bool enabled;
}

/// A tab bar matching shadcn/ui's `Tabs`.
///
/// The filled variant's track is `h-9 rounded-lg bg-muted p-[3px]` — note the
/// **3px** padding, an arbitrary value rather than a spacing step, which is
/// what makes the active tab sit flush inside the track. Each trigger is
/// `h-[calc(100%-1px)] rounded-md px-2 py-1 text-sm font-medium`, and the
/// inactive label colour is `text-foreground/60` in light mode but
/// `text-muted-foreground` in dark.
///
/// The line variant drops the track and instead draws a 2px underline
/// (`after:h-0.5`) 5 pixels below the trigger (`after:bottom-[-5px]`).
///
/// ## Accessibility
///
/// Arrow keys move between tabs and the bar holds a single tab stop, matching
/// the WAI-ARIA tabs pattern that Radix implements.
///
/// ```dart
/// CairnTabs<String>(
///   value: tab,
///   onChanged: (v) => setState(() => tab = v),
///   tabs: const [
///     CairnTab(value: 'account', label: Text('Account')),
///     CairnTab(value: 'password', label: Text('Password')),
///   ],
/// );
/// ```
class CairnTabs<T> extends StatelessWidget {
  /// Creates a tab bar.
  const CairnTabs({
    super.key,
    required this.value,
    required this.tabs,
    this.onChanged,
    this.variant = CairnTabsVariant.filled,
    this.expand = false,
  });

  /// The selected tab's value.
  final T value;

  /// The tabs.
  final List<CairnTab<T>> tabs;

  /// Called when a tab is chosen.
  final ValueChanged<T>? onChanged;

  /// The visual style.
  final CairnTabsVariant variant;

  /// Whether tabs share the available width equally.
  final bool expand;

  /// `p-[3px]` — an arbitrary value, not a spacing step.
  static const double _trackPadding = 3.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool filled = variant == CairnTabsVariant.filled;

    final List<Widget> triggers = <Widget>[
      for (final CairnTab<T> tab in tabs)
        _TabTrigger<T>(
          tab: tab,
          selected: tab.value == value,
          variant: variant,
          expand: expand,
          onTap: onChanged == null || !tab.enabled
              ? null
              : () => onChanged!(tab.value),
        ),
    ];

    final Widget bar = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      spacing: filled ? 0.0 : CairnSpacing.s1,
      children: expand
          ? <Widget>[for (final Widget t in triggers) Expanded(child: t)]
          : triggers,
    );

    return Semantics(
      container: true,
      child: FocusTraversalGroup(
        child: filled
            ? Container(
                height: 36.0,
                padding: const EdgeInsets.all(_trackPadding),
                decoration: BoxDecoration(
                  color: theme.muted,
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                ),
                child: bar,
              )
            : bar,
      ),
    );
  }
}

/// One trigger inside a [CairnTabs].
class _TabTrigger<T> extends StatelessWidget {
  const _TabTrigger({
    required this.tab,
    required this.selected,
    required this.variant,
    required this.expand,
    required this.onTap,
  });

  final CairnTab<T> tab;
  final bool selected;
  final CairnTabsVariant variant;
  final bool expand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool filled = variant == CairnTabsVariant.filled;

    return CairnInteractive(
      enabled: onTap != null,
      onTap: onTap,
      isButton: false,
      builder: (BuildContext context, CairnStates states) {
        // Inactive: `text-foreground/60`, or `text-muted-foreground` in dark.
        final Color foreground = selected
            ? theme.foreground
            : states.hovered
            ? theme.foreground
            : (isDark
                  ? theme.mutedForeground
                  : theme.foreground.withValues(alpha: 0.6));

        return Opacity(
          opacity: states.disabled ? 0.5 : 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              CairnShadowed(
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
                shadows: <BoxShadow>[
                  if (filled && selected) ...CairnShadows.sm,
                  if (states.focused) ...theme.focusRing,
                ],
                child: AnimatedContainer(
                  duration: CairnMotion.d150,
                  curve: CairnMotion.standard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CairnSpacing.s2,
                    vertical: CairnSpacing.s1,
                  ),
                  // No `alignment`: a Container with one expands to fill bounded
                  // constraints, which would stretch every trigger to the track
                  // width even when `expand` is false. The Row below centres.
                  decoration: BoxDecoration(
                    color: filled && selected
                        ? (isDark
                              ? theme.input.withOpacityModifier(0.3)
                              : theme.background)
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(theme.radiusScale.md),
                    border: Border.all(
                      color: states.focused
                          ? theme.ring
                          : const Color(0x00000000),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s1p5,
                    children: <Widget>[
                      if (tab.icon != null)
                        IconTheme(
                          data: IconThemeData(color: foreground, size: 16),
                          child: SizedBox.square(
                            dimension: 16,
                            child: tab.icon,
                          ),
                        ),
                      DefaultTextStyle(
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              fontWeight: CairnTypography.medium,
                              color: foreground,
                            ),
                        child: tab.label,
                      ),
                    ],
                  ),
                ),
              ),
              // The line variant's underline: `after:bottom-[-5px] h-0.5`.
              if (!filled && selected)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -5,
                  child: Container(height: 2, color: theme.foreground),
                ),
            ],
          ),
        );
      },
    );
  }
}
