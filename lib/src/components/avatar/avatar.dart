import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/typography.dart';

/// The size of a [CairnAvatar].
enum CairnAvatarSize {
  /// `size-6` — 24 logical pixels, with `text-xs` fallback text.
  sm,

  /// `size-8` — 32 logical pixels.
  md,

  /// `size-10` — 40 logical pixels.
  lg,
}

/// A user avatar matching shadcn/ui's `Avatar`.
///
/// `relative flex size-8 shrink-0 overflow-hidden rounded-full select-none`,
/// with a `bg-muted text-sm text-muted-foreground` fallback.
///
/// Radix's Avatar shows [fallback] until the image has actually loaded and
/// swaps to the image only on success — so a broken URL leaves the initials in
/// place rather than showing a broken-image box. Cairn reproduces that with
/// [Image.errorBuilder] and [Image.frameBuilder] instead of just stacking the
/// image on top of the fallback.
///
/// ```dart
/// CairnAvatar(
///   image: const NetworkImage('https://example.com/me.jpg'),
///   fallback: const Text('RJ'),
/// );
/// ```
class CairnAvatar extends StatelessWidget {
  /// Creates an avatar.
  const CairnAvatar({
    super.key,
    this.image,
    this.fallback,
    this.size = CairnAvatarSize.md,
    this.semanticLabel,
  });

  /// The avatar image. Falls back to [fallback] while loading or on error.
  final ImageProvider<Object>? image;

  /// Shown when [image] is null, still loading, or failed.
  final Widget? fallback;

  /// The size.
  final CairnAvatarSize size;

  /// The accessible name.
  final String? semanticLabel;

  /// `size-6` / `size-8` / `size-10`.
  double get _dimension => switch (size) {
    CairnAvatarSize.sm => 24.0,
    CairnAvatarSize.md => 32.0,
    CairnAvatarSize.lg => 40.0,
  };

  /// `text-xs` at sm, otherwise `text-sm`.
  TextStyle get _fallbackStyle =>
      size == CairnAvatarSize.sm ? CairnTypography.xs : CairnTypography.sm;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    final Widget fallbackChild = Container(
      color: theme.muted,
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: theme
            .textStyle(_fallbackStyle)
            .copyWith(color: theme.mutedForeground),
        child: fallback ?? const SizedBox.shrink(),
      ),
    );

    Widget content = fallbackChild;
    if (image != null) {
      content = Image(
        image: image!,
        width: _dimension,
        height: _dimension,
        fit: BoxFit.cover,
        // Keep the fallback visible until the first frame decodes.
        frameBuilder:
            (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return fallbackChild;
            },
        // A failed load keeps the initials rather than a broken-image glyph.
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                fallbackChild,
      );
    }

    return Semantics(
      label: semanticLabel,
      image: image != null,
      child: SizedBox.square(
        dimension: _dimension,
        child: ClipOval(child: content),
      ),
    );
  }
}

/// A row of overlapping avatars matching shadcn/ui's `AvatarGroup`.
///
/// `flex -space-x-2 *:ring-2 *:ring-background` — each avatar overlaps the
/// previous by 8 logical pixels and carries a 2px ring in the page background
/// colour, which is what separates them visually.
///
/// CSS achieves the overlap with a negative margin. Flutter's [Padding] asserts
/// non-negative insets, so this lays the avatars out in a [Stack] with computed
/// offsets instead and sizes the box explicitly — which also lets the first
/// avatar paint on top, matching the CSS stacking order.
///
/// ```dart
/// const CairnAvatarGroup(
///   size: CairnAvatarSize.md,
///   children: [
///     CairnAvatar(fallback: Text('RJ')),
///     CairnAvatar(fallback: Text('AB')),
///     CairnAvatar(fallback: Text('+3')),
///   ],
/// );
/// ```
class CairnAvatarGroup extends StatelessWidget {
  /// Creates an avatar group.
  const CairnAvatarGroup({
    super.key,
    required this.children,
    this.size = CairnAvatarSize.md,
    this.overlap = 8.0,
    this.ringWidth = 2.0,
  });

  /// The avatars, drawn left to right with the first on top.
  final List<Widget> children;

  /// The size of every avatar in the group.
  final CairnAvatarSize size;

  /// How far each avatar overlaps the previous (`-space-x-2`).
  final double overlap;

  /// The separating ring width (`ring-2`).
  final double ringWidth;

  double get _dimension => switch (size) {
    CairnAvatarSize.sm => 24.0,
    CairnAvatarSize.md => 32.0,
    CairnAvatarSize.lg => 40.0,
  };

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    if (children.isEmpty) return const SizedBox.shrink();

    // Each avatar plus its ring on both sides.
    final double ringed = _dimension + ringWidth * 2;
    final double step = ringed - overlap;
    final double width = ringed + step * (children.length - 1);

    return SizedBox(
      width: width,
      height: ringed,
      child: Stack(
        children: <Widget>[
          // Reversed so index 0 ends up painted last, i.e. on top.
          for (int i = children.length - 1; i >= 0; i--)
            Positioned(
              left: step * i,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.background, width: ringWidth),
                ),
                child: children[i],
              ),
            ),
        ],
      ),
    );
  }
}
