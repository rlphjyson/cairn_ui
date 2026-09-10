import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/popover_layer.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// The floating panel shared by Popover, Dropdown Menu, Select and friends.
///
/// `rounded-md border bg-popover text-popover-foreground shadow-md`. Padding
/// varies by component — Popover and Hover Card use `p-4`, menus use `p-1` —
/// so it is a parameter rather than baked in.
///
/// Exposed publicly so applications can build their own floating surfaces that
/// match the rest of the library.
class CairnSurface extends StatelessWidget {
  /// Creates a floating surface.
  const CairnSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(CairnSpacing.s4),
    this.width,
    this.constraints,
    this.elevated = false,
  });

  /// The panel's contents.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// An optional fixed width.
  final double? width;

  /// Optional size constraints.
  final BoxConstraints? constraints;

  /// Whether to use `shadow-lg` instead of `shadow-md`.
  ///
  /// Submenus and Context Menus sit at `shadow-lg`; top-level Popovers and
  /// Dropdown Menus at `shadow-md`.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      width: width,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.popover,
        borderRadius: BorderRadius.circular(theme.radiusScale.md),
        border: Border.all(color: theme.border),
        boxShadow: elevated ? CairnShadows.lg : CairnShadows.md,
      ),
      child: DefaultTextStyle(
        style: theme
            .textStyle(CairnTypography.sm)
            .copyWith(color: theme.popoverForeground),
        // The popover layer caps a surface's height to the room between the
        // anchor and the viewport edge. Content taller than that must scroll
        // rather than overflow — a tall Calendar in a short window is the
        // common case.
        //
        // The scroll view is added only when the incoming constraints are
        // bounded. A vertical viewport given unbounded height throws, and
        // CairnSurface is public API that can legitimately be placed inside a
        // Row or Column with no height limit.
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (!constraints.hasBoundedHeight) return child;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// A floating panel anchored to a trigger, matching shadcn/ui's `Popover`.
///
/// The content is `w-72` (288 logical pixels) with `p-4` padding, `rounded-md`,
/// a 1px border and `shadow-md`, offset 4px from the trigger.
///
/// ```dart
/// final controller = CairnOverlayController();
///
/// CairnPopover(
///   controller: controller,
///   content: const Text('Anchored content'),
///   child: CairnButton(
///     onPressed: controller.toggle,
///     child: const Text('Open'),
///   ),
/// );
/// ```
class CairnPopover extends StatelessWidget {
  /// Creates a popover.
  const CairnPopover({
    super.key,
    required this.controller,
    required this.child,
    required this.content,
    this.side = CairnSide.bottom,
    this.align = CairnAlign.center,
    this.offset = 4.0,
    this.width = 288.0,
    this.padding = const EdgeInsets.all(CairnSpacing.s4),
  });

  /// Drives the open state.
  final CairnOverlayController controller;

  /// The trigger.
  final Widget child;

  /// The panel's contents.
  final Widget content;

  /// The preferred side.
  final CairnSide side;

  /// The cross-axis alignment.
  final CairnAlign align;

  /// The gap between trigger and panel.
  final double offset;

  /// The panel width (`w-72`).
  final double? width;

  /// The panel's inner padding (`p-4`).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CairnAnchoredOverlay(
    controller: controller,
    side: side,
    align: align,
    offset: offset,
    anchor: child,
    overlayBuilder: (BuildContext context) =>
        CairnSurface(width: width, padding: padding, child: content),
  );
}

/// The title slot of a [CairnPopover] — `font-medium`.
class CairnPopoverTitle extends StatelessWidget {
  /// Creates a popover title.
  const CairnPopoverTitle(this.text, {super.key});

  /// The title text.
  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      text,
      style: theme
          .textStyle(CairnTypography.sm)
          .copyWith(
            fontWeight: CairnTypography.medium,
            color: theme.popoverForeground,
          ),
    );
  }
}

/// The description slot of a [CairnPopover] — `text-muted-foreground`.
class CairnPopoverDescription extends StatelessWidget {
  /// Creates a popover description.
  const CairnPopoverDescription(this.text, {super.key});

  /// The description text.
  final String text;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Text(
      text,
      style: theme
          .textStyle(CairnTypography.sm)
          .copyWith(color: theme.mutedForeground),
    );
  }
}
