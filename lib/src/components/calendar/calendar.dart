import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../button/button.dart';

/// A month-grid date picker.
///
/// Day cells are 32 logical pixel (`size-8`) ghost buttons. The selected day
/// takes the primary fill, today takes the accent fill, and days spilling in
/// from the neighbouring months are muted to 50% opacity so the current month
/// still reads as a single block.
///
/// The grid is a fixed 7 x 6 so the calendar's height never changes as months
/// with different day counts are paged through — a jumping popover is one of
/// the more obvious tells of a hand-rolled date picker.
///
/// ```dart
/// CairnCalendar(
///   selected: date,
///   onChanged: (d) => setState(() => date = d),
/// );
/// ```
class CairnCalendar extends StatefulWidget {
  /// Creates a calendar.
  const CairnCalendar({
    super.key,
    this.selected,
    this.onChanged,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.weekStartsOnMonday = true,
  });

  /// The currently selected day.
  final DateTime? selected;

  /// Called when a day is chosen.
  final ValueChanged<DateTime>? onChanged;

  /// The month shown on first build. Defaults to [selected]'s month, else now.
  final DateTime? initialMonth;

  /// The earliest selectable day, inclusive.
  final DateTime? firstDate;

  /// The latest selectable day, inclusive.
  final DateTime? lastDate;

  /// Whether weeks start on Monday (ISO) rather than Sunday (US default).
  final bool weekStartsOnMonday;

  /// `size-8` — the day cell.
  static const double cellSize = 32.0;

  @override
  State<CairnCalendar> createState() => _CairnCalendarState();
}

class _CairnCalendarState extends State<CairnCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final DateTime seed =
        widget.initialMonth ?? widget.selected ?? DateTime.now();
    _month = DateTime(seed.year, seed.month);
  }

  /// Strips the time component so day comparisons are exact.
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime? a, DateTime? b) =>
      a != null &&
      b != null &&
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  void _page(int months) => setState(() {
    _month = DateTime(_month.year, _month.month + months);
  });

  bool _selectable(DateTime day) {
    if (widget.onChanged == null) return false;
    if (widget.firstDate != null && day.isBefore(_dayOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null && day.isAfter(_dayOnly(widget.lastDate!))) {
      return false;
    }
    return true;
  }

  /// The 42 days shown, starting from the first visible week.
  List<DateTime> _grid() {
    final DateTime firstOfMonth = DateTime(_month.year, _month.month);
    // Dart's weekday is 1 (Mon) .. 7 (Sun).
    final int weekday = firstOfMonth.weekday;
    final int leading = widget.weekStartsOnMonday ? weekday - 1 : weekday % 7;
    final DateTime start = firstOfMonth.subtract(Duration(days: leading));
    return <DateTime>[
      for (int i = 0; i < 42; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
  }

  static const List<String> _monthNames = <String>[
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

  static const List<String> _weekdayNamesMon = <String>[
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  static const List<String> _weekdayNamesSun = <String>[
    'Su',
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final DateTime today = _dayOnly(DateTime.now());
    final List<DateTime> days = _grid();
    final List<String> weekdays = widget.weekStartsOnMonday
        ? _weekdayNamesMon
        : _weekdayNamesSun;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: CairnSpacing.s4,
      children: <Widget>[
        // Caption row: month label with paging buttons at each end.
        Row(
          children: <Widget>[
            CairnButton.icon(
              icon: const CairnIcon(CairnIconData.chevronLeft),
              semanticLabel: 'Previous month',
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.iconSm,
              onPressed: () => _page(-1),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_monthNames[_month.month - 1]} ${_month.year}',
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        fontWeight: CairnTypography.medium,
                        color: theme.foreground,
                      ),
                ),
              ),
            ),
            CairnButton.icon(
              icon: const CairnIcon(CairnIconData.chevronRight),
              semanticLabel: 'Next month',
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.iconSm,
              onPressed: () => _page(1),
            ),
          ],
        ),
        // Weekday header — `text-muted-foreground text-[0.8rem]`.
        Row(
          children: <Widget>[
            for (final String name in weekdays)
              SizedBox(
                width: CairnCalendar.cellSize,
                child: Center(
                  child: Text(
                    name,
                    style: theme
                        .textStyle(CairnTypography.xs)
                        .copyWith(
                          color: theme.mutedForeground,
                          fontWeight: CairnTypography.normal,
                        ),
                  ),
                ),
              ),
          ],
        ),
        // Six fixed rows keep the calendar's height stable across months.
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int week = 0; week < 6; week++)
              Row(
                children: <Widget>[
                  for (int d = 0; d < 7; d++)
                    _DayCell(
                      day: days[week * 7 + d],
                      outside: days[week * 7 + d].month != _month.month,
                      selected: _sameDay(days[week * 7 + d], widget.selected),
                      isToday: _sameDay(days[week * 7 + d], today),
                      enabled: _selectable(days[week * 7 + d]),
                      onTap: () => widget.onChanged?.call(days[week * 7 + d]),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// A single day cell.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.outside,
    required this.selected,
    required this.isToday,
    required this.enabled,
    required this.onTap,
  });

  final DateTime day;
  final bool outside;
  final bool selected;
  final bool isToday;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return CairnInteractive(
      enabled: enabled,
      onTap: onTap,
      semanticLabel: '${day.day}',
      builder: (BuildContext context, CairnStates states) {
        final Color background = selected
            ? theme.primary
            : isToday
            ? theme.accent
            : states.hovered
            ? theme.accent
            : const Color(0x00000000);

        final Color foreground = selected
            ? theme.primaryForeground
            : outside
            ? theme.mutedForeground
            : isToday || states.hovered
            ? theme.accentForeground
            : theme.foreground;

        return Opacity(
          // `day-outside` is `text-muted-foreground opacity-50`.
          opacity: !enabled
              ? 0.5
              : outside
              ? 0.5
              : 1.0,
          // An unselected day cell has no fill, so the focus ring must be
          // clipped to its exterior rather than painted across the date.
          child: CairnShadowed(
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            shadows: states.focused ? theme.focusRing : const <BoxShadow>[],
            child: AnimatedContainer(
              duration: CairnMotion.d150,
              curve: CairnMotion.standard,
              width: CairnCalendar.cellSize,
              height: CairnCalendar.cellSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(theme.radiusScale.md),
              ),
              child: Text(
                '${day.day}',
                style: theme
                    .textStyle(CairnTypography.sm)
                    .copyWith(
                      color: foreground,
                      fontWeight: CairnTypography.normal,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
