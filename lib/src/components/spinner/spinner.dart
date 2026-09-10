import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';

/// A loading spinner matching shadcn/ui's `Spinner`.
///
/// `size-4 animate-spin` — a 16 logical pixel arc rotating once per second at
/// a linear rate, matching Tailwind's `animate-spin` keyframes exactly (a
/// constant-speed 360-degree rotation, not an eased one).
///
/// ```dart
/// const CairnSpinner();
/// CairnButton(
///   onPressed: null,
///   leading: const CairnSpinner(),
///   child: const Text('Saving'),
/// );
/// ```
class CairnSpinner extends StatefulWidget {
  /// Creates a spinner.
  const CairnSpinner({
    super.key,
    this.size = 16.0,
    this.color,
    this.strokeWidth = 2.0,
    this.semanticLabel = 'Loading',
  });

  /// The diameter (`size-4`).
  final double size;

  /// The arc colour. Defaults to the ambient text colour.
  final Color? color;

  /// The arc thickness.
  final double strokeWidth;

  /// The accessible name.
  final String semanticLabel;

  @override
  State<CairnSpinner> createState() => _CairnSpinnerState();
}

class _CairnSpinnerState extends State<CairnSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CairnMotion.spin,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color =
        widget.color ??
        DefaultTextStyle.of(context).style.color ??
        theme.foreground;

    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: RotationTransition(
          turns: _controller,
          child: CustomPaint(
            painter: _SpinnerPainter(
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the three-quarter arc Lucide's `loader-circle` uses.
class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Rect rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
