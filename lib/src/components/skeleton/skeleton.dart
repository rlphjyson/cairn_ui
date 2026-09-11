import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';

/// A loading placeholder.
///
/// `animate-pulse rounded-md bg-accent`.
///
/// Tailwind's `animate-pulse` keyframes run `opacity: 1 -> .5 -> 1` over two
/// seconds with `cubic-bezier(0.4, 0, 0.6, 1)`. This reproduces that curve
/// rather than using a shimmer, because a shimmer is a different effect that
/// would not match.
///
/// Respects [MediaQueryData.disableAnimations], so users who have asked their
/// platform to reduce motion get a static placeholder.
///
/// ```dart
/// const CairnSkeleton(width: 200, height: 16);
/// const CairnSkeleton.circle(size: 40);
/// ```
class CairnSkeleton extends StatefulWidget {
  /// Creates a rectangular skeleton.
  const CairnSkeleton({super.key, this.width, this.height, this.borderRadius})
    : _circle = false;

  /// Creates a circular skeleton, for avatar placeholders.
  const CairnSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null,
      _circle = true;

  /// The width. Null fills the available width.
  final double? width;

  /// The height.
  final double? height;

  /// Overrides `rounded-md`.
  final BorderRadius? borderRadius;

  final bool _circle;

  @override
  State<CairnSkeleton> createState() => _CairnSkeletonState();
}

class _CairnSkeletonState extends State<CairnSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CairnMotion.pulse,
  );

  late final Animation<double> _opacity = Tween<double>(begin: 1.0, end: 0.5)
      .animate(
        CurvedAnimation(
          parent: _controller,
          // Tailwind's `animate-pulse` easing.
          curve: const Cubic(0.4, 0.0, 0.6, 1.0),
        ),
      );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion && _controller.isAnimating) {
      _controller.stop();
    } else if (!reduceMotion && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }

    final Widget box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.accent,
        shape: widget._circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget._circle
            ? null
            : (widget.borderRadius ??
                  BorderRadius.circular(theme.radiusScale.md)),
      ),
    );

    if (reduceMotion) return ExcludeSemantics(child: box);

    return ExcludeSemantics(
      child: FadeTransition(opacity: _opacity, child: box),
    );
  }
}
