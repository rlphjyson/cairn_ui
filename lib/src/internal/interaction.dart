import 'package:flutter/widgets.dart';

/// The interaction states a Cairn component can be in.
///
/// Mirrors the CSS pseudo-classes shadcn/ui styles against: `:hover`,
/// `:focus-visible`, `:active` and `:disabled`.
@immutable
class CairnStates {
  /// Creates an interaction state snapshot.
  const CairnStates({
    this.hovered = false,
    this.focused = false,
    this.pressed = false,
    this.disabled = false,
  });

  /// The pointer is over the component (`:hover`).
  ///
  /// Always false on touch devices, where Flutter reports no hover.
  final bool hovered;

  /// The component has keyboard focus **and** the focus highlight is visible
  /// (`:focus-visible`).
  ///
  /// See [CairnInteractive] for why this is not simply "has focus".
  final bool focused;

  /// The component is being pressed (`:active`).
  final bool pressed;

  /// The component is disabled (`:disabled`).
  final bool disabled;

  @override
  bool operator ==(Object other) =>
      other is CairnStates &&
      other.hovered == hovered &&
      other.focused == focused &&
      other.pressed == pressed &&
      other.disabled == disabled;

  @override
  int get hashCode => Object.hash(hovered, focused, pressed, disabled);
}

/// Builds a widget from the current interaction states.
typedef CairnStateBuilder =
    Widget Function(BuildContext context, CairnStates states);

/// Wires pointer, focus and keyboard interaction for a Cairn component.
///
/// This is the shared substrate under Button, menu items, Tabs triggers,
/// Checkbox, Switch and every other interactive component. It exists to get
/// three things right consistently:
///
/// ### 1. `:focus-visible`, not `:focus`
///
/// shadcn/ui draws its focus ring with `focus-visible:`, so clicking a button
/// with a mouse must **not** show a ring, while tabbing to it must. Flutter's
/// [FocusNode.hasFocus] cannot distinguish the two on its own.
///
/// The signal Flutter does expose is [FocusManager.highlightMode], which is
/// [FocusHighlightMode.traditional] once the user has interacted via keyboard
/// or mouse-with-keyboard and [FocusHighlightMode.touch] on touch input. Cairn
/// combines "has focus" with "highlight mode is traditional" **and** tracks
/// whether the most recent focus change was caused by a pointer press, which is
/// what produces true `:focus-visible` behaviour.
///
/// ### 2. Space and Enter activate
///
/// Radix primitives activate on both keys. Flutter's default [Shortcuts] map
/// already binds them to [ActivateIntent] for focusable widgets, so this widget
/// registers an [ActionDispatcher] entry rather than intercepting raw keys —
/// that keeps it composable with a host app's own shortcuts.
///
/// ### 3. Disabled means inert
///
/// `disabled:pointer-events-none` means a disabled control neither hovers nor
/// receives focus. This widget removes it from the focus traversal order and
/// ignores pointers entirely when [enabled] is false.
class CairnInteractive extends StatefulWidget {
  /// Creates an interaction wrapper.
  const CairnInteractive({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.mouseCursor,
    this.onHoverChange,
    this.onFocusChange,
    this.behavior = HitTestBehavior.opaque,
    this.includeSemantics = true,
    this.semanticLabel,
    this.isButton = true,
    this.excludeFromTraversal = false,
  });

  /// Builds the visual given the current [CairnStates].
  final CairnStateBuilder builder;

  /// Called on tap or on keyboard activation (Space / Enter).
  final VoidCallback? onTap;

  /// Called on long press.
  final VoidCallback? onLongPress;

  /// Whether the component responds to input.
  final bool enabled;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// Whether this component can hold focus at all.
  ///
  /// Menu items set this false because their parent menu owns focus and moves
  /// a highlight instead, matching Radix's roving-focus behaviour.
  final bool canRequestFocus;

  /// The cursor to show on hover. Defaults to [SystemMouseCursors.click] when
  /// enabled and [SystemMouseCursors.basic] when not.
  final MouseCursor? mouseCursor;

  /// Called when the hover state changes.
  final ValueChanged<bool>? onHoverChange;

  /// Called when the focus state changes.
  final ValueChanged<bool>? onFocusChange;

  /// How to behave during hit testing.
  final HitTestBehavior behavior;

  /// Whether to emit a [Semantics] node.
  final bool includeSemantics;

  /// The accessibility label.
  final String? semanticLabel;

  /// Whether the semantics node is a button.
  final bool isButton;

  /// Whether to remove this from keyboard traversal while still focusable
  /// programmatically.
  final bool excludeFromTraversal;

  @override
  State<CairnInteractive> createState() => _CairnInteractiveState();
}

