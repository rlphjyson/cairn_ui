import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A floating action button, optionally expanding into a speed dial.
///
/// A 56px primary-coloured circle with the large shadow, the standard
/// treatment for a screen's one primary action. Without [actions] it is a plain
/// button calling [onPressed]. With [actions] it toggles a stack of labelled
/// 40px mini actions above it; the trigger rotates 45 degrees (so a plus
/// becomes a cross) and closes again after an action is picked.
///
/// Place it with `Positioned` or `Align` — it takes only its own size and
/// leaves placement to the caller, as Cairn's other overlays do.
///
/// ```dart
/// CairnFab(
///   icon: const CairnIcon(CairnIconData.plus),
///   semanticLabel: 'Create',
///   actions: [
///     CairnFabAction(icon: Icon(...), label: 'Document', onPressed: () {}),
///   ],
/// );
/// ```
class CairnFab extends StatefulWidget {
  /// Creates a floating action button.
  const CairnFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.actions = const <CairnFabAction>[],
    this.semanticLabel,
  });

  /// The trigger glyph. Draw it as a plus if you use [actions], so the
  /// open rotation reads as a close.
  final Widget icon;

  /// Called on tap when there are no [actions].
  final VoidCallback? onPressed;

  /// Speed-dial entries, nearest the trigger first.
  final List<CairnFabAction> actions;

  /// The accessible name of the trigger.
  final String? semanticLabel;

  @override
  State<CairnFab> createState() => _CairnFabState();
}

/// One entry of a [CairnFab] speed dial.
@immutable
class CairnFabAction {
  /// Creates an action.
  const CairnFabAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// The glyph.
  final Widget icon;

  /// The label shown beside the mini button, also its accessible name.
  final String label;

  /// Called when picked. The dial closes afterwards.
  final VoidCallback onPressed;
}

class _CairnFabState extends State<CairnFab> {
  bool _open = false;

  /// `size-14`.
  static const double _size = 56.0;

  /// `size-10`.
  static const double _mini = 40.0;

  void _trigger() {
    if (widget.actions.isEmpty) {
      widget.onPressed?.call();
    } else {
      setState(() => _open = !_open);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool enabled = widget.actions.isNotEmpty || widget.onPressed != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: CairnSpacing.s3,
      children: <Widget>[
        if (_open)
          for (final CairnFabAction action in widget.actions.reversed)
            _MiniAction(
              action: action,
              size: _mini,
              onPicked: () {
                setState(() => _open = false);
                action.onPressed();
              },
            ),
        Semantics(
          expanded: widget.actions.isEmpty ? null : _open,
          child: CairnInteractive(
            enabled: enabled,
            onTap: _trigger,
            semanticLabel: widget.semanticLabel,
            builder: (BuildContext context, CairnStates states) {
              return Opacity(
                opacity: enabled ? 1.0 : 0.5,
                child: AnimatedContainer(
                  duration: CairnMotion.d150,
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: states.pressed || states.hovered
                        ? theme.primary.withValues(alpha: 0.9)
                        : theme.primary,
                    boxShadow: <BoxShadow>[
                      ...CairnShadows.lg,
                      if (states.focused) ...theme.focusRing,
                    ],
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _open ? 0.125 : 0,
                      duration: CairnMotion.d200,
                      curve: CairnMotion.standard,
                      child: IconTheme(
                        data: IconThemeData(
                          color: theme.primaryForeground,
                          size: 24,
                        ),
                        child: widget.icon,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.action,
    required this.size,
    required this.onPicked,
  });

  final CairnFabAction action;
  final double size;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return CairnInteractive(
      onTap: onPicked,
      semanticLabel: action.label,
      builder: (BuildContext context, CairnStates states) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s3,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CairnSpacing.s2p5,
              vertical: CairnSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: theme.popover,
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
              border: Border.all(color: theme.border),
              boxShadow: CairnShadows.md,
            ),
            child: Text(
              action.label,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.popoverForeground),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: states.hovered ? theme.accent : theme.secondary,
              border: Border.all(color: theme.border),
              boxShadow: <BoxShadow>[
                ...CairnShadows.md,
                if (states.focused) ...theme.focusRing,
              ],
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: theme.secondaryForeground, size: 18),
                child: action.icon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
