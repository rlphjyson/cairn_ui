import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';

/// A scroll container with a slim styled scrollbar, matching shadcn/ui's
/// `ScrollArea`.
///
/// The scrollbar track is `w-2.5` (10 logical pixels) with `p-px` padding and
/// the thumb is `rounded-full bg-border` — noticeably slimmer and quieter than
/// a platform scrollbar, which is the point of the component.
///
/// Radix renders a custom scrollbar because browsers historically could not
/// style native ones. Flutter *can* style [Scrollbar], so this configures the
/// framework's rather than reimplementing scrolling — reimplementing would give
/// up momentum physics, trackpad handling and accessibility for no visual gain.
///
/// ```dart
/// CairnScrollArea(
///   height: 200,
///   child: Column(children: items),
/// );
/// ```
class CairnScrollArea extends StatefulWidget {
  /// Creates a scroll area.
  const CairnScrollArea({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.axis = Axis.vertical,
    this.padding,
    this.alwaysVisible = false,
  });

  /// The scrollable content.
  final Widget child;

  /// An optional fixed height.
  final double? height;

  /// An optional fixed width.
  final double? width;

  /// The scroll direction.
  final Axis axis;

  /// Padding applied inside the scroll view.
  final EdgeInsetsGeometry? padding;

  /// Whether the scrollbar stays visible rather than fading out.
  final bool alwaysVisible;

  @override
  State<CairnScrollArea> createState() => _CairnScrollAreaState();
}

class _CairnScrollAreaState extends State<CairnScrollArea> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// `w-2.5` minus the `p-px` on each side.
  static const double _trackWidth = 10.0;
  static const double _thumbWidth = 8.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ScrollConfiguration(
        // Suppress the platform's own overscroll glow; shadcn/ui has none.
        behavior: const _NoGlowBehavior(),
        child: RawScrollbar(
          controller: _controller,
          thumbVisibility: widget.alwaysVisible,
          thickness: _thumbWidth,
          radius: const Radius.circular(9999),
          // `bg-border` — the thumb is the border token, not a platform grey.
          thumbColor: theme.border,
          // A 1px inset reproduces the track's `p-px`.
          crossAxisMargin: (_trackWidth - _thumbWidth) / 2,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: widget.axis,
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Removes the platform overscroll indicator.
class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
