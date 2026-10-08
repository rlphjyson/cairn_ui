import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/typography.dart';

/// A text link.
///
/// `text-primary font-medium underline-offset-4 hover:underline` — primary
/// coloured, underlined on hover and on keyboard focus, and drawing the same
/// 3px ring other controls draw when focused so it is findable by keyboard.
///
/// Cairn does not navigate: [onPressed] is where you call your router or
/// `url_launcher`. Set [muted] for the quieter `mutedForeground` variant used
/// in footers, and [underline] to underline at rest.
///
/// ```dart
/// CairnLink(onPressed: () => context.go('/docs'), child: Text('Read the docs'));
/// ```
class CairnLink extends StatelessWidget {
  /// Creates a link.
  const CairnLink({
    super.key,
    required this.child,
    required this.onPressed,
    this.muted = false,
    this.underline = false,
  });

  /// The link text.
  final Widget child;

  /// Called on activation. Null renders it disabled.
  final VoidCallback? onPressed;

  /// Whether to use the muted colour.
  final bool muted;

  /// Whether to underline when not hovered or focused.
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool enabled = onPressed != null;

    return CairnInteractive(
      enabled: enabled,
      onTap: onPressed,
      mouseCursor: CairnCursors.forEnabled(enabled),
      builder: (BuildContext context, CairnStates states) {
        final bool underlined = underline || states.hovered || states.focused;
        return Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.radiusScale.sm),
              boxShadow: states.focused ? theme.focusRing : null,
            ),
            child: DefaultTextStyle.merge(
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(
                    fontWeight: CairnTypography.medium,
                    color: muted ? theme.mutedForeground : theme.primary,
                    decoration: underlined
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: muted
                        ? theme.mutedForeground
                        : theme.primary,
                  ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