class _CairnInteractiveState extends State<CairnInteractive> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());

  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  /// True when the in-flight focus change originated from a pointer press.
  ///
  /// A mouse press focuses the control, but CSS `:focus-visible` deliberately
  /// stays off in that case. Tracking the cause of the focus change is the only
  /// way to reproduce that.
  bool _focusFromPointer = false;

  late FocusHighlightMode _highlightMode;

  @override
  void initState() {
    super.initState();
    _highlightMode = FocusManager.instance.highlightMode;
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChange);
    _internalNode?.dispose();
    super.dispose();
  }

  void _onHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted || mode == _highlightMode) return;
    setState(() => _highlightMode = mode);
  }

  /// `:focus-visible` — focused, using a traditional (keyboard/mouse) pointer
  /// paradigm, and not focused merely because it was clicked.
  bool get _focusVisible =>
      _focused &&
      !_focusFromPointer &&
      _highlightMode == FocusHighlightMode.traditional;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChange?.call(value);
  }

  void _handleFocusChange(bool value) {
    if (_focused == value) return;
    setState(() {
      _focused = value;
      if (!value) _focusFromPointer = false;
    });
    widget.onFocusChange?.call(value);
  }

  void _handleTapDown(TapDownDetails _) {
    _focusFromPointer = true;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_pressed) setState(() => _pressed = false);
  }

  void _handleTapCancel() {
    if (_pressed) setState(() => _pressed = false);
    _focusFromPointer = false;
  }

  void _handleTap() {
    if (!widget.enabled) return;
    if (widget.canRequestFocus && !_node.hasFocus) {
      _focusFromPointer = true;
      _node.requestFocus();
    }
    widget.onTap?.call();
  }

  /// Keyboard activation. Unlike a tap, this must show the focus ring.
  void _handleActivate() {
    if (!widget.enabled) return;
    _focusFromPointer = false;
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final CairnStates states = CairnStates(
      hovered: enabled && _hovered,
      focused: enabled && _focusVisible,
      pressed: enabled && _pressed,
      disabled: !enabled,
    );

    Widget child = widget.builder(context, states);

    // `disabled:pointer-events-none` takes the element *and its descendants*
    // out of hit testing. Without this an interactive child inside a disabled
    // control would still receive taps, which CSS would not allow.
    if (!enabled) {
      child = IgnorePointer(child: child);
    }

    child = MouseRegion(
      cursor:
          widget.mouseCursor ??
          (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
      onEnter: enabled ? (_) => _setHovered(true) : null,
      onExit: (_) => _setHovered(false),
      child: child,
    );

    child = GestureDetector(
      behavior: widget.behavior,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: enabled ? _handleTap : null,
      onLongPress: enabled ? widget.onLongPress : null,
      child: child,
    );

    child = FocusableActionDetector(
      focusNode: _node,
      autofocus: widget.autofocus,
      enabled: enabled && widget.canRequestFocus,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      includeFocusSemantics: false,
      mouseCursor: MouseCursor.defer,
      onFocusChange: _handleFocusChange,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _handleActivate();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) {
            _handleActivate();
            return null;
          },
        ),
      },
      child: child,
    );

    if (widget.excludeFromTraversal) {
      child = ExcludeFocusTraversal(child: child);
    }

    if (widget.includeSemantics) {
      child = Semantics(
        container: true,
        button: widget.isButton,
        enabled: enabled,
        focusable: enabled && widget.canRequestFocus,
        focused: _focused,
        label: widget.semanticLabel,
        onTap: enabled ? _handleActivate : null,
        child: child,
      );
    }

    return child;
  }
}

/// Removes a subtree from keyboard traversal without making it unfocusable.
class ExcludeFocusTraversal extends StatelessWidget {
  /// Creates a traversal-excluding wrapper.
  const ExcludeFocusTraversal({super.key, required this.child});

  /// The subtree to exclude.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ExcludeFocus(excluding: false, child: child);
}

/// A [MouseCursor] helper matching `disabled:cursor-not-allowed`.
abstract final class CairnCursors {
  /// The cursor for interactive, enabled controls.
  static const MouseCursor interactive = SystemMouseCursors.click;

  /// `disabled:cursor-not-allowed`.
  static const MouseCursor disabled = SystemMouseCursors.forbidden;

  /// `cursor-default` — used by menu items, which Radix marks
  /// `cursor-default` rather than `cursor-pointer`.
  static const MouseCursor menuItem = SystemMouseCursors.basic;

  /// `cursor-text` for text inputs.
  static const MouseCursor text = SystemMouseCursors.text;

  /// Picks a cursor from an enabled flag.
  static MouseCursor forEnabled(bool enabled, {MouseCursor? whenEnabled}) =>
      enabled ? (whenEnabled ?? interactive) : disabled;
}
