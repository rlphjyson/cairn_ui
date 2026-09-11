import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';

/// A checkbox, optionally with an indeterminate third state.
///
/// `size-4 shrink-0 rounded-[4px] border border-input shadow-xs` — 16 logical
/// pixels square with a 4px radius. That radius is a **literal 4px**, not a
/// step on the radius scale, so it holds even when a theme retunes its base: at
/// 16px square, a proportionally scaled radius would round the box into a
/// blob.
///
/// Checking swaps to `bg-primary border-primary text-primary-foreground` and
/// draws a 14px (`size-3.5`) check.
///
/// Supports a tristate (indeterminate) value, rendered as a minus instead of a
/// check — the state a "select all" box needs when only some of the boxes it
/// governs are ticked.
///
/// ```dart
/// CairnCheckbox(
///   value: accepted,
///   onChanged: (v) => setState(() => accepted = v ?? false),
/// );
/// ```
class CairnCheckbox extends StatelessWidget {
  /// Creates a checkbox.
  const CairnCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.hasError = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Whether the box is checked. Null means indeterminate when [tristate] is
  /// true.
  final bool? value;

  /// Called with the next value when the user toggles the box.
  ///
  /// Null disables the checkbox.
  final ValueChanged<bool?>? onChanged;

  /// Whether the box cycles through an indeterminate state.
  final bool tristate;

  /// Marks the control invalid (`aria-invalid`).
  final bool hasError;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// The accessible name.
  final String? semanticLabel;

  /// `size-4`.
  static const double _size = 16.0;

  /// `rounded-[4px]` — a literal value, not a `--radius` step.
  static const double _radius = 4.0;

  /// `size-3.5` — the check glyph.
  static const double _iconSize = 14.0;

  bool get _enabled => onChanged != null;

  /// In tristate mode the cycle is unchecked -> checked -> indeterminate.
  bool? get _next {
    if (!tristate) return !(value ?? false);
    return switch (value) {
      false => true,
      true => null,
      null => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool checked = value ?? false;
    final bool indeterminate = value == null && tristate;
    final bool filled = checked || indeterminate;

    return Semantics(
      checked: checked,
      mixed: indeterminate,
      enabled: _enabled,
      label: semanticLabel,
      child: CairnInteractive(
        enabled: _enabled,
        focusNode: focusNode,
        autofocus: autofocus,
        includeSemantics: false,
        onTap: () => onChanged?.call(_next),
        builder: (BuildContext context, CairnStates states) {
          final Color borderColor = hasError
              ? theme.destructive
              : states.focused
              ? theme.ring
              : (filled ? theme.primary : theme.input);

          return Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            // Unchecked in light mode the box is transparent, so the shadow
            // and focus ring have to be clipped to its exterior.
            child: CairnShadowed(
              borderRadius: BorderRadius.circular(_radius),
              shadows: <BoxShadow>[
                ...CairnShadows.xs,
                if (states.focused)
                  ...(hasError ? theme.invalidRing : theme.focusRing),
              ],
              child: AnimatedContainer(
                duration: CairnMotion.d150,
                curve: CairnMotion.standard,
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: filled
                      ? theme.primary
                      : (isDark
                            ? theme.input.withOpacityModifier(0.3)
                            : const Color(0x00000000)),
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: borderColor),
                ),
                child: filled
                    ? Center(
                        child: CairnIcon(
                          indeterminate
                              ? CairnIconData.minus
                              : CairnIconData.check,
                          size: _iconSize,
                          color: theme.primaryForeground,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
