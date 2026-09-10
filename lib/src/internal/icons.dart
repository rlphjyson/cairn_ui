import 'package:flutter/widgets.dart';

/// The glyphs Cairn draws internally.
///
/// shadcn/ui uses `lucide-react` for every icon inside a component (the check
/// in a Checkbox, the chevron in a Select trigger, the X on a Dialog). Cairn
/// redraws the handful it needs rather than taking a dependency or bundling an
/// icon font, so the package stays pure Dart with no assets.
///
/// Geometry follows Lucide's own source: a 24x24 view box, 2px stroke, round
/// caps and round joins. [CairnIcon] scales that to the requested size, so a
/// 16px icon (shadcn/ui's `size-4` default) draws a 1.33px stroke exactly as
/// the browser would.
enum CairnIconData {
  /// Lucide `check` — the Checkbox indicator and selected menu items.
  check,

  /// Lucide `chevron-down` — Select and Accordion triggers.
  chevronDown,

  /// Lucide `chevron-up` — Select scroll-up button.
  chevronUp,

  /// Lucide `chevron-left` — Pagination and Calendar previous.
  chevronLeft,

  /// Lucide `chevron-right` — submenu triggers, Breadcrumb separators.
  chevronRight,

  /// Lucide `chevrons-up-down` — the Combobox trigger.
  chevronsUpDown,

  /// Lucide `x` — Dialog and Sheet close buttons.
  close,

  /// Lucide `circle` (filled) — the Radio Group indicator.
  dot,

  /// Lucide `search` — the Command palette input.
  search,

  /// Lucide `minus` — the indeterminate Checkbox state.
  minus,

  /// Lucide `more-horizontal` — Breadcrumb and Pagination ellipsis.
  moreHorizontal,

  /// Lucide `arrow-up` — ascending sort in a Data Table header.
  arrowUp,

  /// Lucide `arrow-down` — descending sort in a Data Table header.
  arrowDown,

  /// Lucide `chevrons-left` — first page.
  chevronsLeft,

  /// Lucide `chevrons-right` — last page.
  chevronsRight,

  /// Lucide `circle-alert` — the destructive Alert.
  alert,

  /// Lucide `circle-check` — a success Toast.
  circleCheck,

  /// Lucide `info` — an informational Toast.
  info,
}

/// Draws one of Cairn's built-in [CairnIconData] glyphs.
///
/// Defaults to 16 logical pixels (shadcn/ui's `size-4`) and inherits its colour
/// from the ambient [IconTheme] when [color] is null, so it behaves like a
/// normal Flutter [Icon] inside buttons and menu items.
class CairnIcon extends StatelessWidget {
  /// Creates an icon.
  const CairnIcon(this.icon, {super.key, this.size = 16.0, this.color});

  /// Which glyph to draw.
  final CairnIconData icon;

  /// The width and height in logical pixels.
  final double size;

  /// The stroke colour. Falls back to the ambient [IconTheme].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final Color resolved =
        color ?? iconTheme.color ?? const Color(0xFF000000);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CairnIconPainter(icon: icon, color: resolved),
        isComplex: false,
      ),
    );
  }
}

/// Paints a Lucide glyph scaled from its native 24x24 grid.
class _CairnIconPainter extends CustomPainter {
  const _CairnIconPainter({required this.icon, required this.color});

  final CairnIconData icon;
  final Color color;

  /// Lucide authors every icon on a 24x24 view box.
  static const double _viewBox = 24.0;

