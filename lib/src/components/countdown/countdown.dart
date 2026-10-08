import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A ticking countdown to zero, shown as labelled digit blocks.
///
/// Counts down from [duration] once per second, rendering days (only when the
/// duration reaches that far), hours, minutes and seconds as two-digit blocks
/// in tabular figures so the layout does not jitter as digits change. Each
/// block is a `muted` rounded tile with a small caption beneath it.
///
/// [onComplete] fires once, when the count reaches zero. Changing [duration]
/// restarts the countdown.
///
/// For a bare digit with no tile — a single number inside a sentence — use
/// [CairnCountdownDigits].
///
/// ```dart
/// CairnCountdown(
///   duration: const Duration(hours: 2, minutes: 30),
///   onComplete: () => print('Sale over'),
/// );
/// ```
class CairnCountdown extends StatefulWidget {
  /// Creates a countdown.
  const CairnCountdown({super.key, required this.duration, this.onComplete});

  /// How long to count down for.
  final Duration duration;

  /// Called once when the countdown reaches zero.
  final VoidCallback? onComplete;

  @override
  State<CairnCountdown> createState() => _CairnCountdownState();
}

class _CairnCountdownState extends State<CairnCountdown> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(CairnCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) _start();
  }

  void _start() {
    _timer?.cancel();
    _remaining = widget.duration;
    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    }
  }

  void _tick(Timer timer) {
    final Duration next = _remaining - const Duration(seconds: 1);
    setState(() => _remaining = next < Duration.zero ? Duration.zero : next);
    if (_remaining == Duration.zero) {
      timer.cancel();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration r = _remaining;
    final bool showDays = widget.duration.inDays > 0;
    final bool showHours = showDays || widget.duration.inHours > 0;

    return Semantics(
      label: 'Time remaining',
      value:
          '${r.inDays} days, ${r.inHours % 24} hours, '
          '${r.inMinutes % 60} minutes, ${r.inSeconds % 60} seconds',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: CairnSpacing.s2,
        children: <Widget>[
          if (showDays) _Block(value: r.inDays, caption: 'days'),
          if (showHours) _Block(value: r.inHours % 24, caption: 'hours'),
          _Block(value: r.inMinutes % 60, caption: 'min'),
          _Block(value: r.inSeconds % 60, caption: 'sec'),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.value, required this.caption});

  final int value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(minWidth: CairnSpacing.s12),
          padding: const EdgeInsets.symmetric(
            horizontal: CairnSpacing.s3,
            vertical: CairnSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: theme.muted,
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: Center(
            widthFactor: 1,
            child: CairnCountdownDigits(
              value: value,
              style: _digitStyle(theme),
            ),
          ),
        ),
        Text(
          caption,
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(color: theme.mutedForeground),
        ),
      ],
    );
  }

  TextStyle _digitStyle(CairnTheme theme) => theme
      .textStyle(CairnTypography.xl2)
      .copyWith(
        fontWeight: CairnTypography.semibold,
        color: theme.foreground,
        height: CairnTypography.leadingNone,
      );
}

/// A number rendered as zero-padded, tabular digits.
///
/// Tabular figures give every digit the same advance, so a ticking value does
/// not shift the text around it. Inherits its style from the ambient
/// [DefaultTextStyle] unless [style] is given.
class CairnCountdownDigits extends StatelessWidget {
  /// Creates a digit run.
  const CairnCountdownDigits({
    super.key,
    required this.value,
    this.minDigits = 2,
    this.style,
  });

  /// The number to show.
  final int value;

  /// The minimum width, zero-padded.
  final int minDigits;

  /// The text style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ?? DefaultTextStyle.of(context).style;
    return Text(
      value.toString().padLeft(minDigits, '0'),
      style: base.copyWith(
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}
