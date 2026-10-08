import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/spacing.dart';
import '../../tokens/tones.dart';
import '../../tokens/typography.dart';

/// One step of a [CairnSteps] indicator.
@immutable
class CairnStep {
  /// Creates a step.
  const CairnStep({required this.label, this.description, this.marker});

  /// The step's name.
  final String label;

  /// An optional second line.
  final String? description;

  /// Replaces the step number inside the circle — an icon or an emoji.
  final Widget? marker;
}

/// A progress-through-a-process indicator — checkout, onboarding, a wizard.
///
/// A row (or column) of 28px circles joined by a 2px line. Steps before
/// [current] are complete (filled, with a check), [current] is filled and
/// numbered, and later steps are outlined and muted. The connecting line fills
/// in as the index advances, animated at 300ms on the standard curve like
/// [CairnProgress].
///
/// Set [tone] to tint the completed portion, for example
/// [CairnTone.success].
///
/// ```dart
/// const CairnSteps(
///   current: 1,
///   steps: [
///     CairnStep(label: 'Cart'),
///     CairnStep(label: 'Shipping'),
///     CairnStep(label: 'Payment'),
///   ],
/// );
/// ```
class CairnSteps extends StatelessWidget {
  /// Creates a steps indicator.
  const CairnSteps({
    super.key,
    required this.steps,
    this.current = 0,
    this.direction = Axis.horizontal,
    this.tone = CairnTone.primary,
    this.onStepTap,
  }) : assert(current >= 0, 'current must not be negative');

  /// The steps, in order.
  final List<CairnStep> steps;

  /// The zero-based index of the active step. A value past the last step marks
  /// every step complete.
  final int current;

  /// Whether the steps run across or down.
  final Axis direction;

  /// The colour of completed and current steps.
  final CairnTone tone;

  /// Called with a step's index when a *completed* step is tapped, so a wizard
  /// can navigate back. Later steps are not tappable.
  final ValueChanged<int>? onStepTap;

  /// `size-7`.
  static const double _marker = 28.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final CairnToneColor colors = CairnToneColors.resolve(theme, tone);
    final bool horizontal = direction == Axis.horizontal;

    Widget marker(int i) {
      final bool done = i < current;
      final bool active = i == current;
      final Widget circle = AnimatedContainer(
        duration: CairnMotion.d200,
        curve: CairnMotion.standard,
        width: _marker,
        height: _marker,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (done || active) ? colors.fill : theme.background,
          border: Border.all(
            color: (done || active) ? colors.fill : theme.border,
          ),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: IconTheme(
            data: IconThemeData(
              color: (done || active) ? colors.onFill : theme.mutedForeground,
              size: 14,
            ),
            child: DefaultTextStyle(
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(
                    fontWeight: CairnTypography.medium,
                    height: CairnTypography.leadingNone,
                    color: (done || active)
                        ? colors.onFill
                        : theme.mutedForeground,
                  ),
              child:
                  steps[i].marker ??
                  (done
                      ? const CairnIcon(CairnIconData.check, size: 14)
                      : Text('${i + 1}')),
            ),
          ),
        ),
      );
      if (!done || onStepTap == null) return circle;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onStepTap!(i),
        child: MouseRegion(cursor: SystemMouseCursors.click, child: circle),
      );
    }

    Widget label(int i) {
      final bool reached = i <= current;
      final CairnStep step = steps[i];
      return Column(
        crossAxisAlignment: horizontal
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            step.label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  fontWeight: CairnTypography.medium,
                  color: reached ? theme.foreground : theme.mutedForeground,
                ),
          ),
          if (step.description != null)
            Text(
              step.description!,
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(color: theme.mutedForeground),
            ),
        ],
      );
    }

    Widget connector(int i) {
      final bool filled = i < current;
      return AnimatedContainer(
        duration: CairnMotion.d300,
        curve: CairnMotion.standard,
        width: horizontal ? null : 2,
        height: horizontal ? 2 : null,
        color: filled ? colors.fill : theme.border,
      );
    }

    final Widget body = horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < steps.length; i++) ...<Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: CairnSpacing.s2,
                  children: <Widget>[marker(i), label(i)],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: (_marker - 2) / 2,
                        left: CairnSpacing.s2,
                        right: CairnSpacing.s2,
                      ),
                      child: connector(i),
                    ),
                  ),
              ],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < steps.length; i++)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        width: _marker,
                        child: Column(
                          children: <Widget>[
                            marker(i),
                            if (i < steps.length - 1)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: CairnSpacing.s1,
                                  ),
                                  child: connector(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: CairnSpacing.s3),
                      Padding(
                        padding: EdgeInsets.only(
                          top: CairnSpacing.s1,
                          bottom: i < steps.length - 1 ? CairnSpacing.s6 : 0,
                        ),
                        child: label(i),
                      ),
                    ],
                  ),
                ),
            ],
          );

    return Semantics(
      container: true,
      value: 'Step ${(current + 1).clamp(1, steps.length)} of ${steps.length}',
      child: body,
    );
  }
}
