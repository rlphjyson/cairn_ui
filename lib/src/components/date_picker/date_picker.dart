import 'package:flutter/widgets.dart';

import '../../internal/anchored_overlay.dart';
import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../internal/popover_layer.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../calendar/calendar.dart';
import '../popover/popover.dart';

/// A date field matching shadcn/ui's `DatePicker` recipe.
///
/// shadcn/ui does not ship a Date Picker component — it documents a *pattern*:
/// an outline Button trigger whose label is either the formatted date or a
/// muted placeholder, opening a Popover containing a Calendar. Cairn packages
/// that same composition so it is one widget at the call site while still being
/// built from [CairnCalendar] and the popover layer.
///
/// [format] defaults to an unambiguous `D Month YYYY`. Applications with
/// `intl` available should pass their own formatter rather than relying on it,
/// which is why this takes a callback instead of a pattern string — the package
/// stays dependency-free.
///
/// ```dart
/// CairnDatePicker(
///   value: date,
///   onChanged: (d) => setState(() => date = d),
/// );
/// ```
class CairnDatePicker extends StatefulWidget {
  /// Creates a date picker.
  const CairnDatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder = 'Pick a date',
    this.format,
    this.firstDate,
    this.lastDate,
    this.initialMonth,
    this.width = 240.0,
    this.hasError = false,
  });

  /// The selected date.
  final DateTime? value;

  /// Called when a date is chosen.
  final ValueChanged<DateTime>? onChanged;

  /// Text shown when nothing is selected.
  final String placeholder;

  /// Formats the selected date for display.
  final String Function(DateTime)? format;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// The month the calendar opens on when nothing is selected.
  ///
  /// Defaults to the current month. Set this to make the picker deterministic
  /// in tests, or to open on a business-relevant month.
  final DateTime? initialMonth;

  /// The trigger width.
  final double width;

  /// Marks the field invalid.
  final bool hasError;

  @override
  State<CairnDatePicker> createState() => _CairnDatePickerState();
}

class _CairnDatePickerState extends State<CairnDatePicker> {
  final CairnOverlayController _controller = CairnOverlayController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _defaultFormat(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool enabled = widget.onChanged != null;
    final String label = widget.value == null
        ? widget.placeholder
        : (widget.format ?? _defaultFormat)(widget.value!);

    return CairnAnchoredOverlay(
      controller: _controller,
      side: CairnSide.bottom,
      align: CairnAlign.start,
      offset: 4.0,
      anchor: CairnInteractive(
        enabled: enabled,
        onTap: _controller.toggle,
        semanticLabel: 'Choose date',
        builder: (BuildContext context, CairnStates states) {
          final Color borderColor = widget.hasError
              ? theme.destructive
              : (states.focused ? theme.ring : theme.input);

          return Opacity(
            opacity: enabled ? 1.0 : 0.5,
            // `bg-transparent` at rest: clip shadows to the exterior.
            child: CairnShadowed(
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
              shadows: <BoxShadow>[
                ...CairnShadows.xs,
                if (states.focused)
                  ...(widget.hasError ? theme.invalidRing : theme.focusRing),
              ],
              child: AnimatedContainer(
                duration: CairnMotion.d150,
                curve: CairnMotion.standard,
                height: 36.0,
                width: widget.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s3,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.input.withValues(
                          alpha: states.hovered ? 0.5 : 0.3,
                        )
                      : (states.hovered
                            ? theme.accent
                            : const Color(0x00000000)),
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  spacing: CairnSpacing.s2,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              // Placeholder is muted, like Select's.
                              color: widget.value == null
                                  ? theme.mutedForeground
                                  : theme.foreground,
                            ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: CairnIcon(
                        CairnIconData.chevronDown,
                        color: theme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      overlayBuilder: (BuildContext context) => CairnSurface(
        padding: const EdgeInsets.all(CairnSpacing.s3),
        child: CairnCalendar(
          selected: widget.value,
          initialMonth: widget.initialMonth,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onChanged: (DateTime d) {
            widget.onChanged?.call(d);
            _controller.close();
          },
        ),
      ),
    );
  }
}
