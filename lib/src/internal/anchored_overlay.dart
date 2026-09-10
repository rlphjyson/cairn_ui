import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tokens/motion.dart';
import 'popover_layer.dart';

/// Renders a trigger and a floating surface anchored to it.
///
/// This is the shared machinery behind Popover, Dropdown Menu, Context Menu,
/// Select, Combobox, Tooltip, Hover Card and Menubar. It handles the parts that
/// are easy to get subtly wrong in each component separately:
///
/// * **Positioning** via [CairnPopoverLayout], including flip and shift.
/// * **Dismissal** — Escape closes, and a tap outside closes when
///   [dismissOnOutsideTap] is set. Radix calls these `onEscapeKeyDown` and
///   `onPointerDownOutside`.
/// * **Entrance animation** — shadcn/ui's `data-[state=open]:animate-in
///   fade-in-0 zoom-in-95` is a 200ms fade from 0 combined with a scale from
///   0.95, with the transform origin on the anchor's edge so the surface
///   appears to grow out of its trigger.
/// * **Focus** — when [trapFocus] is true the surface takes focus on open and
///   restores it to the trigger on close, matching Radix's focus management for
///   menus. Tooltips and hover cards leave focus alone.
///
/// Uses [OverlayPortal] rather than pushing a route, so the surface does not
/// appear in the navigation stack and a system back gesture does not have to
/// pop it.
class CairnAnchoredOverlay extends StatefulWidget {
  /// Creates an anchored overlay.
  const CairnAnchoredOverlay({
    super.key,
    required this.controller,
    required this.anchor,
    required this.overlayBuilder,
    this.side = CairnSide.bottom,
    this.align = CairnAlign.center,
    this.offset = 4.0,
    this.viewportPadding = 8.0,
    this.matchAnchorWidth = false,
    this.dismissOnOutsideTap = true,
    this.trapFocus = true,
    this.barrierColor,
    this.onClosed,
  });

  /// Drives the open state.
  final CairnOverlayController controller;

  /// The trigger widget.
  final Widget anchor;

  /// Builds the floating surface.
  final WidgetBuilder overlayBuilder;

  /// The preferred side (Radix's `side`).
  final CairnSide side;

  /// The cross-axis alignment (Radix's `align`).
  final CairnAlign align;

  /// The gap between anchor and surface (Radix's `sideOffset`, default 4).
  final double offset;

  /// Minimum distance from the viewport edge.
  final double viewportPadding;

  /// Whether the surface is at least as wide as the anchor.
  final bool matchAnchorWidth;

  /// Whether a tap outside dismisses the surface.
  final bool dismissOnOutsideTap;

  /// Whether to move focus into the surface and restore it on close.
  final bool trapFocus;

  /// An optional scrim colour. Most anchored surfaces have none.
  final Color? barrierColor;

  /// Called after the surface closes.
  final VoidCallback? onClosed;

  @override
  State<CairnAnchoredOverlay> createState() => _CairnAnchoredOverlayState();
}

class _CairnAnchoredOverlayState extends State<CairnAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  final FocusScopeNode _surfaceFocus = FocusScopeNode(
    debugLabel: 'CairnAnchoredOverlay',
  );

  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: CairnMotion.d200,
    reverseDuration: CairnMotion.d150,
  );

  FocusNode? _restoreFocusTo;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _animation.addStatusListener(_onAnimationStatus);
    if (widget.controller.isOpen) _show();
  }

  @override
  void didUpdateWidget(CairnAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animation.removeStatusListener(_onAnimationStatus);
    _animation.dispose();
    _surfaceFocus.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.isOpen) {
      _show();
    } else {
      _animation.reverse();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || !mounted) return;
    _portal.hide();
    if (widget.trapFocus) {
      _restoreFocusTo?.requestFocus();
      _restoreFocusTo = null;
    }
    widget.onClosed?.call();
  }

  void _show() {
    if (widget.trapFocus) {
      _restoreFocusTo = FocusManager.instance.primaryFocus;
    }
    _portal.show();
    _animation.forward();
    if (widget.trapFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.isOpen) {
          _surfaceFocus.requestFocus();
        }
      });
    }
  }

  /// The anchor's rect in the overlay's coordinate space.
  Rect? _anchorRect() {
    final RenderObject? box = _anchorKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final RenderObject? overlay = Overlay.of(
      context,
    ).context.findRenderObject();
    if (overlay is! RenderBox) return null;
    final Offset topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    return topLeft & box.size;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: KeyedSubtree(key: _anchorKey, child: widget.anchor),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final Rect? rect = _anchorRect();
    if (rect == null) return const SizedBox.shrink();

    // `zoom-in-95` scales from 0.95, with the origin on the anchor edge so the
    // surface grows out of its trigger rather than from its own middle.
    final Alignment origin = switch (widget.side) {
      CairnSide.top => Alignment.bottomCenter,
      CairnSide.bottom => Alignment.topCenter,
      CairnSide.left => Alignment.centerRight,
      CairnSide.right => Alignment.centerLeft,
    };

    final Widget surface = FadeTransition(
      opacity: CurvedAnimation(parent: _animation, curve: CairnMotion.easeOut),
      child: ScaleTransition(
        alignment: origin,
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: _animation, curve: CairnMotion.easeOut),
        ),
        child: FocusScope(
          node: _surfaceFocus,
          child: Builder(builder: widget.overlayBuilder),
        ),
      ),
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              widget.controller.close();
              return null;
            },
          ),
        },
        child: Stack(
          children: <Widget>[
            if (widget.dismissOnOutsideTap)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.controller.close,
                  child: widget.barrierColor == null
                      ? const SizedBox.expand()
                      : FadeTransition(
                          opacity: _animation,
                          child: ColoredBox(color: widget.barrierColor!),
                        ),
                ),
              ),
            CustomSingleChildLayout(
              delegate: CairnPopoverLayout(
                anchorRect: rect,
                side: widget.side,
                align: widget.align,
                offset: widget.offset,
                viewportPadding: widget.viewportPadding,
                matchAnchorWidth: widget.matchAnchorWidth,
              ),
              child: surface,
            ),
          ],
        ),
      ),
    );
  }
}
