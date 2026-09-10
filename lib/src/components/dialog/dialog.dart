import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/colors.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Shows a modal dialog matching shadcn/ui's `Dialog`.
///
/// The panel is `w-full max-w-[calc(100%-2rem)] sm:max-w-lg gap-4 rounded-lg
/// border bg-background p-6 shadow-lg` over a `bg-black/50` scrim, animating in
/// over 200ms with `fade-in-0 zoom-in-95`.
///
/// ## Why this pushes a route
///
/// Radix traps focus inside an open dialog, restores it to the trigger on
/// close, and closes on Escape. Flutter gives all three for free to anything
/// pushed as a [ModalRoute] — [Navigator] installs a [FocusScope] per route and
/// restores focus on pop. Reimplementing that on an [OverlayEntry] would mean
/// hand-rolling a focus trap, so modal surfaces use a route while *anchored*
/// surfaces (Popover, Dropdown Menu) use an overlay.
///
/// It also means the platform back gesture and Android's back button dismiss
/// the dialog, which users expect and Radix has no equivalent of.
///
/// ```dart
/// await showCairnDialog<void>(
///   context: context,
///   builder: (context) => CairnDialog(
///     title: const Text('Delete project'),
///     description: const Text('This cannot be undone.'),
///     content: const SizedBox.shrink(),
///     actions: [
///       CairnButton(
///         variant: CairnButtonVariant.outline,
///         onPressed: () => Navigator.pop(context),
///         child: const Text('Cancel'),
///       ),
///     ],
///   ),
/// );
/// ```
Future<T?> showCairnDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss',
}) {
  final CairnTheme theme = CairnTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    _CairnModalRoute<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: theme.overlay,
      transitionDuration: CairnMotion.d200,
      transitionBuilder: _zoomFade,
    ),
  );
}

/// `fade-in-0 zoom-in-95` — a fade from 0 combined with a scale from 0.95.
Widget _zoomFade(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondary,
  Widget child,
) {
  final CurvedAnimation curved = CurvedAnimation(
    parent: animation,
    curve: CairnMotion.easeOut,
    reverseCurve: CairnMotion.easeIn,
  );
  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
      child: child,
    ),
  );
}

/// A [PopupRoute] carrying Cairn's modal transition and scrim.
class _CairnModalRoute<T> extends PopupRoute<T> {
  _CairnModalRoute({
    required this.builder,
    required this.barrierDismissible,
    required this.barrierLabel,
    required this.barrierColor,
    required this.transitionDuration,
    required this.transitionBuilder,
  });

  final WidgetBuilder builder;

  @override
  final bool barrierDismissible;

  @override
  final String barrierLabel;

  @override
  final Color barrierColor;

  @override
  final Duration transitionDuration;

  final RouteTransitionsBuilder transitionBuilder;

  @override
  Duration get reverseTransitionDuration => CairnMotion.d150;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // SafeArea keeps the panel clear of notches and the system status bar.
    return SafeArea(child: Builder(builder: builder));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => transitionBuilder(context, animation, secondaryAnimation, child);
}

/// The panel shown by [showCairnDialog].
///
/// Structure mirrors shadcn/ui's slots: header (title + description), body and
/// footer, separated by `gap-4` (16 logical pixels), inside `p-6` padding.
class CairnDialog extends StatelessWidget {
  /// Creates a dialog panel.
  const CairnDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions = const <Widget>[],
    this.showCloseButton = true,
    this.maxWidth = 512.0,
  });

  /// The dialog heading — `text-lg leading-none font-semibold`.
  final Widget? title;

  /// The supporting text — `text-sm text-muted-foreground`.
  final Widget? description;

  /// The dialog body.
  final Widget? content;

  /// Footer buttons, right-aligned on wide layouts.
  final List<Widget> actions;

  /// Whether to show the `top-4 right-4` close affordance.
  final bool showCloseButton;

  /// `sm:max-w-lg` — 32rem.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Center(
      child: Padding(
        // `max-w-[calc(100%-2rem)]` — 16px of breathing room each side.
        padding: const EdgeInsets.all(CairnSpacing.s4),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            namesRoute: true,
            child: _DialogSurface(
              child: Container(
                padding: const EdgeInsets.all(CairnSpacing.s6),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                  border: Border.all(color: theme.border),
                  boxShadow: CairnShadows.lg,
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: CairnSpacing.s4,
                      children: <Widget>[
                        if (title != null || description != null)
                          CairnDialogHeader(
                            title: title,
                            description: description,
                          ),
                        ?content,
                        if (actions.isNotEmpty)
                          CairnDialogFooter(children: actions),
                      ],
                    ),
                    if (showCloseButton)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _CloseButton(theme: theme),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal stand-in for Material's `Material` widget.
///
/// Dialog content needs an ambient [DefaultTextStyle] and [IconTheme], but
/// wrapping in Material's `Material` would also drag along its ink, elevation
/// and theme defaults — none of which shadcn/ui has. This provides only what is
/// actually required.
class _DialogSurface extends StatelessWidget {
  const _DialogSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DefaultTextStyle(
      style: theme.defaultTextStyle,
      child: IconTheme(
        data: IconThemeData(color: theme.foreground, size: 16),
        child: child,
      ),
    );
  }
}

/// The `top-4 right-4` close affordance.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.theme});

  final CairnTheme theme;

  @override
  Widget build(BuildContext context) {
    return CairnInteractive(
      onTap: () => Navigator.of(context).maybePop(),
      semanticLabel: 'Close',
      builder: (BuildContext context, CairnStates states) => Opacity(
        // `opacity-70 hover:opacity-100`.
        opacity: states.hovered ? 1.0 : 0.7,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // `rounded-xs` — a literal 2px, not a --radius step.
            borderRadius: BorderRadius.circular(2),
            color: states.hovered ? theme.accent : const Color(0x00000000),
            boxShadow: states.focused ? theme.focusRing : null,
          ),
          child: CairnIcon(CairnIconData.close, color: theme.foreground),
        ),
      ),
    );
  }
}

