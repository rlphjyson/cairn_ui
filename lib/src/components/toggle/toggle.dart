import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The visual style of a [CairnToggle].
enum CairnToggleVariant {
  /// `bg-transparent` — no border or fill at rest.
  normal,

  /// `border border-input bg-transparent shadow-xs`.
  outline,
}

/// The size of a [CairnToggle].
enum CairnToggleSize {
  /// `h-8 min-w-8 px-1.5`.
  sm,

  /// `h-9 min-w-9 px-2`.
  md,

  /// `h-10 min-w-10 px-2.5`.
  lg,
}

/// A two-state button matching shadcn/ui's `Toggle`.
///
/// `rounded-md text-sm font-medium hover:bg-muted hover:text-muted-foreground`,
/// switching to `bg-accent text-accent-foreground` when on.
///
/// Note the sizes use `min-w-*` rather than a fixed width, so a toggle holding
/// only an icon is square but one holding text grows — reproduced here with
/// [BoxConstraints.minWidth].
///
/// ```dart
/// CairnToggle(
///   value: bold,
///   onChanged: (v) => setState(() => bold = v),
///   child: const Text('B'),
/// );
/// ```
class CairnToggle extends StatelessWidget {
  /// Creates a toggle.
  const CairnToggle({
    super.key,
    required this.value,
    required this.child,
    this.onChanged,
    this.variant = CairnToggleVariant.normal,
    this.size = CairnToggleSize.md,
    this.focusNode,
    this.semanticLabel,
  });

  /// Whether the toggle is on.
  final bool value;

  /// The toggle's content.
  final Widget child;

  /// Called with the next value. Null disables the toggle.
  final ValueChanged<bool>? onChanged;

  /// The visual style.
  final CairnToggleVariant variant;

  /// The size.
  final CairnToggleSize size;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// The accessible name.
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  /// `h-*` and `min-w-*`.
  double get _extent => switch (size) {
    CairnToggleSize.sm => 32.0,
    CairnToggleSize.md => 36.0,
    CairnToggleSize.lg => 40.0,
  };

  /// `px-*`.
  double get _paddingX => switch (size) {
    CairnToggleSize.sm => CairnSpacing.s1p5,
    CairnToggleSize.md => CairnSpacing.s2,
    CairnToggleSize.lg => CairnSpacing.s2p5,
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Semantics(
      toggled: value,
      enabled: _enabled,
      label: semanticLabel,
      child: CairnInteractive(
        enabled: _enabled,
        focusNode: focusNode,
        includeSemantics: false,
        onTap: () => onChanged?.call(!value),
        builder: (BuildContext context, CairnStates states) {
          final Color background = value
              ? theme.accent
              : (states.hovered ? theme.muted : const Color(0x00000000));
          final Color foreground = value
              ? theme.accentForeground
              : (states.hovered ? theme.mutedForeground : theme.foreground);

          return Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            child: AnimatedContainer(
              duration: CairnMotion.d150,
              curve: CairnMotion.standard,
              height: _extent,
              constraints: BoxConstraints(minWidth: _extent),
              padding: EdgeInsets.symmetric(horizontal: _paddingX),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
                border: variant == CairnToggleVariant.outline
                    ? Border.all(
                        color: states.focused ? theme.ring : theme.input,
                      )
                    : (states.focused ? Border.all(color: theme.ring) : null),
                boxShadow: <BoxShadow>[
                  if (variant == CairnToggleVariant.outline) ...CairnShadows.xs,
                  if (states.focused) ...theme.focusRing,
                ],
              ),
              child: IconTheme(
                data: IconThemeData(color: foreground, size: 16),
                child: DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        color: foreground,
                      ),
                  maxLines: 1,
                  softWrap: false,
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
