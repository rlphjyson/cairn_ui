import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/popover_layer.dart';
import '../menu/menu.dart';

/// A menu anchored to a trigger, matching shadcn/ui's `DropdownMenu`.
///
/// The panel is a [CairnMenuPanel] — `min-w-[8rem] rounded-md border bg-popover
/// p-1 shadow-md` — positioned 4px from the trigger and aligned to its start
/// edge, which is Radix's default for dropdowns (unlike Popover, which centres).
///
/// Items are closed over automatically: choosing one dismisses the menu, which
/// is Radix's default `onSelect` behaviour.
///
/// ```dart
/// final menu = CairnOverlayController();
///
/// CairnDropdownMenu(
///   controller: menu,
///   items: [
///     CairnMenuLabel('My account'),
///     const CairnMenuSeparator(),
///     CairnMenuItem(onPressed: () {}, shortcut: 'Ctrl+P', child: const Text('Profile')),
///     CairnMenuItem(
///       variant: CairnMenuItemVariant.destructive,
///       onPressed: () {},
///       child: const Text('Sign out'),
///     ),
///   ],
///   child: CairnButton(onPressed: menu.toggle, child: const Text('Open')),
/// );
/// ```
class CairnDropdownMenu extends StatelessWidget {
  /// Creates a dropdown menu.
  const CairnDropdownMenu({
    super.key,
    required this.controller,
    required this.child,
    required this.items,
    this.side = CairnSide.bottom,
    this.align = CairnAlign.start,
    this.offset = 4.0,
    this.minWidth = 128.0,
    this.maxHeight,
    this.closeOnSelect = true,
  });

  /// Drives the open state.
  final CairnOverlayController controller;

  /// The trigger.
  final Widget child;

  /// The menu's rows.
  final List<Widget> items;

  /// The preferred side.
  final CairnSide side;

  /// The cross-axis alignment. Radix defaults dropdowns to `start`.
  final CairnAlign align;

  /// The gap between trigger and panel.
  final double offset;

  /// `min-w-[8rem]`.
  final double minWidth;

  /// An optional scroll cap.
  final double? maxHeight;

  /// Whether choosing an item dismisses the menu.
  final bool closeOnSelect;

  @override
  Widget build(BuildContext context) => CairnAnchoredOverlay(
    controller: controller,
    side: side,
    align: align,
    offset: offset,
    anchor: child,
    overlayBuilder: (BuildContext context) => CairnMenuPanel(
      minWidth: minWidth,
      maxHeight: maxHeight,
      children: closeOnSelect
          ? <Widget>[
              for (final Widget item in items)
                _CloseOnSelect(controller: controller, child: item),
            ]
          : items,
    ),
  );
}

/// Dismisses the owning menu after an item is chosen.
///
/// Wraps each row in a [Listener] on the *up* event rather than replacing the
/// item's callback, so the item's own `onPressed` still runs first and the
/// wrapper works for any widget the caller passes, not just [CairnMenuItem].
class _CloseOnSelect extends StatelessWidget {
  const _CloseOnSelect({required this.controller, required this.child});

  final CairnOverlayController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Labels and separators are not selectable, so they must not dismiss.
    if (child is CairnMenuLabel || child is CairnMenuSeparator) return child;
    return Listener(
      onPointerUp: (_) {
        // Defer so the item's own tap handler completes first.
        WidgetsBinding.instance.addPostFrameCallback((_) => controller.close());
      },
      child: child,
    );
  }
}