  /// Lucide's default `stroke-width`.
  static const double _strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _viewBox;
    canvas.save();
    canvas.scale(scale);

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final Paint fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (icon) {
      case CairnIconData.check:
        canvas.drawPath(_poly(<Offset>[
          const Offset(20, 6),
          const Offset(9, 17),
          const Offset(4, 12),
        ]), stroke);

      case CairnIconData.chevronDown:
        canvas.drawPath(_poly(<Offset>[
          const Offset(6, 9),
          const Offset(12, 15),
          const Offset(18, 9),
        ]), stroke);

      case CairnIconData.chevronUp:
        canvas.drawPath(_poly(<Offset>[
          const Offset(18, 15),
          const Offset(12, 9),
          const Offset(6, 15),
        ]), stroke);

      case CairnIconData.chevronLeft:
        canvas.drawPath(_poly(<Offset>[
          const Offset(15, 18),
          const Offset(9, 12),
          const Offset(15, 6),
        ]), stroke);

      case CairnIconData.chevronRight:
        canvas.drawPath(_poly(<Offset>[
          const Offset(9, 18),
          const Offset(15, 12),
          const Offset(9, 6),
        ]), stroke);

      case CairnIconData.chevronsUpDown:
        canvas
          ..drawPath(_poly(<Offset>[
            const Offset(7, 15),
            const Offset(12, 20),
            const Offset(17, 15),
          ]), stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(7, 9),
            const Offset(12, 4),
            const Offset(17, 9),
          ]), stroke);

      case CairnIconData.chevronsLeft:
        canvas
          ..drawPath(_poly(<Offset>[
            const Offset(11, 17),
            const Offset(6, 12),
            const Offset(11, 7),
          ]), stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(18, 17),
            const Offset(13, 12),
            const Offset(18, 7),
          ]), stroke);

      case CairnIconData.chevronsRight:
        canvas
          ..drawPath(_poly(<Offset>[
            const Offset(6, 17),
            const Offset(11, 12),
            const Offset(6, 7),
          ]), stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(13, 17),
            const Offset(18, 12),
            const Offset(13, 7),
          ]), stroke);

      case CairnIconData.close:
        canvas
          ..drawLine(const Offset(18, 6), const Offset(6, 18), stroke)
          ..drawLine(const Offset(6, 6), const Offset(18, 18), stroke);

      case CairnIconData.dot:
        // The Radio indicator is a filled circle, `size-2 fill-primary`.
        canvas.drawCircle(const Offset(12, 12), 10, fill);

      case CairnIconData.minus:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);

      case CairnIconData.search:
        canvas
          ..drawCircle(const Offset(11, 11), 8, stroke)
          ..drawLine(const Offset(21, 21), const Offset(16.65, 16.65), stroke);

      case CairnIconData.moreHorizontal:
        canvas
          ..drawCircle(const Offset(12, 12), 1, fill)
          ..drawCircle(const Offset(19, 12), 1, fill)
          ..drawCircle(const Offset(5, 12), 1, fill);

      case CairnIconData.arrowUp:
        canvas
          ..drawLine(const Offset(12, 19), const Offset(12, 5), stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(5, 12),
            const Offset(12, 5),
            const Offset(19, 12),
          ]), stroke);

      case CairnIconData.arrowDown:
        canvas
          ..drawLine(const Offset(12, 5), const Offset(12, 19), stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(19, 12),
            const Offset(12, 19),
            const Offset(5, 12),
          ]), stroke);

      case CairnIconData.alert:
        canvas
          ..drawCircle(const Offset(12, 12), 10, stroke)
          ..drawLine(const Offset(12, 8), const Offset(12, 12), stroke)
          ..drawLine(const Offset(12, 16), const Offset(12.01, 16), stroke);

      case CairnIconData.circleCheck:
        canvas
          ..drawCircle(const Offset(12, 12), 10, stroke)
          ..drawPath(_poly(<Offset>[
            const Offset(9, 12),
            const Offset(11, 14),
            const Offset(15, 10),
          ]), stroke);

      case CairnIconData.info:
        canvas
          ..drawCircle(const Offset(12, 12), 10, stroke)
          ..drawLine(const Offset(12, 16), const Offset(12, 12), stroke)
          ..drawLine(const Offset(12, 8), const Offset(12.01, 8), stroke);
    }

    canvas.restore();
  }

  /// Builds an open polyline through [points].
  static Path _poly(List<Offset> points) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_CairnIconPainter oldDelegate) =>
      oldDelegate.icon != icon || oldDelegate.color != color;
}
