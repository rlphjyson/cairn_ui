import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../button/button.dart';

/// A horizontally paged content strip.
///
/// The previous/next controls are 32 logical pixel round outline buttons that
/// sit *outside* the viewport edges rather than floating over the content, so
/// they never cover part of a slide. The trade-off is worth stating plainly:
/// the carousel needs horizontal room around it.
///
/// The strip itself is a [PageView]. Flutter's scroll physics, drag handling
/// and page snapping are already right, and anything hand-rolled would only be
/// a worse version of them — so the component's substance is its chrome, its
/// metrics and its keyboard behaviour.
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

  /// The gap between slides, in logical pixels.
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
