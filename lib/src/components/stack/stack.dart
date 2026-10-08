import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';

/// Overlaps its children like a pile of cards.
///
/// The first child is on top. Each following child is shifted by [offset] and
/// shrunk slightly, with a hairline [CairnTheme.border] edge so the layers stay
/// distinguishable on a matching surface. Pass the same-sized children — the
/// stack takes the size of the first (top) one.
///
/// Also the right tool for an avatar pile: set [offset] to a small negative
/// horizontal value and let [reverse] put the first avatar on top.
///
/// ```dart
/// CairnStack(
///   offset: const Offset(0, 8),
///   children: [CairnCard(...), CairnCard(...), CairnCard(...)],
/// );
/// ```
class CairnStack extends StatelessWidget {
  /// Creates a stack.
  const CairnStack({
    super.key,
    required this.children,
    this.offset = const Offset(0, 8),
    this.scaleStep = 0.05,
  });

  /// The layers, top first.
  final List<Widget> children;

  /// How far each layer moves from the one above it.
  final Offset offset;

  /// How much each layer shrinks, as a fraction of its size.
  final double scaleStep;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final CairnTheme theme = CairnTheme.of(context);

    // Paint back-to-front: the last child first, the top child last. The top
    // child is laid out normally so it alone determines the stack's size; the
    // layers behind are positioned relative to it.
    final double maxDx = offset.dx.abs() * (children.length - 1);
    final double maxDy = offset.dy.abs() * (children.length - 1);

    return Padding(
      padding: EdgeInsets.only(
        right: offset.dx > 0 ? maxDx : 0,
        left: offset.dx < 0 ? maxDx : 0,
        bottom: offset.dy > 0 ? maxDy : 0,
        top: offset.dy < 0 ? maxDy : 0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int i = children.length - 1; i >= 0; i--)
            if (i == 0)
              children[i]
            else
              Positioned.fill(
                child: Transform.translate(
                  offset: offset * i.toDouble(),
                  child: Transform.scale(
                    scale: (1 - scaleStep * i).clamp(0.1, 1.0),
                    alignment: Alignment.topCenter,
                    child: DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          theme.radiusScale.xl,
                        ),
                        border: Border.all(color: theme.border),
                      ),
                      child: children[i],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
