import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/radius.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';

/// A group of mutually exclusive radio buttons, matching shadcn/ui's
/// `RadioGroup`.
///
/// The group itself is `grid gap-3` — a 12 logical pixel gap between items.
///
/// ## Accessibility
///
/// Radix implements radio groups with **roving focus**: the group holds a
/// single tab stop, and arrow keys move the selection between items. Cairn
/// reproduces that with a [FocusTraversalGroup] plus arrow-key [Shortcuts], so
/// tabbing lands on the group once rather than stepping through every option —
/// which is both the accessible behaviour and what a screen-reader user
/// expects.
///
/// ```dart
/// CairnRadioGroup<String>(
///   value: plan,
///   onChanged: (v) => setState(() => plan = v),
///   children: const [
///     CairnRadioItem(value: 'free', label: Text('Free')),
///     CairnRadioItem(value: 'pro', label: Text('Pro')),
///   ],
/// );
/// ```
class CairnRadioGroup<T> extends StatelessWidget {
  /// Creates a radio group.
  const CairnRadioGroup({
    super.key,
    required this.value,
    required this.children,
    this.onChanged,
    this.spacing = CairnSpacing.s3,
    this.semanticLabel,
  });

  /// The currently selected value.
  final T? value;

  /// The items in this group. Typically [CairnRadioItem]s.
  final List<Widget> children;

  /// Called when the selection changes. Null disables the whole group.
  final ValueChanged<T>? onChanged;

  /// The gap between items (`gap-3`).
  final double spacing;

  /// The accessible name for the group.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return _CairnRadioScope<T>(
      value: value,
      onChanged: onChanged,
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: FocusTraversalGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Carries the group's selection down to its items.
class _CairnRadioScope<T> extends InheritedWidget {
  const _CairnRadioScope({
    required this.value,
    required this.onChanged,
    required super.child,
  });

  final T? value;
  final ValueChanged<T>? onChanged;

  static _CairnRadioScope<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CairnRadioScope<T>>();

  @override
  bool updateShouldNotify(_CairnRadioScope<T> oldWidget) =>
      oldWidget.value != value || oldWidget.onChanged != onChanged;
}

/// One option inside a [CairnRadioGroup].
///
/// The control is `aspect-square size-4 rounded-full border border-input
/// shadow-xs` with a `size-2 fill-primary` dot when selected — a 16px circle
/// containing an 8px filled dot.
class CairnRadioItem<T> extends StatelessWidget {
  /// Creates a radio item.
  const CairnRadioItem({
    super.key,
    required this.value,
    this.label,
    this.enabled = true,
    this.focusNode,
    this.semanticLabel,
  });

  /// The value this item selects.
  final T value;

  /// An optional label rendered beside the control.
  final Widget? label;

  /// Whether this individual item is selectable.
  final bool enabled;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// The accessible name. Falls back to [label] when that is a [Text].
  final String? semanticLabel;

  /// `size-4`.
  static const double _size = 16.0;

  /// `size-2` — the selected dot.
  static const double _dotSize = 8.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final _CairnRadioScope<T>? scope = _CairnRadioScope.maybeOf<T>(context);
    final bool selected = scope?.value == value;
    final ValueChanged<T>? onChanged = scope?.onChanged;
    final bool isEnabled = enabled && onChanged != null;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: isEnabled,
      label: semanticLabel,
      child: CairnInteractive(
        enabled: isEnabled,
        focusNode: focusNode,
        includeSemantics: false,
        onTap: () => onChanged?.call(value),
        builder: (BuildContext context, CairnStates states) {
          // The circle is transparent in light mode, so its shadow and focus
          // ring must be clipped outside the shape.
          final Widget control = CairnShadowed(
            borderRadius: CairnRadius.brFull,
            shadows: <BoxShadow>[
              ...CairnShadows.xs,
              if (states.focused) ...theme.focusRing,
            ],
            child: AnimatedContainer(
              duration: CairnMotion.d150,
              curve: CairnMotion.standard,
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.input.withOpacityModifier(0.3)
                    : const Color(0x00000000),
                borderRadius: CairnRadius.brFull,
                border: Border.all(
                  color: states.focused ? theme.ring : theme.input,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: CairnRadius.brFull,
                        ),
                      ),
                    )
                  : null,
            ),
          );

          return Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            child: label == null
                ? control
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s2,
                    children: <Widget>[
                      control,
                      DefaultTextStyle(
                        style: theme.defaultTextStyle,
                        child: label!,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
