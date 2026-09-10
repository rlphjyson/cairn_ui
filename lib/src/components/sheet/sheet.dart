import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// Which edge a [CairnSheet] slides in from.
enum CairnSheetSide {
  /// `inset-x-0 top-0 h-auto border-b`.
  top,

  /// `inset-y-0 right-0 h-full w-3/4 sm:max-w-sm border-l`.
  right,

  /// `inset-x-0 bottom-0 h-auto border-t`.
  bottom,

  /// `inset-y-0 left-0 h-full w-3/4 sm:max-w-sm border-r`.
  left;

  /// Whether this side produces a full-height side panel.
  bool get isHorizontal =>
      this == CairnSheetSide.left || this == CairnSheetSide.right;
}

/// Shows an edge-anchored panel matching shadcn/ui's `Sheet`.
///
/// Side sheets are `w-3/4 sm:max-w-sm` — three quarters of the viewport, capped
/// at 384 logical pixels — with a `shadow-lg` and a border on the inner edge.
///
/// The animation is **asymmetric**, which is easy to miss: shadcn/ui specifies
/// `data-[state=open]:duration-500` and `data-[state=closed]:duration-300`, so
/// a sheet opens noticeably slower than it closes. That is reproduced here via
/// the route's separate forward and reverse durations.
///
/// ```dart
/// await showCairnSheet<void>(
///   context: context,
///   side: CairnSheetSide.right,
///   builder: (context) => const CairnSheet(
///     title: Text('Filters'),
///     content: SizedBox.shrink(),
///   ),
/// );
/// ```
Future<T?> showCairnSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  CairnSheetSide side = CairnSheetSide.right,
  bool barrierDismissible = true,
}) {
  final CairnTheme theme = CairnTheme.of(context);
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SheetRoute<T>(
      builder: builder,
      side: side,
      barrierDismissible: barrierDismissible,
      barrierColor: theme.overlay,
    ),
  );
}

