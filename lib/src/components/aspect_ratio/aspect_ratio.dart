import 'package:flutter/widgets.dart';

/// Constrains a child to a fixed aspect ratio.
///
/// Flutter's own [AspectRatio] already does this correctly, so this is a thin,
/// documented wrapper rather than a reimplementation — there is nothing here to
/// improve on. It exists so the Cairn surface stays complete: a
/// ratio-constrained box inside a Card is reached for by the same name as
/// everything around it.
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
