import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A file picker control with the same footprint as [CairnInput].
///
/// `h-9 w-full rounded-md border border-input px-3 text-sm shadow-xs` with a
/// "Choose file" segment on the left and the selected [fileName] (or the
/// [placeholder]) beside it, so it lines up in a form column with every other
/// field.
///
/// Cairn deliberately has no dependencies, so this widget draws the control but
/// does not open a system picker: [onBrowse] is where you call
/// `file_picker`, `image_picker` or a web `<input type=file>`. Report the choice
/// back by setting [fileName]; pass [onClear] to show a clear button once a
/// file is selected.
///
/// ```dart
/// CairnFileInput(
///   fileName: _picked?.name,
///   onBrowse: () async => _picked = await pickFile(),
///   onClear: () => setState(() => _picked = null),
/// );
/// ```
class CairnFileInput extends StatelessWidget {
  /// Creates a file input.
  const CairnFileInput({
    super.key,
    this.fileName,
    this.onBrowse,
    this.onClear,
    this.placeholder = 'No file chosen',
    this.buttonLabel = 'Choose file',
    this.invalid = false,
    this.semanticLabel,
  });

  /// The chosen file's name, or null when nothing is chosen.
  final String? fileName;

  /// Called to open the picker. Null disables the control.
  final VoidCallback? onBrowse;

  /// Called to clear the selection. The clear button only shows when this is
  /// non-null and a file is chosen.
  final VoidCallback? onClear;

  /// Shown when [fileName] is null.
  final String placeholder;

  /// The label on the left-hand segment.
  final String buttonLabel;

  /// Whether to draw the destructive outline.
  final bool invalid;

  /// The accessible name.
  final String? semanticLabel;

  /// `h-9`.
  static const double _height = 36.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool enabled = onBrowse != null;
    final BorderRadius radius = BorderRadius.circular(theme.radiusScale.md);
    final bool hasFile = fileName != null;

    return Semantics(
      label: semanticLabel,
      value: fileName,
      child: CairnInteractive(
        enabled: enabled,
        onTap: onBrowse,
        includeSemantics: false,
        mouseCursor: CairnCursors.forEnabled(enabled),
        builder: (BuildContext context, CairnStates states) {
          final Color border = invalid
              ? theme.destructive
              : (states.focused ? theme.ring : theme.input);
          return Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: CairnShadowed(
              shadows: states.focused
                  ? (invalid ? theme.invalidRing : theme.focusRing)
                  : CairnShadows.xs,
              borderRadius: radius,
              child: AnimatedContainer(
                duration: CairnMotion.d150,
                height: _height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: CairnSpacing.s3,
                      ),
                      color: states.hovered ? theme.accent : theme.muted,
                      alignment: Alignment.center,
                      child: Text(
                        buttonLabel,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              fontWeight: CairnTypography.medium,
                              color: theme.foreground,
                            ),
                      ),
                    ),
                    Container(width: 1, color: border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CairnSpacing.s3,
                        ),
                        child: Text(
                          fileName ?? placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(
                                color: hasFile
                                    ? theme.foreground
                                    : theme.mutedForeground,
                              ),
                        ),
                      ),
                    ),
                    if (hasFile && onClear != null)
                      CairnInteractive(
                        onTap: onClear,
                        semanticLabel: 'Clear file',
                        builder: (BuildContext context, CairnStates s) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: CairnSpacing.s3,
                              ),
                              child: CairnIcon(
                                CairnIconData.close,
                                size: 14,
                                color: s.hovered
                                    ? theme.foreground
                                    : theme.mutedForeground,
                              ),
                            ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
