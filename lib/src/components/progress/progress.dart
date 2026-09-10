import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/radius.dart';

/// A progress bar matching shadcn/ui's `Progress`.
///
/// `relative h-2 w-full overflow-hidden rounded-full bg-primary/20` with a
/// `bg-primary` indicator — an 8 logical pixel track whose background is the
/// primary colour at 20% alpha, not the `--muted` token.
///
/// Passing null to [value] renders an indeterminate bar, which shadcn/ui itself
/// does not provide but which is a normal expectation in a Flutter app.
///
/// ```dart
/// const CairnProgress(value: 0.6);
/// const CairnProgress(); // indeterminate
/// ```
class CairnProgress extends StatefulWidget {
  /// Creates a progress bar.
  const CairnProgress({
    super.key,
    this.value,
    this.height = 8.0,
    this.semanticLabel,
  }) : assert(
         value == null || (value >= 0.0 && value <= 1.0),
         'value must be between 0 and 1',
       );

  /// Progress from 0 to 1, or null for indeterminate.
  final double? value;

  /// The track height (`h-2`).
  final double height;

  /// The accessible name.
  final String? semanticLabel;

  @override
  State<CairnProgress> createState() => _CairnProgressState();
}

class _CairnProgressState extends State<CairnProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(CairnProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
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

    return Semantics(
      label: widget.semanticLabel,
      value: widget.value == null ? null : '${(widget.value! * 100).round()}%',
      child: ClipRRect(
        borderRadius: CairnRadius.brFull,
        child: Container(
          height: widget.height,
          // `bg-primary/20` — the primary token at 20% alpha.
          color: theme.primary.withValues(alpha: 0.2),
          child: widget.value == null
              ? _buildIndeterminate(theme)
              : _buildDeterminate(theme),
        ),
      ),
    );
  }

  Widget _buildDeterminate(CairnTheme theme) => Align(
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: widget.value,
      heightFactor: 1.0,
      child: AnimatedContainer(
        duration: CairnMotion.d300,
        curve: CairnMotion.standard,
        color: theme.primary,
      ),
    ),
  );

  Widget _buildIndeterminate(CairnTheme theme) => AnimatedBuilder(
    animation: _controller,
    builder: (BuildContext context, Widget? child) {
      // A 30%-wide bar sweeping from off-left to off-right.
      const double fraction = 0.3;
      final double t = _controller.value;
      return FractionallySizedBox(
        widthFactor: fraction,
        heightFactor: 1.0,
        alignment: Alignment(-1.0 + 2.0 * t * (1 + fraction), 0),
        child: ColoredBox(color: theme.primary),
      );
    },
  );
}
