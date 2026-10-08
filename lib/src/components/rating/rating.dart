import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/tones.dart';

/// A star rating input and display.
///
/// A row of 20px stars with a 2px gap. Filled stars take the [tone] colour
/// (amber by default, the conventional star colour) and empty ones the
/// `border` token's stroke. With [onChanged] null the rating is read-only —
/// no hover, no focus, no cursor change — which is the right default for
/// showing an aggregate score.
///
/// Fractional [value]s (a 3.5 average) paint a half star. The input itself
/// only produces whole values, or halves when [allowHalf] is set.
///
/// Keyboard: arrow keys step the value by one (or a half), Home and End jump
/// to zero and [count].
///
/// ```dart
/// CairnRating(value: _stars, onChanged: (v) => setState(() => _stars = v));
/// ```
class CairnRating extends StatefulWidget {
  /// Creates a rating.
  const CairnRating({
    super.key,
    required this.value,
    this.onChanged,
    this.count = 5,
    this.size = 20.0,
    this.allowHalf = false,
    this.tone = CairnTone.warning,
    this.semanticLabel = 'Rating',
  }) : assert(count > 0, 'count must be positive');

  /// The current rating, from 0 to [count].
  final double value;

  /// Called with the new rating. Null makes the rating read-only.
  final ValueChanged<double>? onChanged;

  /// How many stars.
  final int count;

  /// The star size.
  final double size;

  /// Whether the input can produce half-star values.
  final bool allowHalf;

  /// The filled-star colour.
  final CairnTone tone;

  /// The accessible name.
  final String semanticLabel;

  @override
  State<CairnRating> createState() => _CairnRatingState();
}

class _CairnRatingState extends State<CairnRating> {
  double? _hover;
  late final FocusNode _focus = FocusNode(debugLabel: 'CairnRating');

  static const double _gap = 2.0;

  bool get _interactive => widget.onChanged != null;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  double _valueAt(double dx) {
    final double slot = widget.size + _gap;
    final int index = (dx / slot).floor().clamp(0, widget.count - 1);
    if (!widget.allowHalf) return index + 1.0;
    final double within = dx - index * slot;
    return index + (within < widget.size / 2 ? 0.5 : 1.0);
  }

  void _set(double v) {
    final double next = v.clamp(0.0, widget.count.toDouble());
    if (next != widget.value) widget.onChanged?.call(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || !_interactive) return KeyEventResult.ignored;
    final double step = widget.allowHalf ? 0.5 : 1.0;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp) {
      _set(widget.value + step);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown) {
      _set(widget.value - step);
    } else if (key == LogicalKeyboardKey.home) {
      _set(0);
    } else if (key == LogicalKeyboardKey.end) {
      _set(widget.count.toDouble());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color fill = CairnToneColors.resolve(theme, widget.tone).fill;
    final double shown = _hover ?? widget.value;
    final double width = widget.count * widget.size + (widget.count - 1) * _gap;

    Widget stars = SizedBox(
      width: width,
      height: widget.size,
      child: CustomPaint(
        painter: _StarsPainter(
          value: shown,
          count: widget.count,
          size: widget.size,
          gap: _gap,
          fill: fill,
          empty: theme.input,
        ),
      ),
    );

    if (_interactive) {
      stars = Focus(
        focusNode: _focus,
        onKeyEvent: _onKey,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (PointerHoverEvent e) =>
              setState(() => _hover = _valueAt(e.localPosition.dx)),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails d) {
              _focus.requestFocus();
              _set(_valueAt(d.localPosition.dx));
            },
            child: stars,
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel,
      value: '${widget.value} of ${widget.count}',
      slider: _interactive,
      increasedValue: _interactive
          ? '${math.min(widget.value + 1, widget.count)}'
          : null,
      decreasedValue: _interactive ? '${math.max(widget.value - 1, 0)}' : null,
      onIncrease: _interactive
          ? () => _set(widget.value + (widget.allowHalf ? 0.5 : 1.0))
          : null,
      onDecrease: _interactive
          ? () => _set(widget.value - (widget.allowHalf ? 0.5 : 1.0))
          : null,
      child: stars,
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter({
    required this.value,
    required this.count,
    required this.size,
    required this.gap,
    required this.fill,
    required this.empty,
  });

  final double value;
  final int count;
  final double size;
  final double gap;
  final Color fill;
  final Color empty;

  /// A five-point star in a unit box.
  static Path _star(double s) {
    final Path p = Path();
    const int points = 5;
    final double outer = s / 2;
    final double inner = outer * 0.42;
    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? outer : inner;
      final double a = -math.pi / 2 + i * math.pi / points;
      final double x = outer + r * math.cos(a);
      final double y = outer + r * math.sin(a) + s * 0.03;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Path star = _star(size);
    final Paint emptyPaint = Paint()
      ..color = empty
      ..style = PaintingStyle.fill;
    final Paint fillPaint = Paint()..color = fill;

    for (int i = 0; i < count; i++) {
      canvas.save();
      canvas.translate(i * (size + gap), 0);
      canvas.drawPath(star, emptyPaint);
      final double portion = (value - i).clamp(0.0, 1.0);
      if (portion > 0) {
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0, 0, size * portion, size));
        canvas.drawPath(star, fillPaint);
        canvas.restore();
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.value != value ||
      old.count != count ||
      old.size != size ||
      old.fill != fill ||
      old.empty != empty;
}
