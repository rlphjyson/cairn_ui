import 'dart:io';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether golden images should actually be compared on this platform.
///
/// Golden files are byte-compared, and while the bundled Geist font removes the
/// dominant source of cross-platform drift (see `flutter_test_config.dart`),
/// sub-pixel anti-aliasing can still differ marginally between engine builds on
/// different operating systems.
///
/// Rather than weaken the comparison with a fuzzy threshold — which would let
/// real regressions through — Cairn generates and enforces goldens on **Linux
/// only**, which is what CI runs. On Windows and macOS the widget is still
/// built and pumped (so layout errors, overflows and exceptions are caught),
/// but the pixel comparison is skipped.
///
/// Set `CAIRN_FORCE_GOLDENS=1` to compare anyway.
bool get goldensEnabled =>
    Platform.isLinux || Platform.environment['CAIRN_FORCE_GOLDENS'] == '1';

/// The canonical background for a golden, per theme.
///
/// Goldens are captured against the theme's own `--background` so the component
/// is composited over the same surface it would sit on in a real app — which
/// matters because several components rely on alpha (the ghost Button's hover
/// fill, the dark theme's translucent borders).
Color _surfaceFor(CairnTheme theme) => theme.background;

/// Advances to a stable frame without using `pumpAndSettle`.
///
/// `pumpAndSettle` pumps until no frame is scheduled, which **never happens**
/// for a component with a repeating animation — the Spinner's rotation, the
/// Skeleton's pulse, the Input OTP caret's blink and the indeterminate Progress
/// sweep all schedule frames forever, so `pumpAndSettle` times out after ten
/// seconds and fails the test.
///
/// Pumping a fixed duration instead is both robust and deterministic: every
/// entrance transition in the library finishes within 300ms (the longest is
/// Sheet's 500ms, which goldens do not capture), and any still-running
/// animation is sampled at exactly the same phase on every run and every
/// machine.
Future<void> settleForGolden(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Wraps [child] in a minimal, deterministic app for golden capture.
///
/// Deliberately avoids [MaterialApp]'s chrome: no [Scaffold], no app bar, no
/// page transitions. Just a directionality, a media query, the Cairn theme and
/// the widget under test, sized to its intrinsic dimensions.
///
/// [textScale] exercises accessibility scaling; the default of 1.0 keeps
/// goldens stable.
Widget goldenHarness({
  required Widget child,
  required CairnTheme theme,
  double textScale = 1.0,
  EdgeInsets padding = const EdgeInsets.all(16),
}) {
  return MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(textScale),
      // Golden images must be a single deterministic frame. Components that
      // honour reduced motion (Skeleton's pulse, Spinner's rotation, the Input
      // OTP caret) then render statically instead of mid-animation.
      disableAnimations: true,
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      // Cairn's text controls wrap Flutter's TextField, which needs
      // MaterialLocalizations for its selection toolbar and accessibility
      // strings. A real app gets these from MaterialApp; this harness is
      // deliberately minimal, so it supplies them directly.
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Theme(
          data: CairnTheme.materialTheme(theme.copyWith(fontFamily: 'Geist')),
          child: ColoredBox(
            color: _surfaceFor(theme),
            child: Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: theme.copyWith(fontFamily: 'Geist').defaultTextStyle,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Pumps [child] in both themes and asserts each against a golden file.
///
/// Produces `goldens/<name>_light.png` and `goldens/<name>_dark.png`.
///
/// ```dart
/// await goldenPair(tester, 'button_variants', const _ButtonRow());
/// ```
Future<void> goldenPair(
  WidgetTester tester,
  String name,
  Widget child, {
  Size surfaceSize = const Size(400, 200),
  double textScale = 1.0,
}) async {
  for (final MapEntry<String, CairnTheme> entry in <String, CairnTheme>{
    'light': CairnTheme.light,
    'dark': CairnTheme.dark,
  }.entries) {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      goldenHarness(theme: entry.value, textScale: textScale, child: child),
    );
    await settleForGolden(tester);

    if (!goldensEnabled) continue;

    await expectLater(
      find.byType(MediaQuery).first,
      matchesGoldenFile('goldens/${name}_${entry.key}.png'),
    );
  }
}

/// Pumps [child] in a single theme and asserts one golden file.
Future<void> goldenSingle(
  WidgetTester tester,
  String name,
  Widget child, {
  CairnTheme theme = CairnTheme.light,
  Size surfaceSize = const Size(400, 200),
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(goldenHarness(theme: theme, child: child));
  await settleForGolden(tester);

  if (!goldensEnabled) return;

  await expectLater(
    find.byType(MediaQuery).first,
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Builds a labelled row of variants for a golden sheet.
///
/// Golden sheets group every variant of a component into one image, which keeps
/// the number of golden files manageable and makes a visual diff show the whole
/// component at once.
class GoldenSheet extends StatelessWidget {
  /// Creates a golden sheet.
  const GoldenSheet({super.key, required this.children, this.spacing = 12.0});

  /// The rows of the sheet.
  final List<Widget> children;

  /// Vertical gap between rows.
  final double spacing;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: spacing,
    children: children,
  );
}

/// A horizontal group of widgets for a golden sheet row.
class GoldenRow extends StatelessWidget {
  /// Creates a golden row.
  const GoldenRow({super.key, required this.children, this.spacing = 8.0});

  /// The widgets in this row.
  final List<Widget> children;

  /// Horizontal gap.
  final double spacing;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: spacing,
    children: children,
  );
}
