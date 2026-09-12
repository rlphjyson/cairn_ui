import 'package:flutter/widgets.dart';

/// Which edge of the anchor a floating surface prefers to sit on.
///
/// A preference, not a guarantee: [CairnPopoverLayout] flips to the opposite
/// edge when the preferred one would overflow the viewport.
enum CairnSide {
  /// Above the anchor.
  top,

  /// To the right of the anchor.
  right,

  /// Below the anchor.
  bottom,

  /// To the left of the anchor.
  left;

  /// The opposite edge, used when the preferred side does not fit.
  CairnSide get flipped => switch (this) {
    CairnSide.top => CairnSide.bottom,
    CairnSide.bottom => CairnSide.top,
    CairnSide.left => CairnSide.right,
    CairnSide.right => CairnSide.left,
  };

  /// Whether this side stacks vertically.
  bool get isVertical => this == CairnSide.top || this == CairnSide.bottom;
}

/// How a floating surface lines up along the anchor's cross axis.
enum CairnAlign {
  /// Flush with the anchor's leading edge.
  start,

  /// Centred on the anchor.
  center,

  /// Flush with the anchor's trailing edge.
  end,
}

/// Positions a floating surface relative to an anchor rectangle.
///
/// This is the layout half of Cairn's popover system. Three behaviours between
/// them cover essentially every case a floating surface runs into:
///
/// * **flip** — if the preferred [side] would overflow the viewport, the
///   surface moves to the opposite side rather than being clipped.
/// * **shift** — along the cross axis the surface is nudged back inside the
///   viewport instead of hanging off the edge.
/// * **offset** — a 4px gap between anchor and surface, enough to read as a
///   separate layer without drifting away from what opened it.
///
/// Sizes larger than the viewport are clamped rather than overflowing, which is
/// what keeps a long Select menu usable on a short window.
class CairnPopoverLayout extends SingleChildLayoutDelegate {
  /// Creates a popover layout delegate.
  const CairnPopoverLayout({
    required this.anchorRect,
    required this.side,
    required this.align,
    required this.offset,
    required this.viewportPadding,
    this.matchAnchorWidth = false,
  });

  /// The anchor's rectangle in global (overlay) coordinates.
  final Rect anchorRect;

  /// The preferred side.
  final CairnSide side;

  /// The cross-axis alignment.
  final CairnAlign align;

  /// The gap between anchor and surface.
  final double offset;

  /// Minimum distance to keep from the viewport edges.
  final double viewportPadding;

  /// Whether the surface should take the anchor's width.
  ///
  /// Select sets this so its menu lines up with its trigger: a menu narrower
  /// than the control that opened it reads as a misplaced tooltip, and one
  /// wider than it reads as a different surface entirely.
  ///
  /// This constrains the width on both sides rather than only setting a floor.
  /// A floor alone is not enough: menu rows lay out at `mainAxisSize.max`, so
  /// with a loose upper bound they expand to whatever maximum they are handed —
  /// which is the whole viewport, not the anchor. The cost of pinning both
  /// sides is that an option longer than the trigger wraps or ellipsizes
  /// instead of widening the menu, which is what a native select does anyway.
  final bool matchAnchorWidth;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth - viewportPadding * 2;
    // The surface may only use the space between the anchor and the far edge,
    // so a menu below a low anchor scrolls instead of running off-screen.
    final double available = switch (side) {
      CairnSide.top => anchorRect.top - offset - viewportPadding,
      CairnSide.bottom =>
        constraints.maxHeight - anchorRect.bottom - offset - viewportPadding,
      _ => constraints.maxHeight - viewportPadding * 2,
    };
    // Flipping may give more room, so allow the larger of the two.
    final double flippedAvailable = switch (side) {
      CairnSide.top =>
        constraints.maxHeight - anchorRect.bottom - offset - viewportPadding,
      CairnSide.bottom => anchorRect.top - offset - viewportPadding,
      _ => available,
    };

    final double anchorWidth = anchorRect.width.clamp(0.0, maxWidth);

    return BoxConstraints(
      minWidth: matchAnchorWidth ? anchorWidth : 0.0,
      maxWidth: matchAnchorWidth
          ? anchorWidth
          : maxWidth.clamp(0.0, double.infinity),
      maxHeight: <double>[available, flippedAvailable]
          .reduce((double a, double b) => a > b ? a : b)
          .clamp(0.0, double.infinity),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    CairnSide resolved = side;

    // Flip if the preferred side cannot fit but the opposite one can.
    bool fits(CairnSide s) => switch (s) {
      CairnSide.top => anchorRect.top - offset - childSize.height >= 0,
      CairnSide.bottom =>
        anchorRect.bottom + offset + childSize.height <= size.height,
      CairnSide.left => anchorRect.left - offset - childSize.width >= 0,
      CairnSide.right =>
        anchorRect.right + offset + childSize.width <= size.width,
    };

    if (!fits(resolved) && fits(resolved.flipped)) {
      resolved = resolved.flipped;
    }

    double x;
    double y;

    if (resolved.isVertical) {
      y = resolved == CairnSide.top
          ? anchorRect.top - offset - childSize.height
          : anchorRect.bottom + offset;
      x = switch (align) {
        CairnAlign.start => anchorRect.left,
        CairnAlign.center => anchorRect.center.dx - childSize.width / 2,
        CairnAlign.end => anchorRect.right - childSize.width,
      };
    } else {
      x = resolved == CairnSide.left
          ? anchorRect.left - offset - childSize.width
          : anchorRect.right + offset;
      y = switch (align) {
        CairnAlign.start => anchorRect.top,
        CairnAlign.center => anchorRect.center.dy - childSize.height / 2,
        CairnAlign.end => anchorRect.bottom - childSize.height,
      };
    }

    // Shift back inside the viewport.
    x = x.clamp(
      viewportPadding,
      (size.width - childSize.width - viewportPadding).clamp(
        viewportPadding,
        double.infinity,
      ),
    );
    y = y.clamp(
      viewportPadding,
      (size.height - childSize.height - viewportPadding).clamp(
        viewportPadding,
        double.infinity,
      ),
    );

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(CairnPopoverLayout oldDelegate) =>
      oldDelegate.anchorRect != anchorRect ||
      oldDelegate.side != side ||
      oldDelegate.align != align ||
      oldDelegate.offset != offset ||
      oldDelegate.viewportPadding != viewportPadding ||
      oldDelegate.matchAnchorWidth != matchAnchorWidth;
}

/// Imperatively opens and closes a floating surface.
///
/// Held by the caller so a Popover, Dropdown Menu or Select can be driven from
/// application code as well as by its own trigger.
///
/// ```dart
/// final controller = CairnOverlayController();
/// ...
/// CairnButton(onPressed: controller.toggle, child: const Text('Open'));
/// ```
class CairnOverlayController extends ChangeNotifier {
  bool _open = false;

  /// Whether the surface is currently shown.
  bool get isOpen => _open;

  /// Shows the surface.
  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  /// Hides the surface.
  void close() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  /// Toggles the surface.
  void toggle() => _open ? close() : open();
}
