import 'package:flutter/widgets.dart';

/// Constrains a child to a fixed aspect ratio, matching shadcn/ui's
/// `AspectRatio`.
///
/// Radix's implementation is a padding-top percentage hack, which exists purely
/// because CSS had no direct way to express this before `aspect-ratio` shipped.
/// Flutter has always had [AspectRatio], so this is a thin, documented wrapper
/// that keeps the Cairn API surface complete and consistent rather than
/// reimplementing anything.
///
/// ```dart
/// CairnAspectRatio(
///   ratio: 16 / 9,
///   child: Image.network('https://example.com/cover.jpg', fit: BoxFit.cover),
/// );
/// ```
class CairnAspectRatio extends StatelessWidget {
  /// Creates an aspect-ratio box.
  const CairnAspectRatio({
    super.key,
    required this.ratio,
    required this.child,
    this.clip = true,
  }) : assert(ratio > 0, 'ratio must be positive');

  /// Width divided by height, e.g. `16 / 9`.
  final double ratio;

  /// The constrained child.
  final Widget child;

  /// Whether to clip the child to the box (`overflow-hidden`).
  final bool clip;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ratio,
    child: clip ? ClipRect(child: child) : child,
  );
}
