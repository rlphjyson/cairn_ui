import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';

/// A before/after comparison with a draggable divider.
///
/// Two widgets are stacked at the same size; [after] is clipped to the right of
/// a divider that the user drags (or moves with the arrow keys) to reveal more
/// of [before] or [after]. Useful for image edits, design reviews and theme
/// comparisons.
///
/// The divider is a 1px [CairnTheme.border]-strength line carrying a 32px round
/// grip with chevrons, and has a 44px-wide hit area so it stays easy to catch
/// on touch. The comparison fills the width it is given; give it an
/// [aspectRatio] (or wrap it in a sized box) to fix the height.
///
/// ```dart
/// CairnDiff(
///   aspectRatio: 16 / 9,
///   before: Image.asset('before.png', fit: BoxFit.cover),
///   after: Image.asset('after.png', fit: BoxFit.cover),
/// );
/// ```
class CairnDiff extends StatefulWidget {
  /// Creates a diff.
  const CairnDiff({
    super.key,
    required this.before,
    required this.after,
    this.initialPosition = 0.5,
    this.aspectRatio,
    this.onChanged,
    this.semanticLabel = 'Comparison divider',
  }) : assert(
         initialPosition >= 0.0 && initialPosition <= 1.0,
         'initialPosition must be between 0 and 1',
       );

  /// Shown on the left of the divider.
  final Widget before;

  /// Shown on the right of the divider.
  final Widget after;

  /// The divider's starting position as a fraction of the width.
  final double initialPosition;

  /// Fixes the height as width / ratio. Null lets the parent decide.
  final double? aspectRatio;

  /// Called as the divider moves.
  final ValueChanged<double>? onChanged;

  /// The accessible name of the divider.
  final String semanticLabel;

  @override
  State<CairnDiff> createState() => _CairnDiffState();
}

class _CairnDiffState extends State<CairnDiff> {
  late double _position = widget.initialPosition;
  final FocusNode _focus = FocusNode(debugLabel: 'CairnDiff');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  static const double _hit = 44.0;
  static const double _grip = 32.0;
  static const double _keyStep = 0.05;

  void _set(double v) {
    final double next = v.clamp(0.0, 1.0);
    if (next == _position) return;
    setState(() => _position = next);
    widget.onChanged?.call(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _set(_position - _keyStep);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _set(_position + _keyStep);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      _set(0);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      _set(1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    Widget body = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double x = width * _position;

        return ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              widget.before,
              ClipRect(clipper: _RightOf(x), child: widget.after),
              Positioned(
                left: x - _hit / 2,
                width: _hit,
                top: 0,
                bottom: 0,
                child: Focus(
                  focusNode: _focus,
                  onKeyEvent: _onKey,
                  child: Semantics(
                    label: widget.semanticLabel,
                    slider: true,
                    value: '${(_position * 100).round()}%',
                    increasedValue:
                        '${((_position + _keyStep).clamp(0.0, 1.0) * 100).round()}%',
                    decreasedValue:
                        '${((_position - _keyStep).clamp(0.0, 1.0) * 100).round()}%',
                    onIncrease: () => _set(_position + _keyStep),
                    onDecrease: () => _set(_position - _keyStep),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (DragUpdateDetails d) =>
                            _set(_position + d.delta.dx / width),
                        onTapDown: (TapDownDetails d) {
                          _focus.requestFocus();
                          _set((x - _hit / 2 + d.localPosition.dx) / width);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(width: 1, color: theme.border),
                            Container(
                              width: _grip,
                              height: _grip,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.background,
                                border: Border.all(color: theme.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CairnIcon(
                                    CairnIconData.chevronLeft,
                                    size: 12,
                                    color: theme.foreground,
                                  ),
                                  CairnIcon(
                                    CairnIconData.chevronRight,
                                    size: 12,
                                    color: theme.foreground,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (widget.aspectRatio != null) {
      body = AspectRatio(aspectRatio: widget.aspectRatio!, child: body);
    }
    return body;
  }
}

class _RightOf extends CustomClipper<Rect> {
  const _RightOf(this.x);

  final double x;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(x, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightOf old) => old.x != x;
}
