import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/radius.dart';
import '../../tokens/shadows.dart';

/// The size of a [CairnSwitch].
enum CairnSwitchSize {
  /// `h-3.5 w-6` with a `size-3` thumb — 14 x 24 with a 12px thumb.
  sm,

  /// `h-[1.15rem] w-8` with a `size-4` thumb — 18.4 x 32 with a 16px thumb.
  md,
}

/// A switch.
///
/// The default track is `h-[1.15rem] w-8` — **18.4 logical pixels** tall, not
/// a round number, and deliberately so. The height is derived rather than
/// chosen: a 16px thumb has to clear the 1px transparent border on both sides
/// with a hair of room, and 18.4 is where that lands. Rounding it to 18 pinches
/// the thumb; rounding it to 20 leaves it swimming.
///
/// The thumb travels `translate-x-[calc(100%-2px)]` when checked — its own
/// width minus 2px, so 14 logical pixels at the default size.
///
/// The dark theme inverts the thumb: unchecked it is `bg-foreground`, checked
/// it is `bg-primary-foreground`, whereas light mode keeps it `bg-background`
/// throughout.
///
/// ```dart
/// CairnSwitch(
///   value: notifications,
///   onChanged: (v) => setState(() => notifications = v),
/// );
/// ```
class CairnSwitch extends StatelessWidget {
  /// Creates a switch.
  const CairnSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.size = CairnSwitchSize.md,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the next value. Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// The size.
  final CairnSwitchSize size;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// The accessible name.
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  /// `h-[1.15rem]` = 18.4, or `h-3.5` = 14.
  double get _trackHeight => size == CairnSwitchSize.md ? 18.4 : 14.0;

  /// `w-8` = 32, or `w-6` = 24.
  double get _trackWidth => size == CairnSwitchSize.md ? 32.0 : 24.0;

  /// `size-4` = 16, or `size-3` = 12.
  double get _thumbSize => size == CairnSwitchSize.md ? 16.0 : 12.0;

  /// `translate-x-[calc(100%-2px)]` — the thumb's own width minus 2.
  double get _travel => _thumbSize - 2.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Semantics(
      toggled: value,
      enabled: _enabled,
      label: semanticLabel,
      child: CairnInteractive(
        enabled: _enabled,
        focusNode: focusNode,
        autofocus: autofocus,
        includeSemantics: false,
        onTap: () => onChanged?.call(!value),
        builder: (BuildContext context, CairnStates states) {
          // `data-[state=unchecked]:bg-input`, softened in dark mode.
          final Color trackColor = value
              ? theme.primary
              : (isDark ? theme.input.withOpacityModifier(0.8) : theme.input);

          final Color thumbColor = isDark
              ? (value ? theme.primaryForeground : theme.foreground)
              : theme.background;

          return Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            child: AnimatedContainer(
              duration: CairnMotion.d150,
              curve: CairnMotion.standard,
              width: _trackWidth,
              height: _trackHeight,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: CairnRadius.brFull,
                // `border border-transparent` — present so the box model
                // matches, but invisible.
                border: Border.all(
                  color: states.focused ? theme.ring : const Color(0x00000000),
                ),
                boxShadow: <BoxShadow>[
                  ...CairnShadows.xs,
                  if (states.focused) ...theme.focusRing,
                ],
              ),
              child: Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    duration: CairnMotion.d150,
                    curve: CairnMotion.standard,
                    left: value ? _travel : 0.0,
                    top: 0.0,
                    bottom: 0.0,
                    child: Center(
                      child: Container(
                        width: _thumbSize,
                        height: _thumbSize,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          borderRadius: CairnRadius.brFull,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