/// The title and description block of a [CairnDialog] — `flex flex-col gap-2`.
class CairnDialogHeader extends StatelessWidget {
  /// Creates a dialog header.
  const CairnDialogHeader({super.key, this.title, this.description});

  /// The heading.
  final Widget? title;

  /// The supporting text.
  final Widget? description;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CairnSpacing.s2,
      children: <Widget>[
        if (title != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.lg)
                .copyWith(
                  fontWeight: CairnTypography.semibold,
                  height: CairnTypography.leadingNone,
                  color: theme.foreground,
                ),
            child: title!,
          ),
        if (description != null)
          DefaultTextStyle(
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
            child: description!,
          ),
      ],
    );
  }
}

/// The action row of a [CairnDialog].
///
/// `flex flex-col-reverse gap-2 sm:flex-row sm:justify-end` — stacked and
/// reversed on narrow screens so the primary action sits at the bottom under a
/// thumb, and a right-aligned row on wide ones. The breakpoint is Tailwind's
/// `sm` (640px).
class CairnDialogFooter extends StatelessWidget {
  /// Creates a dialog footer.
  const CairnDialogFooter({super.key, required this.children});

  /// The actions, in logical order (primary last).
  final List<Widget> children;

  /// Tailwind's `sm` breakpoint.
  static const double _smBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= _smBreakpoint;

    if (wide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: CairnSpacing.s2,
        children: children,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s2,
      // `flex-col-reverse`.
      children: children.reversed.toList(growable: false),
    );
  }
}

/// A confirmation dialog matching shadcn/ui's `AlertDialog`.
///
/// Differs from [CairnDialog] in three ways that matter: there is no close
/// button, the scrim is not dismissible, and Escape does not close it — an
/// alert dialog demands an explicit choice. Radix enforces the same.
class CairnAlertDialog extends StatelessWidget {
  /// Creates an alert dialog panel.
  const CairnAlertDialog({
    super.key,
    this.title,
    this.description,
    this.actions = const <Widget>[],
    this.maxWidth = 512.0,
  });

  /// The heading.
  final Widget? title;

  /// The supporting text.
  final Widget? description;

  /// The actions — typically a cancel and a confirm button.
  final List<Widget> actions;

  /// `sm:max-w-lg`.
  final double maxWidth;

  @override
  Widget build(BuildContext context) => CairnDialog(
    title: title,
    description: description,
    actions: actions,
    maxWidth: maxWidth,
    showCloseButton: false,
  );
}

/// Shows a [CairnAlertDialog].
///
/// Unlike [showCairnDialog] this is not barrier-dismissible and swallows the
/// back gesture, so the user must pick one of [CairnAlertDialog.actions].
Future<T?> showCairnAlertDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final CairnTheme theme = CairnTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    _CairnModalRoute<T>(
      builder: (BuildContext context) =>
          PopScope<T>(canPop: false, child: Builder(builder: builder)),
      barrierDismissible: false,
      barrierLabel: 'Alert',
      barrierColor: theme.overlay,
      transitionDuration: CairnMotion.d200,
      transitionBuilder: _zoomFade,
    ),
  );
}

/// The scrim colour shared by every Cairn modal (`bg-black/50`).
///
/// Exposed so an application building its own modal can match.
const Color cairnModalScrim = CairnColors.overlay;
