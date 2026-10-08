import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/tones.dart';

/// A small dot communicating state — online, away, failing.
///
/// An 8 logical pixel circle in a [CairnTone] colour with a 1px halo of the
/// same colour at 30% alpha so it stays legible against any surface. Set
/// [ping] to pulse a ring outwards, for state that is live right now.
///
/// ```dart
/// const CairnStatus(tone: CairnTone.success, semanticLabel: 'Online');
/// ```
class CairnStatus extends StatefulWidget {
  /// Creates a status dot.
  const CairnStatus({
    super.key,
    this.tone = CairnTone.neutral,
    this.size = 8.0,
    this.ping = false,
    this.semanticLabel,
  });

  /// The colour intent.
  final CairnTone tone;

  /// The dot diameter.
  final double size;

  /// Whether to pulse a ring outwards from the dot.
  final bool ping;

  /// The accessible name. A dot is meaningless to a screen reader without one.
  final String? semanticLabel;

  @override
  State<CairnStatus> createState() => _CairnStatusState();
}

class _CairnStatusState extends State<CairnStatus>
    with SingleTickerProviderStateMixin {
  // Created in initState for the same reason as CairnProgress: a lazy field
  // would be built for the first time inside dispose() when never pinging.
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: CairnMotion.pulse);
    if (widget.ping) _controller.repeat();
  }

  @override
  void didUpdateWidget(CairnStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ping && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.ping && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = CairnToneColors.resolve(theme, widget.tone).fill;

    return Semantics(
      label: widget.semanticLabel,
      container: widget.semanticLabel != null,
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (widget.ping)
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final double t = Curves.easeOut.transform(_controller.value);
                  return Positioned.fill(
                    child: Transform.scale(
                      scale: 1.0 + t * 1.5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.75 * (1 - t)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
