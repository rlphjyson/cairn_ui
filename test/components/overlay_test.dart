import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('showCairnDialog', () {
    testWidgets('opens, shows content and closes on the close button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => showCairnDialog<void>(
                context: context,
                builder: (BuildContext context) => const CairnDialog(
                  title: Text('Delete project'),
                  description: Text('This cannot be undone.'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete project'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Delete project'), findsNothing);
    });

    testWidgets('closes on Escape', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => showCairnDialog<void>(
                context: context,
                builder: (BuildContext context) =>
                    const CairnDialog(title: Text('Escapable')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Escapable'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.text('Escapable'),
        findsNothing,
        reason: 'Radix dismisses on Escape',
      );
    });

    testWidgets('traps focus inside the dialog', (WidgetTester tester) async {
      final FocusNode outside = FocusNode();
      addTearDown(outside.dispose);

      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CairnButton(
                  focusNode: outside,
                  onPressed: () {},
                  child: const Text('Behind'),
                ),
                CairnButton(
                  onPressed: () => showCairnDialog<void>(
                    context: context,
                    builder: (BuildContext context) => CairnDialog(
                      title: const Text('Trapped'),
                      actions: <Widget>[
                        CairnButton(
                          onPressed: () {},
                          child: const Text('Inside'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ],
            ),
          ),
        ),
      );

      outside.requestFocus();
      await tester.pumpAndSettle();
      expect(outside.hasFocus, isTrue);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The modal route installs its own FocusScope; the button behind must
      // have lost focus and must not be reachable by tabbing.
      expect(outside.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        outside.hasFocus,
        isFalse,
        reason: 'Tab must not escape the modal route',
      );
    });

    testWidgets('restores focus to the trigger on close', (
      WidgetTester tester,
    ) async {
      final FocusNode trigger = FocusNode();
      addTearDown(trigger.dispose);

      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              focusNode: trigger,
              onPressed: () => showCairnDialog<void>(
                context: context,
                builder: (BuildContext context) =>
                    const CairnDialog(title: Text('Restoring')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      trigger.requestFocus();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(trigger.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        trigger.hasFocus,
        isTrue,
        reason: 'Navigator restores focus when the route pops',
      );
    });
  });

  group('showCairnAlertDialog', () {
    testWidgets('does not close on Escape or a barrier tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => showCairnAlertDialog<void>(
                context: context,
                builder: (BuildContext context) => CairnAlertDialog(
                  title: const Text('Are you sure?'),
                  actions: <Widget>[
                    CairnButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.text('Are you sure?'),
        findsOneWidget,
        reason: 'an alert dialog demands an explicit choice',
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsNothing);
    });

    testWidgets('has no close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => showCairnAlertDialog<void>(
                context: context,
                builder: (BuildContext context) =>
                    const CairnAlertDialog(title: Text('No close')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Close'), findsNothing);
    });
  });

  group('showCairnSheet', () {
    testWidgets('slides in and dismisses', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => showCairnSheet<void>(
                context: context,
                builder: (BuildContext context) => const CairnSheet(
                  title: Text('Filters'),
                  content: Text('Sheet body'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
    });
  });

  group('CairnPopover', () {
    testWidgets('opens and closes via its controller', (
      WidgetTester tester,
    ) async {
      final CairnOverlayController controller = CairnOverlayController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(
          child: CairnPopover(
            controller: controller,
            content: const Text('Popover body'),
            child: CairnButton(
              onPressed: controller.toggle,
              child: const Text('Toggle'),
            ),
          ),
        ),
      );

      expect(find.text('Popover body'), findsNothing);

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Popover body'), findsOneWidget);

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('closes on Escape', (WidgetTester tester) async {
      final CairnOverlayController controller = CairnOverlayController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(
          child: CairnPopover(
            controller: controller,
            content: const Text('Dismiss me'),
            child: CairnButton(
              onPressed: controller.open,
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Dismiss me'), findsNothing);
    });
  });

  group('CairnDropdownMenu', () {
    testWidgets('opens, selects an item and closes', (
      WidgetTester tester,
    ) async {
      final CairnOverlayController controller = CairnOverlayController();
      addTearDown(controller.dispose);
      int chosen = 0;

      await tester.pumpWidget(
        harness(
          child: CairnDropdownMenu(
            controller: controller,
            items: <Widget>[
              const CairnMenuLabel('Account'),
              const CairnMenuSeparator(),
              CairnMenuItem(
                onPressed: () => chosen++,
                shortcut: 'Ctrl+P',
                child: const Text('Profile'),
              ),
            ],
            child: CairnButton(
              onPressed: controller.toggle,
              child: const Text('Menu'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(chosen, 1);
      expect(
        find.text('Profile'),
        findsNothing,
        reason: 'choosing an item dismisses the menu',
      );
    });
  });

  group('CairnSelect', () {
    testWidgets('opens its menu and selects an option', (
      WidgetTester tester,
    ) async {
      String? value;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnSelect<String>(
                  value: value,
                  placeholder: 'Select a framework',
                  width: 240,
                  options: const <CairnSelectOption<String>>[
                    CairnSelectOption<String>(
                      value: 'flutter',
                      label: 'Flutter',
                    ),
                    CairnSelectOption<String>(value: 'react', label: 'React'),
                  ],
                  onChanged: (String v) => setState(() => value = v),
                ),
          ),
        ),
      );

      expect(find.text('Select a framework'), findsOneWidget);

      await tester.tap(find.text('Select a framework'));
      await tester.pumpAndSettle();
      expect(find.text('React'), findsOneWidget);

      await tester.tap(find.text('React'));
      await tester.pumpAndSettle();
      expect(value, 'react');
      // The trigger now shows the selection and the menu is gone.
      expect(find.text('React'), findsOneWidget);
      expect(find.text('Flutter'), findsNothing);
    });
  });

  group('CairnCommand', () {
    testWidgets('filters as you type and runs the chosen item', (
      WidgetTester tester,
    ) async {
      String? ran;

      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 480,
            child: CairnCommand(
              autofocus: false,
              items: <CairnCommandItem>[
                CairnCommandItem(
                  label: 'New file',
                  group: 'Actions',
                  onSelected: () => ran = 'new',
                ),
                CairnCommandItem(
                  label: 'Open settings',
                  group: 'Actions',
                  keywords: const <String>['preferences'],
                  onSelected: () => ran = 'settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('New file'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'sett');
      await tester.pumpAndSettle();
      expect(find.text('New file'), findsNothing);
      expect(find.text('Open settings'), findsOneWidget);

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      expect(ran, 'settings');
    });

    testWidgets('matches on keywords, not just the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 480,
            child: CairnCommand(
              autofocus: false,
              items: <CairnCommandItem>[
                CairnCommandItem(
                  label: 'Sign out',
                  keywords: const <String>['logout'],
                  onSelected: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText), 'logout');
      await tester.pumpAndSettle();
      expect(
        find.text('Sign out'),
        findsOneWidget,
        reason: 'cmdk matches keywords too',
      );
    });

    testWidgets('shows the empty state when nothing matches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 480,
            child: CairnCommand(
              autofocus: false,
              emptyMessage: 'Nothing here.',
              items: <CairnCommandItem>[
                CairnCommandItem(label: 'Alpha', onSelected: () {}),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('Nothing here.'), findsOneWidget);
    });
  });

  group('CairnCombobox', () {
    testWidgets('filters options and selects one', (WidgetTester tester) async {
      String? value;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnCombobox<String>(
                  value: value,
                  placeholder: 'Pick one',
                  options: const <CairnSelectOption<String>>[
                    CairnSelectOption<String>(
                      value: 'flutter',
                      label: 'Flutter',
                    ),
                    CairnSelectOption<String>(value: 'svelte', label: 'Svelte'),
                  ],
                  onChanged: (String v) => setState(() => value = v),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Pick one'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'sve');
      await tester.pumpAndSettle();
      expect(find.text('Flutter'), findsNothing);

      await tester.tap(find.text('Svelte'));
      await tester.pumpAndSettle();
      expect(value, 'svelte');
    });
  });

  group('CairnToaster', () {
    testWidgets('shows a toast and dismisses it on the close button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        toastHarness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => CairnToast.show(
                context,
                const CairnToast(
                  title: 'Saved',
                  description: 'Your changes are live.',
                ),
              ),
              child: const Text('Save'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Your changes are live.'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('auto-dismisses after its duration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        toastHarness(
          child: Builder(
            builder: (BuildContext context) => CairnButton(
              onPressed: () => CairnToast.show(
                context,
                const CairnToast(
                  title: 'Transient',
                  duration: Duration(seconds: 2),
                ),
              ),
              child: const Text('Fire'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fire'));
      // Pump the 300ms slide-in with explicit frames rather than
      // pumpAndSettle: pumpAndSettle advances virtual time until nothing is
      // scheduled, which can run straight past the auto-dismiss timer.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Transient'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Transient'), findsNothing);
    });
  });

  group('CairnDatePicker', () {
    testWidgets('opens a calendar and picks a day', (
      WidgetTester tester,
    ) async {
      DateTime? picked;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnDatePicker(
                  value: picked,
                  initialMonth: DateTime(2026, 3),
                  onChanged: (DateTime d) => setState(() => picked = d),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Pick a date'));
      await tester.pumpAndSettle();
      expect(find.text('March 2026'), findsOneWidget);

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      expect(picked, isNotNull);
      expect(picked!.day, 15);
      expect(picked!.month, 3);
    });
  });

  group('CairnDataTable', () {
    testWidgets('sorts when a sortable header is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CairnDataTable<_Row>(
              rows: const <_Row>[
                _Row('Charlie', 30),
                _Row('Alice', 10),
                _Row('Bob', 20),
              ],
              columns: <CairnColumn<_Row>>[
                CairnColumn<_Row>(
                  label: 'Name',
                  cell: (_Row r) => Text(r.name),
                  sortKey: (_Row r) => r.name,
                ),
                CairnColumn<_Row>(
                  label: 'Score',
                  cell: (_Row r) => Text('${r.score}'),
                  sortKey: (_Row r) => r.score,
                ),
              ],
            ),
          ),
        ),
      );

      // Unsorted: original order.
      expect(
        tester.getTopLeft(find.text('Charlie')).dy,
        lessThan(tester.getTopLeft(find.text('Alice')).dy),
      );

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      // Ascending by name: Alice first.
      expect(
        tester.getTopLeft(find.text('Alice')).dy,
        lessThan(tester.getTopLeft(find.text('Charlie')).dy),
      );

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      // Descending: Charlie first again.
      expect(
        tester.getTopLeft(find.text('Charlie')).dy,
        lessThan(tester.getTopLeft(find.text('Alice')).dy),
      );
    });

    testWidgets('filters rows via the search field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CairnDataTable<_Row>(
              rows: const <_Row>[_Row('Alice', 10), _Row('Bob', 20)],
              searchBy: (_Row r) => r.name,
              columns: <CairnColumn<_Row>>[
                CairnColumn<_Row>(
                  label: 'Name',
                  cell: (_Row r) => Text(r.name),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'ali');
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    testWidgets('does not mutate the caller\'s row list when sorting', (
      WidgetTester tester,
    ) async {
      final List<_Row> rows = <_Row>[
        const _Row('Charlie', 30),
        const _Row('Alice', 10),
      ];
      final List<_Row> original = List<_Row>.of(rows);

      await tester.pumpWidget(
        harness(
          center: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CairnDataTable<_Row>(
              rows: rows,
              columns: <CairnColumn<_Row>>[
                CairnColumn<_Row>(
                  label: 'Name',
                  cell: (_Row r) => Text(r.name),
                  sortKey: (_Row r) => r.name,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      expect(
        rows.map((_Row r) => r.name),
        original.map((_Row r) => r.name),
        reason: 'sorting must copy, not sort the caller\'s list in place',
      );
    });
  });

  group('CairnInputOtp', () {
    testWidgets('fires onCompleted once the code is full', (
      WidgetTester tester,
    ) async {
      String? completed;
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(
          child: CairnInputOtp(
            length: 4,
            controller: controller,
            onCompleted: (String code) => completed = code,
          ),
        ),
      );

      // The active slot's caret blinks forever, so pumpAndSettle would never
      // return here — pump explicit frames instead.
      await tester.enterText(find.byType(EditableText), '123');
      await tester.pump();
      expect(completed, isNull);

      await tester.enterText(find.byType(EditableText), '1234');
      await tester.pump();
      expect(completed, '1234');
    });

    testWidgets('renders one slot per digit', (WidgetTester tester) async {
      await tester.pumpWidget(harness(child: const CairnInputOtp(length: 6)));
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsNWidgets(6));
    });
  });

  group('CairnContextMenu', () {
    testWidgets('disposes cleanly when it was never opened', (
      WidgetTester tester,
    ) async {
      // Regression test. The open/close AnimationController used to be a
      // `late final` field, so a context menu that was never right-clicked
      // built its controller for the first time inside dispose() — against an
      // already-deactivated element. createTicker then looked up an ancestor
      // TickerMode and threw "Looking up a deactivated widget's ancestor is
      // unsafe". Mounting and unmounting without interacting is enough to
      // catch it.
      await tester.pumpWidget(
        harness(
          child: CairnContextMenu(
            items: <Widget>[
              CairnMenuItem(onPressed: () {}, child: const Text('Reload')),
            ],
            child: const SizedBox(width: 120, height: 60),
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(harness(child: const SizedBox.shrink()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}

/// A row type for the data table tests.
class _Row {
  const _Row(this.name, this.score);

  final String name;
  final int score;
}
