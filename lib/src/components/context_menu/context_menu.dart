import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/popover_layer.dart';
import '../../tokens/motion.dart';
import '../menu/menu.dart';

/// A menu opened by right-click or long-press.
///
/// Unlike a Dropdown Menu, a context menu is anchored to the **pointer**, not
/// to a widget — so the layout anchor is a zero-size rect at the click point.
/// It also sits at `shadow-lg` rather than `shadow-md`.
///
/// Opens on secondary (right) click on desktop and on long-press on touch,
/// which are the two platform-native gestures for this.
///
/// ```dart
/// CairnContextMenu(
///   items: [
///     CairnMenuItem(onPressed: () {}, child: const Text('Back')),
///     const CairnMenuSeparator(),
///     CairnMenuItem(onPressed: () {}, child: const Text('Reload')),
///   ],
///   child: const CairnCard(children: [/* ... */]),
/// );
/// ```
class CairnContextMenu extends StatefulWidget {
  /// Creates a context menu.
  const CairnContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.minWidth = 128.0,
  });

  /// The region that responds to right-click and long-press.
  final Widget child;

  /// The menu's rows.
  final List<Widget> items;

  /// `min-w-[8rem]`.
  final double minWidth;

  @override
  State<CairnContextMenu> createState() => _CairnContextMenuState();
}

class _CairnContextMenuState extends State<CairnContextMenu>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  Offset? _position;

  /// The open/close animation.
  ///
  /// Constructed in [initState] rather than as a `late final` initialiser.
  /// A lazy field is only created on first read, and for a context menu that
  /// is never opened the first read is `dispose()` — which builds an
  /// [AnimationController] against a deactivated element, and
  /// `SingleTickerProviderStateMixin.createTicker` then walks the tree looking
  /// for a [TickerMode], tripping "Looking up a deactivated widget's ancestor
  /// is unsafe". Every other stateful component here touches its controller in
  /// `initState`, which is why this was the only one affected.
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
          vsync: this,
          duration: CairnMotion.d200,
          reverseDuration: CairnMotion.d150,
        )..addStatusListener((AnimationStatus s) {
          if (s == AnimationStatus.dismissed && mounted) _portal.hide();
        });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _open(Offset globalPosition) {
    final RenderObject? overlay = Overlay.of(
      context,
    ).context.findRenderObject();
    if (overlay is! RenderBox) return;
    setState(() => _position = overlay.globalToLocal(globalPosition));
    _portal.show();
    _animation.forward(from: 0);
  }

  void _close() => _animation.reverse();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapDown: (TapDownDetails d) => _open(d.globalPosition),
        onLongPressStart: (LongPressStartDetails d) => _open(d.globalPosition),
        child: widget.child,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final Offset? at = _position;
    if (at == null) return const SizedBox.shrink();

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (PointerDownEvent _) => _close(),
              ),
            ),
            CustomSingleChildLayout(
              // A zero-size rect at the pointer: the menu hangs from the
              // click point and flips near a screen edge like any popover.
              delegate: CairnPopoverLayout(
                anchorRect: at & Size.zero,
                side: CairnSide.bottom,
                align: CairnAlign.start,
                offset: 0,
                viewportPadding: 8,
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animation,
                  curve: CairnMotion.easeOut,
                ),
                child: ScaleTransition(
                  alignment: Alignment.topLeft,
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animation,
                      curve: CairnMotion.easeOut,
                    ),
                  ),
                  child: CairnMenuPanel(
                    minWidth: widget.minWidth,
                    elevated: true,
                    children: <Widget>[
                      for (final Widget item in widget.items)
                        Listener(
                          onPointerUp: (_) => WidgetsBinding.instance
                              .addPostFrameCallback((_) => _close()),
                          child: item,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
