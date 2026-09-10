import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/shadows.dart';

/// A value slider matching shadcn/ui's `Slider`.
///
/// The track is `h-1.5 rounded-full bg-muted` (6 logical pixels), the filled
/// range is `bg-primary`, and the thumb is `size-4 rounded-full border
/// border-primary bg-white shadow-sm` — 16 logical pixels.
///
/// The thumb's fill is a literal `bg-white`, **not** a token, so it stays white
/// in dark mode too. That is easy to get wrong by reflexively mapping it to
/// `--background`, which would turn it near-black on a dark page.
///
/// Hover and keyboard focus both grow a `ring-4` (4px) halo at `ring-ring/50`
/// — note this is 4px, not the 3px ring the rest of the library uses.
///
/// ## Accessibility
///
/// Arrow keys move by [step], Home and End jump to the bounds, and the
/// [Semantics] node exposes increase/decrease actions so screen readers can
/// drive it.
///
/// ```dart
/// CairnSlider(
///   value: volume,
///   onChanged: (v) => setState(() => volume = v),
/// );
/// ```
class CairnSlider extends StatefulWidget {
  /// Creates a slider.
  const CairnSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.step,
    this.focusNode,
    this.semanticLabel,
  }) : assert(min < max, 'min must be less than max');

  /// The current value, between [min] and [max].
  final double value;

  /// Called continuously as the user drags. Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called once when a drag or keyboard interaction finishes.
  final ValueChanged<double>? onChangeEnd;

  /// The lower bound.
  final double min;

  /// The upper bound.
  final double max;

  /// The increment for arrow keys and drag snapping. Null means continuous,
  /// with arrow keys moving by 1% of the range.
  final double? step;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// The accessible name.
  final String? semanticLabel;

  /// `h-1.5`.
  static const double trackHeight = 6.0;

  /// `size-4`.
  static const double thumbSize = 16.0;

  /// `hover:ring-4` / `focus-visible:ring-4` — wider than the usual 3px.
  static const double ringWidth = 4.0;

  @override
  State<CairnSlider> createState() => _CairnSliderState();
}

class _CairnSliderState extends State<CairnSlider> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());
  bool _hovered = false;
  bool _focused = false;
  bool _dragging = false;

  bool get _enabled => widget.onChanged != null;

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double get _stepSize => widget.step ?? (widget.max - widget.min) / 100.0;

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  void _emit(double raw, {bool end = false}) {
    double next = raw.clamp(widget.min, widget.max);
    if (widget.step != null) {
      final double steps = ((next - widget.min) / widget.step!).roundToDouble();
      next = (widget.min + steps * widget.step!).clamp(widget.min, widget.max);
    }
    widget.onChanged?.call(next);
    if (end) widget.onChangeEnd?.call(next);
  }

  void _updateFromPosition(double dx, double width) {
    final double usable = width - CairnSlider.thumbSize;
    if (usable <= 0) return;
    final double fraction = ((dx - CairnSlider.thumbSize / 2) / usable).clamp(
      0.0,
      1.0,
    );
    _emit(widget.min + fraction * (widget.max - widget.min));
  }

  void _nudge(double direction) =>
      _emit(widget.value + direction * _stepSize, end: true);

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool showRing = _enabled && (_hovered || _focused || _dragging);

    return Semantics(
      slider: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      value: '${(_fraction * 100).round()}%',
      onIncrease: _enabled ? () => _nudge(1) : null,
      onDecrease: _enabled ? () => _nudge(-1) : null,
      child: FocusableActionDetector(
        focusNode: _node,
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (bool v) => setState(() => _hovered = v),
        onFocusChange: (bool v) => setState(() => _focused = v),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _AdjustIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _AdjustIntent(1),
          SingleActivator(LogicalKeyboardKey.home): _BoundIntent(false),
          SingleActivator(LogicalKeyboardKey.end): _BoundIntent(true),
        },
        actions: <Type, Action<Intent>>{
          _AdjustIntent: CallbackAction<_AdjustIntent>(
            onInvoke: (_AdjustIntent intent) {
              _nudge(intent.direction.toDouble());
              return null;
            },
          ),
          _BoundIntent: CallbackAction<_BoundIntent>(
            onInvoke: (_BoundIntent intent) {
              _emit(intent.upper ? widget.max : widget.min, end: true);
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _enabled
                  ? (TapDownDetails d) =>
                        _updateFromPosition(d.localPosition.dx, width)
                  : null,
              onHorizontalDragStart: _enabled
                  ? (DragStartDetails d) {
                      setState(() => _dragging = true);
                      _updateFromPosition(d.localPosition.dx, width);
                    }
                  : null,
              onHorizontalDragUpdate: _enabled
                  ? (DragUpdateDetails d) =>
                        _updateFromPosition(d.localPosition.dx, width)
                  : null,
              onHorizontalDragEnd: _enabled
                  ? (DragEndDetails d) {
                      setState(() => _dragging = false);
                      widget.onChangeEnd?.call(widget.value);
                    }
                  : null,
              child: Opacity(
                opacity: _enabled ? 1.0 : 0.5,
                child: SizedBox(
                  height: CairnSlider.thumbSize + CairnSlider.ringWidth * 2,
                  width: width,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      // Track, inset by half a thumb at each end so the thumb
                      // centre reaches exactly min and max.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CairnSlider.thumbSize / 2,
                        ),
                        child: ClipRRect(
                          borderRadius: CairnRadius.brFull,
                          child: SizedBox(
                            height: CairnSlider.trackHeight,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: ColoredBox(color: theme.muted),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _fraction,
                                  heightFactor: 1.0,
                                  child: ColoredBox(color: theme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left:
                            _fraction *
                            (width - CairnSlider.thumbSize).clamp(
                              0.0,
                              double.infinity,
                            ),
                        child: Container(
                          width: CairnSlider.thumbSize,
                          height: CairnSlider.thumbSize,
                          decoration: BoxDecoration(
                            // A literal bg-white in both themes.
                            color: CairnColors.white,
                            borderRadius: CairnRadius.brFull,
                            border: Border.all(color: theme.primary),
                            boxShadow: <BoxShadow>[
                              ...CairnShadows.sm,
                              if (showRing)
                                BoxShadow(
                                  color: theme.ringMuted,
                                  spreadRadius: CairnSlider.ringWidth,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Moves the slider by one step in [direction].
class _AdjustIntent extends Intent {
  const _AdjustIntent(this.direction);

  final int direction;
}

/// Jumps the slider to a bound.
class _BoundIntent extends Intent {
  const _BoundIntent(this.upper);

  final bool upper;
}
