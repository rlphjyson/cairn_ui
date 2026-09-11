import 'package:flutter/widgets.dart';

/// Draws box shadows **outside** a rounded rectangle only, the way CSS does.
///
/// ## The problem this solves
///
/// CSS and Flutter disagree about where an outer box-shadow is allowed to
/// paint. CSS clips an outer `box-shadow` to the area *outside* the border box
/// — the shadow is never visible through the element, even when the element is
/// fully transparent. Flutter's [BoxDecoration.boxShadow] has no such clip: it
/// paints a blurred, filled copy of the shape behind the box, so any part of
/// the box that is not opaque lets the shadow show through.
///
/// That difference is invisible on an opaque component and very visible on a
/// transparent one, which is most of shadcn/ui's form controls:
///
/// * `Input`, `Textarea`, `Select`, `Combobox` and the Date Picker trigger are
///   all `bg-transparent shadow-xs` in light mode. Flutter renders the 5%-black
///   `shadow-xs` straight through the middle, turning a white field a dirty
///   grey.
/// * The focus ring is worse. `focus-visible:ring-[3px] ring-ring/50` compiles
///   to `box-shadow: 0 0 0 3px`, i.e. a hard unblurred ring. Painted the
///   Flutter way behind a transparent control it fills the entire control with
///   50%-alpha ring colour instead of drawing a 3px outline.
///
/// ## How it works
///
/// The shadows are painted by a [CustomPainter] that first clips away the
/// interior of the shape, so only the part of each shadow lying outside the
/// border box survives. That reproduces CSS's clipping rule exactly, for both
/// blurred shadows and hard rings, and for negative spreads.
///
/// Use it in place of [BoxDecoration.boxShadow]:
///
/// ```dart
/// CairnShadowed(
///   shadows: CairnShadows.xs,
///   borderRadius: BorderRadius.circular(8),
///   child: Container(decoration: BoxDecoration(/* no boxShadow */)),
/// );
/// ```
class CairnShadowed extends StatelessWidget {
  /// Wraps [child] with externally-clipped [shadows].
  const CairnShadowed({
    super.key,
    required this.shadows,
    required this.borderRadius,
    required this.child,
  });

  /// The shadows to draw. An empty list skips all painting.
  final List<BoxShadow> shadows;

  /// The shape the shadows hug, and whose interior is clipped away.
  final BorderRadius borderRadius;

  /// The decorated content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (shadows.isEmpty) return child;
    return CustomPaint(
      painter: _OuterShadowPainter(
        shadows: shadows,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

/// Paints shadows clipped to the region outside the shape.
class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter({
    required this.shadows,
    required this.borderRadius,
  });

  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final RRect shape = borderRadius.toRRect(bounds);

    // How far a shadow can reach beyond the box: the largest combination of
    // offset, blur and spread across every layer. Used to bound the clip
    // region so nothing is cut off early.
    double reach = 0;
    for (final BoxShadow s in shadows) {
      final double extent =
          s.blurRadius + s.spreadRadius.abs() + s.offset.distance + 1;
      if (extent > reach) reach = extent;
    }

    final Path outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(bounds.inflate(reach)),
      // Deflate by a hair so the clip edge lands just inside the shape's
      // outline. Without it, antialiasing on the clip boundary leaves a faint
      // seam where the shadow meets the border.
      Path()..addRRect(_deflate(shape, 0.5)),
    );

    canvas.save();
    canvas.clipPath(outside);
    for (final BoxShadow shadow in shadows) {
      final RRect lit = _inflate(
        shape.shift(shadow.offset),
        shadow.spreadRadius,
      );
      canvas.drawRRect(lit, shadow.toPaint());
    }
    canvas.restore();
  }

  /// Grows an [RRect] on all sides, keeping corner radii sensible.
  ///
  /// [RRect.inflate] exists but grows the radii by the same amount, which
  /// distorts a pill. Clamping at zero keeps a negative spread (which Tailwind
  /// uses on every large shadow) from producing invalid geometry.
  static RRect _inflate(RRect r, double delta) {
    if (delta == 0) return r;
    return RRect.fromLTRBAndCorners(
      r.left - delta,
      r.top - delta,
      r.right + delta,
      r.bottom + delta,
      topLeft: _radius(r.tlRadius, delta),
      topRight: _radius(r.trRadius, delta),
      bottomLeft: _radius(r.blRadius, delta),
      bottomRight: _radius(r.brRadius, delta),
    );
  }

  static RRect _deflate(RRect r, double delta) => _inflate(r, -delta);

  static Radius _radius(Radius r, double delta) => Radius.elliptical(
    (r.x + delta).clamp(0.0, double.infinity),
    (r.y + delta).clamp(0.0, double.infinity),
  );

  @override
  bool shouldRepaint(_OuterShadowPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      !_sameShadows(oldDelegate.shadows, shadows);

  static bool _sameShadows(List<BoxShadow> a, List<BoxShadow> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
