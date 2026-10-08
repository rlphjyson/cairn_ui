import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../tokens/motion.dart';

/// How a [CairnSwap] animates between its two faces.
enum CairnSwapEffect {
  /// Cross-fade.
  fade,

  /// Rotate a quarter turn while fading — a menu icon becoming a close icon.
  rotate,

  /// Flip around the vertical axis.
  flip,
}

/// A toggle that swaps between two widgets — a hamburger and a close icon, a
/// sun and a moon, a play and a pause.
///
/// Tapping (or pressing Space / Enter when focused) calls [onChanged] with the
/// opposite of [value]. The control is controlled: it shows [on] when [value] is
/// true and [off] otherwise, and animates between them at 200ms on the standard
/// curve using the chosen [effect].
///
/// ```dart
/// CairnSwap(
///   value: _open,
///   onChanged: (v) => setState(() => _open = v),
///   effect: CairnSwapEffect.rotate,
///   on: const CairnIcon(CairnIconData.close),
///   off: const CairnIcon(CairnIconData.moreHorizontal),
///   semanticLabel: 'Toggle menu',
/// );
/// ```
class CairnSwap extends StatelessWidget {
  /// Creates a swap.
  const CairnSwap({
    super.key,
    required this.value,
    required this.on,
    required this.off,
    this.onChanged,
    this.effect = CairnSwapEffect.fade,
    this.semanticLabel,
  });

  /// Whether [on] is showing.
  final bool value;

  /// The face shown when [value] is true.
  final Widget on;

  /// The face shown when [value] is false.
  final Widget off;

  /// Called with the new value on tap. Null makes the swap inert.
  final ValueChanged<bool>? onChanged;

  /// The transition style.
  final CairnSwapEffect effect;

  /// The accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget face = AnimatedSwitcher(
      duration: CairnMotion.d200,
      switchInCurve: CairnMotion.standard,
      switchOutCurve: CairnMotion.standard,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          switch (effect) {
            CairnSwapEffect.fade => FadeTransition(
              opacity: animation,
              child: child,
            ),
            CairnSwapEffect.rotate => FadeTransition(
              opacity: animation,
              child: RotationTransition(
                turns: Tween<double>(begin: -0.25, end: 0.0).animate(animation),
                child: child,
              ),
            ),
            CairnSwapEffect.flip => AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateY((1 - animation.value) * math.pi / 2),
                child: Opacity(opacity: animation.value, child: child),
              ),
              child: child,
            ),
          },
      child: KeyedSubtree(key: ValueKey<bool>(value), child: value ? on : off),
    );

    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: CairnInteractive(
        enabled: onChanged != null,
        onTap: () => onChanged?.call(!value),
        includeSemantics: false,
        builder: (BuildContext context, CairnStates states) => face,
      ),
    );
  }
}
