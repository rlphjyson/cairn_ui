import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../label/label.dart';

/// A labelled form row: label, control, description and error message.
///
/// The row is an 8px-gapped stack: a label that turns destructive when the
/// field is invalid, the control itself, a muted description, and the
/// validation message in its place.
///
/// Cairn deliberately ships the **layout wrapper only** and no validation
/// engine. Flutter already has [Form] and [FormField] with validators, and a
/// component library that invented a competing one would be fighting the
/// framework. [CairnFormField] therefore takes an [error] string that the
/// caller supplies from whatever state management it already uses.
///
/// ```dart
/// CairnFormField(
///   label: 'Email',
///   description: 'We will never share it.',
///   error: emailError,
///   child: CairnInput(controller: controller, hasError: emailError != null),
/// );
/// ```
class CairnFormField extends StatelessWidget {
  /// Creates a form field row.
  const CairnFormField({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.error,
    this.enabled = true,
  });

  /// The control this row wraps.
  final Widget child;

  /// The field's label.
  final String? label;

  /// Helper text shown below the control when there is no [error].
  final String? description;

  /// The validation error. Non-null switches the label to the destructive
  /// token and replaces [description].
  final String? error;

  /// Whether the control is enabled; false dims the label.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool invalid = error != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      // `grid gap-2`.
      spacing: CairnSpacing.s2,
      children: <Widget>[
        if (label != null)
          // An invalid label goes destructive, matching `FormLabel`'s
          // data-[error=true]:text-destructive.
          invalid
              ? DefaultTextStyle(
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        height: CairnTypography.leadingNone,
                        color: theme.destructive,
                      ),
                  child: Text(label!),
                )
              : CairnLabel(label!, enabled: enabled),
        child,
        if (invalid)
          Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.destructive),
            ),
          )
        else if (description != null)
          Text(
            description!,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
          ),
      ],
    );
  }
}
