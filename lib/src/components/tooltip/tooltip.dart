import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/popover_layer.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../popover/popover.dart';

/// A hover/focus hint.
///
/// `w-fit rounded-md bg-foreground px-3 py-1.5 text-xs text-background` — note
/// the **inverted** colours: a tooltip is the foreground colour filled with
/// background-coloured text, so it reads as a dark chip in light mode and a
/// light chip in dark mode. It carries no border and no shadow.
///
/// ## Behaviour
///
/// The tooltip opens after a 700ms delay and closes immediately on pointer
/// exit: the delay is what stops a row of icon buttons flashing tooltips as the
/// pointer crosses them, and there is no reason to linger once the pointer has
/// left. It also opens on keyboard focus, without which a tooltip is invisible
/// to anyone not using a mouse.
///
/// ```dart
/// CairnTooltip(
///   message: 'Copy to clipboard',
///   child: CairnButton.icon(
///     icon: const CairnIcon(CairnIconData.check),
///     semanticLabel: 'Copy',
///     onPressed: () {},
///   ),
/// );
/// ```
class CairnTooltip extends StatefulWidget {
  /// Creates a tooltip.
  const CairnTooltip({
    super.key,
    required this.message,
    required this.child,
    this.side = CairnSide.top,
    this.align = CairnAlign.center,
    this.offset = 4.0,
    this.openDelay = const Duration(milliseconds: 700),
  });

  /// The hint text.
  final String message;

  /// The widget the tooltip describes.
  final Widget child;

  /// The preferred side.
  final CairnSide side;

  /// The cross-axis alignment.
  final CairnAlign align;

  /// The gap between trigger and tooltip.
  final double offset;

  /// How long the pointer must rest before the tooltip opens.
  final Duration openDelay;

  @override
  State<CairnTooltip> createState() => _CairnTooltipState();
}

class _CairnTooltipState extends State<CairnTooltip> {
  final CairnOverlayController _controller = CairnOverlayController();
  bool _pendingOpen = false;

  @override
  void dispose() {
    _pendingOpen = false;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scheduleOpen() async {
    _pendingOpen = true;
    await Future<void>.delayed(widget.openDelay);
    if (!mounted || !_pendingOpen) return;
    _controller.open();
  }

  void _cancel() {
    _pendingOpen = false;
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Semantics(
      tooltip: widget.message,
      child: MouseRegion(
        onEnter: (_) => _scheduleOpen().ignore(),
        onExit: (_) => _cancel(),
        child: Focus(
          skipTraversal: true,
          canRequestFocus: false,
          onFocusChange: (bool focused) {
            if (focused) {
              _controller.open();
            } else {
              _cancel();
            }
          },
          child: CairnAnchoredOverlay(
            controller: _controller,
            side: widget.side,
            align: widget.align,
            offset: widget.offset,
            // A tooltip must never steal focus or swallow taps.
            trapFocus: false,
            dismissOnOutsideTap: false,
            anchor: widget.child,
            overlayBuilder: (BuildContext context) => IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s3,
                  vertical: CairnSpacing.s1p5,
                ),
                decoration: BoxDecoration(
                  // Inverted: fill is `--foreground`.
                  color: theme.foreground,
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                ),
                child: Text(
                  widget.message,
                  style: theme
                      .textStyle(CairnTypography.xs)
                      .copyWith(color: theme.background),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A richer hover panel.
///
/// `w-64 rounded-md border bg-popover p-4 text-popover-foreground shadow-md` —
/// 256 logical pixels wide, and unlike [CairnTooltip] it is a normal popover
/// surface rather than an inverted chip.
///
/// It opens after 700ms and closes after a 300ms grace period. The grace
/// period is the difference between a usable hover card and an infuriating one:
/// the card holds interactive content, so the pointer has to be able to travel
/// from the trigger to the card without it vanishing in the gap between
/// them.
class CairnHoverCard extends StatefulWidget {
  /// Creates a hover card.
  const CairnHoverCard({
    super.key,
    required this.child,
    required this.content,
    this.side = CairnSide.bottom,
    this.align = CairnAlign.center,
    this.offset = 4.0,
    this.width = 256.0,
    this.openDelay = const Duration(milliseconds: 700),
    this.closeDelay = const Duration(milliseconds: 300),
  });

  /// The trigger.
  final Widget child;

  /// The card's contents.
  final Widget content;

  /// The preferred side.
  final CairnSide side;

  /// The cross-axis alignment.
  final CairnAlign align;

  /// The gap between trigger and card.
  final double offset;

  /// The card width (`w-64`).
  final double width;

  /// How long the pointer must rest before opening.
  final Duration openDelay;

  /// The grace period before closing, so the pointer can reach the card.
  final Duration closeDelay;

  @override
  State<CairnHoverCard> createState() => _CairnHoverCardState();
}

class _CairnHoverCardState extends State<CairnHoverCard> {
  final CairnOverlayController _controller = CairnOverlayController();
  int _generation = 0;

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final int token = ++_generation;
    await Future<void>.delayed(widget.openDelay);
    if (!mounted || token != _generation) return;
    _controller.open();
  }

  Future<void> _close() async {
    final int token = ++_generation;
    await Future<void>.delayed(widget.closeDelay);
    if (!mounted || token != _generation) return;
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _open().ignore(),
      onExit: (_) => _close().ignore(),
      child: CairnAnchoredOverlay(
        controller: _controller,
        side: widget.side,
        align: widget.align,
        offset: widget.offset,
        trapFocus: false,
        dismissOnOutsideTap: false,
        anchor: widget.child,
        overlayBuilder: (BuildContext context) => MouseRegion(
          onEnter: (_) => _generation++,
          onExit: (_) => _close().ignore(),
          child: CairnSurface(width: widget.width, child: widget.content),
        ),
      ),
    );
  }
}