/// A route that slides its child in from an edge.
class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({
    required this.builder,
    required this.side,
    required this.barrierDismissible,
    required this.barrierColor,
  });

  final WidgetBuilder builder;
  final CairnSheetSide side;

  @override
  final bool barrierDismissible;

  @override
  final Color barrierColor;

  @override
  String get barrierLabel => 'Dismiss';

  /// `data-[state=open]:duration-500`.
  @override
  Duration get transitionDuration => CairnMotion.d500;

  /// `data-[state=closed]:duration-300`.
  @override
  Duration get reverseTransitionDuration => CairnMotion.d300;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Builder(builder: builder);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Offset begin = switch (side) {
      CairnSheetSide.left => const Offset(-1, 0),
      CairnSheetSide.right => const Offset(1, 0),
      CairnSheetSide.top => const Offset(0, -1),
      CairnSheetSide.bottom => const Offset(0, 1),
    };

    return Align(
      alignment: switch (side) {
        CairnSheetSide.left => Alignment.centerLeft,
        CairnSheetSide.right => Alignment.centerRight,
        CairnSheetSide.top => Alignment.topCenter,
        CairnSheetSide.bottom => Alignment.bottomCenter,
      },
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            // `ease-in-out` on the way in, matching `transition ease-in-out`.
            curve: CairnMotion.standard,
            reverseCurve: CairnMotion.standard,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// The panel shown by [showCairnSheet].
class CairnSheet extends StatelessWidget {
  /// Creates a sheet panel.
  const CairnSheet({
    super.key,
    this.title,
    this.description,
    this.content,
    this.footer = const <Widget>[],
    this.side = CairnSheetSide.right,
    this.showCloseButton = true,
    this.maxExtent = 384.0,
    this.widthFactor = 0.75,
  });

  /// The heading — `font-semibold text-foreground`.
  final Widget? title;

  /// The supporting text — `text-sm text-muted-foreground`.
  final Widget? description;

  /// The body.
  final Widget? content;

  /// Footer actions, pinned to the bottom (`mt-auto`).
  final List<Widget> footer;

  /// Which edge this sheet is attached to.
  final CairnSheetSide side;

  /// Whether to show the `top-4 right-4` close affordance.
  final bool showCloseButton;

  /// `sm:max-w-sm` — 24rem.
  final double maxExtent;

  /// `w-3/4`.
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final bool horizontal = side.isHorizontal;

    final double? width = horizontal
        ? (screen.width * widthFactor).clamp(0.0, maxExtent)
        : null;

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: true,
      child: Container(
        width: horizontal ? width : screen.width,
        height: horizontal ? screen.height : null,
        decoration: BoxDecoration(
          color: theme.background,
          boxShadow: CairnShadows.lg,
          border: Border(
            left: side == CairnSheetSide.right
                ? BorderSide(color: theme.border)
                : BorderSide.none,
            right: side == CairnSheetSide.left
                ? BorderSide(color: theme.border)
                : BorderSide.none,
            top: side == CairnSheetSide.bottom
                ? BorderSide(color: theme.border)
                : BorderSide.none,
            bottom: side == CairnSheetSide.top
                ? BorderSide(color: theme.border)
                : BorderSide.none,
          ),
        ),
        child: SafeArea(
          child: DefaultTextStyle(
            style: theme.defaultTextStyle,
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisSize: horizontal
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  // `gap-4` between the sheet's slots.
                  spacing: CairnSpacing.s4,
                  children: <Widget>[
                    if (title != null || description != null)
                      Padding(
                        // `p-4` on the header.
                        padding: const EdgeInsets.all(CairnSpacing.s4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // `gap-1.5`.
                          spacing: CairnSpacing.s1p5,
                          children: <Widget>[
                            if (title != null)
                              DefaultTextStyle(
                                style: theme
                                    .textStyle(CairnTypography.sm)
                                    .copyWith(
                                      fontWeight: CairnTypography.semibold,
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
                        ),
                      ),
                    if (content != null)
                      horizontal
                          ? Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: CairnSpacing.s4,
                                ),
                                child: content!,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: CairnSpacing.s4,
                              ),
                              child: content!,
                            ),
                    if (footer.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(CairnSpacing.s4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: CairnSpacing.s2,
                          children: footer,
                        ),
                      ),
                  ],
                ),
                if (showCloseButton)
                  Positioned(
                    top: CairnSpacing.s4,
                    right: CairnSpacing.s4,
                    child: _SheetClose(theme: theme),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The sheet's close affordance.
class _SheetClose extends StatelessWidget {
  const _SheetClose({required this.theme});

  final CairnTheme theme;

  @override
  Widget build(BuildContext context) => CairnInteractive(
    onTap: () => Navigator.of(context).maybePop(),
    semanticLabel: 'Close',
    builder: (BuildContext context, CairnStates states) => Opacity(
      opacity: states.hovered ? 1.0 : 0.7,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: states.hovered ? theme.secondary : const Color(0x00000000),
          boxShadow: states.focused ? theme.focusRing : null,
        ),
        child: CairnIcon(CairnIconData.close, color: theme.foreground),
      ),
    ),
  );
}

/// A bottom sheet with a drag handle, matching shadcn/ui's `Drawer`.
///
/// shadcn/ui's Drawer wraps Vaul, which is a bottom-anchored sheet with a grab
/// handle and drag-to-dismiss. Cairn implements it as a [CairnSheet] pinned to
/// the bottom edge plus the handle and drag gesture, rather than as a separate
/// system.
class CairnDrawer extends StatelessWidget {
  /// Creates a drawer panel.
  const CairnDrawer({
    super.key,
    this.title,
    this.description,
    this.content,
    this.footer = const <Widget>[],
  });

  /// The heading.
  final Widget? title;

  /// The supporting text.
  final Widget? description;

  /// The body.
  final Widget? content;

  /// Footer actions.
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return GestureDetector(
      // Drag down past a threshold dismisses, matching Vaul.
      onVerticalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.of(context).maybePop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.background,
          border: Border(top: BorderSide(color: theme.border)),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.radiusScale.lg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Vaul's grab handle: `mx-auto mt-4 h-2 w-[100px] rounded-full
              // bg-muted`.
              Padding(
                padding: const EdgeInsets.only(top: CairnSpacing.s4),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.muted,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
              CairnSheet(
                title: title,
                description: description,
                content: content,
                footer: footer,
                side: CairnSheetSide.bottom,
                showCloseButton: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a [CairnDrawer] from the bottom edge.
Future<T?> showCairnDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) => showCairnSheet<T>(
  context: context,
  builder: builder,
  side: CairnSheetSide.bottom,
  barrierDismissible: barrierDismissible,
);
