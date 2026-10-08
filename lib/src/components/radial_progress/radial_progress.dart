import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/tones.dart';
import '../../tokens/typography.dart';

/// A circular progress indicator with room for a value in the middle.
///
/// The ring analogue of [CairnProgress]: the track is the indicator colour at
/// 20% alpha and the arc is the full colour, so the two halves read as one
/// object at two strengths. The arc starts at twelve o'clock, runs clockwise,
/// has round caps, and animates between values at 300ms on the standard curve.
///
/// [child] is centred inside the ring; when omitted and [showValue] is true the
/// percentage is drawn there.
///
/// ```dart
/// const CairnRadialProgress(value: 0.7, showValue: true);
/// ```
class CairnRadialProgress extends StatelessWidget {
  /// Creates a radial progress indicator.
  const CairnRadialProgress({
    super.key,
    required this.value,
    this.size = 64.0,
    this.thickness = 6.0,
    this.tone = CairnTone.primary,
    this.showValue = false,
    this.child,
    this.semanticLabel,
  }) : assert(value >= 0.0 && value <= 1.0, 'value must be between 0 and 1');

  /// Progress from 0 to 1.
  final double value;

  /// The outer diameter.
  final double size;

  /// The ring thickness.
  final double thickness;

  /// The colour intent.
  final CairnTone tone;

  /// Whether to draw the percentage in the centre when [child] is null.
  final bool showValue;

  /// Centre content.
  final Widget? child;

  /// The accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = CairnToneColors.resolve(theme, tone).fill;

    final Widget? center =
        child ??
        (showValue
            ? Text(
                '${(value * 100).round()}%',
                style: theme
                    .textStyle(CairnTypography.sm)
                    .copyWith(
                      fontWeight: CairnTypography.medium,
                      color: theme.foreground,
                    ),
              )
            : null);

    return Semantics(
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value),
          duration: CairnMotion.d300,
          curve: CairnMotion.standard,
          builder: (BuildContext context, double animated, Widget? _) =>
              CustomPaint(
                painter: _RingPainter(
                  value: animated,
                  thickness: thickness,
                  color: color,
                ),
                child: Center(child: center),
              ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.thickness,
    required this.color,
  });

  final double value;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Rect arc = rect.deflate(thickness / 2);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = color.withValues(alpha: 0.2);
    canvas.drawArc(arc, 0, math.pi * 2, false, track);

    if (value <= 0) return;
    final Paint indicator = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value, false, indicator);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.thickness != thickness || old.color != color;
}
