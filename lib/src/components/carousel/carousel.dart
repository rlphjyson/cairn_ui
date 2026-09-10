import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../button/button.dart';

/// A horizontally paged content strip matching shadcn/ui's `Carousel`.
///
/// shadcn/ui wraps Embla Carousel and adds two `size-8 rounded-full` outline
/// buttons positioned outside the viewport edges (`-left-12` / `-right-12`),
/// which is why a shadcn carousel needs horizontal room around it.
///
/// Cairn drives the strip with a [PageView] rather than porting Embla — the
/// scroll physics, drag handling and page snapping are already correct in
/// Flutter, and the component's identity lives in its chrome and metrics.
///
/// ```dart
/// CairnCarousel(
///   height: 200,
///   items: [for (final image in images) Image.network(image)],
/// );
/// ```
class CairnCarousel extends StatefulWidget {
  /// Creates a carousel.
  const CairnCarousel({
    super.key,
    required this.items,
    this.height = 200.0,
    this.viewportFraction = 1.0,
    this.spacing = CairnSpacing.s4,
    this.showControls = true,
    this.showIndicators = true,
    this.onPageChanged,
  });

  /// The slides.
  final List<Widget> items;

  /// The strip height.
  final double height;

  /// How much of the viewport one slide occupies. Below 1.0 the neighbouring
  /// slides peek in, which Embla calls a "partial" slide.
  final double viewportFraction;

  /// The gap between slides (`pl-4` on each item in shadcn/ui).
  final double spacing;

  /// Whether to show the previous/next buttons.
  final bool showControls;

  /// Whether to show the dot indicators.
  final bool showIndicators;

  /// Called when the visible page changes.
  final ValueChanged<int>? onPageChanged;

  @override
  State<CairnCarousel> createState() => _CairnCarouselState();
}

class _CairnCarouselState extends State<CairnCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
  );
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canPrev => _page > 0;
  bool get _canNext => _page < widget.items.length - 1;

  Future<void> _go(int delta) => _controller.animateToPage(
    (_page + delta).clamp(0, widget.items.length - 1),
    duration: CairnMotion.d300,
    curve: CairnMotion.standard,
  );

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (widget.showControls)
              CairnButton.icon(
                icon: const CairnIcon(CairnIconData.chevronLeft),
                semanticLabel: 'Previous slide',
                variant: CairnButtonVariant.outline,
                size: CairnButtonSize.iconSm,
                onPressed: _canPrev ? () => _go(-1).ignore() : null,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.showControls ? widget.spacing : 0,
                ),
                child: SizedBox(
                  height: widget.height,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: widget.items.length,
                    onPageChanged: (int p) {
                      setState(() => _page = p);
                      widget.onPageChanged?.call(p);
                    },
                    itemBuilder: (BuildContext context, int i) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.viewportFraction < 1.0
                            ? widget.spacing / 2
                            : 0,
                      ),
                      child: widget.items[i],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showControls)
              CairnButton.icon(
                icon: const CairnIcon(CairnIconData.chevronRight),
                semanticLabel: 'Next slide',
                variant: CairnButtonVariant.outline,
                size: CairnButtonSize.iconSm,
                onPressed: _canNext ? () => _go(1).ignore() : null,
              ),
          ],
        ),
        if (widget.showIndicators) ...<Widget>[
          const SizedBox(height: CairnSpacing.s4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              for (int i = 0; i < widget.items.length; i++)
                AnimatedContainer(
                  duration: CairnMotion.d200,
                  curve: CairnMotion.standard,
                  width: i == _page ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? theme.primary : theme.muted,
                    borderRadius: CairnRadius.brFull,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
