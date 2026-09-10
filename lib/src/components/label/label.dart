import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A form label matching shadcn/ui's `Label`.
///
/// `flex items-center gap-2 text-sm leading-none font-medium select-none`.
///
/// Note `leading-none`: the label's line height is exactly 1.0, not the font's
/// natural metric. Flutter's default line height comes from font metrics
/// (~1.2), so this must be set explicitly or a label sits a pixel or two low
/// relative to the control it labels.
///
/// Setting [enabled] to false applies `peer-disabled:opacity-50`, mirroring how
/// shadcn/ui dims a label whose control is disabled.
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   spacing: 8,
///   children: [
///     const CairnLabel('Email'),
///     CairnInput(controller: controller),
///   ],
/// );
/// ```
class CairnLabel extends StatelessWidget {
  /// Creates a label from a string.
  const CairnLabel(this.text, {super.key, this.enabled = true}) : child = null;

  /// Creates a label wrapping arbitrary content, such as text plus a badge.
  const CairnLabel.custom({
    super.key,
    required Widget this.child,
    this.enabled = true,
  }) : text = null;

  /// The label text, when built with the default constructor.
  final String? text;

  /// A custom label body, when built with [CairnLabel.custom].
  final Widget? child;

  /// Whether the labelled control is enabled. False dims the label to 50%.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle style = theme
        .textStyle(CairnTypography.sm)
        .copyWith(
          fontWeight: CairnTypography.medium,
          height: CairnTypography.leadingNone,
          color: theme.foreground,
        );

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: DefaultTextStyle(
        style: style,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s2,
          children: <Widget>[child ?? Text(text ?? '')],
        ),
      ),
    );
  }
}
