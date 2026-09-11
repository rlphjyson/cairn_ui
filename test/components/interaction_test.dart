import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('CairnButton', () {
    testWidgets('fires onPressed on tap', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        harness(
          child: CairnButton(
            onPressed: () => taps++,
            child: const Text('Continue'),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        harness(
          child: CairnButton(
            // Disabled: no handler at all.
            onPressed: null,
            child: GestureDetector(
              onTap: () => taps++,
              child: const Text('Disabled'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pump();
      expect(
        taps,
        0,
        reason: 'disabled:pointer-events-none means taps do not land',
      );
    });

    testWidgets('a disabled button is skipped by focus traversal', (
      WidgetTester tester,
    ) async {
      final FocusNode enabled = FocusNode();
      final FocusNode disabled = FocusNode();
      addTearDown(enabled.dispose);
      addTearDown(disabled.dispose);

      await tester.pumpWidget(
        harness(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CairnButton(
                focusNode: disabled,
                onPressed: null,
                child: const Text('Off'),
              ),
              CairnButton(
                focusNode: enabled,
                onPressed: () {},
                child: const Text('On'),
              ),
            ],
          ),
        ),
      );

      disabled.requestFocus();
      await tester.pumpAndSettle();
      expect(disabled.hasFocus, isFalse);
    });

    testWidgets('activates on Space and Enter', (WidgetTester tester) async {
      int taps = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        harness(
          child: CairnButton(
            focusNode: node,
            autofocus: true,
            onPressed: () => taps++,
            child: const Text('Go'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 1, reason: 'Space should activate a focused button');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 2, reason: 'Enter should activate too');
    });

    testWidgets('renders at its documented heights', (
      WidgetTester tester,
    ) async {
      for (final (CairnButtonSize size, double expected)
          in <(CairnButtonSize, double)>[
            (CairnButtonSize.xs, 24.0),
            (CairnButtonSize.sm, 32.0),
            (CairnButtonSize.md, 36.0),
            (CairnButtonSize.lg, 40.0),
          ]) {
        await tester.pumpWidget(
          harness(
            child: CairnButton(
              size: size,
              onPressed: () {},
              child: const Text('X'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Size rendered = tester.getSize(
          find.byType(AnimatedContainer).first,
        );
        expect(
          rendered.height,
          expected,
          reason: '${size.name} should be ${expected}px tall',
        );
      }
    });

    testWidgets('icon sizes are square', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          child: CairnButton.icon(
            icon: const CairnIcon(CairnIconData.check),
            semanticLabel: 'Confirm',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(AnimatedContainer).first);
      expect(size.width, 36.0);
      expect(size.height, 36.0);
    });

    testWidgets('exposes a button semantics node with its label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: CairnButton.icon(
            icon: const CairnIcon(CairnIconData.close),
            semanticLabel: 'Close panel',
            onPressed: () {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Close panel'), findsOneWidget);
    });
  });

  group('CairnCheckbox', () {
    testWidgets('toggles on tap', (WidgetTester tester) async {
      bool? value = false;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnCheckbox(
                  value: value,
                  onChanged: (bool? v) => setState(() => value = v),
                ),
          ),
        ),
      );

      await tester.tap(find.byType(CairnCheckbox));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      await tester.tap(find.byType(CairnCheckbox));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('tristate cycles false -> true -> null', (
      WidgetTester tester,
    ) async {
      bool? value = false;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnCheckbox(
                  value: value,
                  tristate: true,
                  onChanged: (bool? v) => setState(() => value = v),
                ),
          ),
        ),
      );

      await tester.tap(find.byType(CairnCheckbox));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      await tester.tap(find.byType(CairnCheckbox));
      await tester.pumpAndSettle();
      expect(value, isNull, reason: 'third state is indeterminate');

      await tester.tap(find.byType(CairnCheckbox));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('is 16x16, matching size-4', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(child: CairnCheckbox(value: false, onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(AnimatedContainer).first);
      expect(size, const Size(16, 16));
    });
  });

  group('CairnSwitch', () {
    testWidgets('toggles and reports semantics', (WidgetTester tester) async {
      bool value = false;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnSwitch(
                  value: value,
                  semanticLabel: 'Notifications',
                  onChanged: (bool v) => setState(() => value = v),
                ),
          ),
        ),
      );

      await tester.tap(find.byType(CairnSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    });

    testWidgets('track is 32 x 18.4, the literal h-[1.15rem] w-8', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(child: CairnSwitch(value: false, onChanged: (_) {})),
      );
      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(AnimatedContainer).first);
      expect(size.width, 32.0);
      // 1.15rem at a 16px root is 18.4, not a round number.
      expect(size.height, closeTo(18.4, 0.001));
    });
  });

  group('CairnRadioGroup', () {
    testWidgets('selects one value at a time', (WidgetTester tester) async {
      String? selected = 'free';
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnRadioGroup<String>(
                  value: selected,
                  onChanged: (String v) => setState(() => selected = v),
                  children: const <Widget>[
                    CairnRadioItem<String>(value: 'free', label: Text('Free')),
                    CairnRadioItem<String>(value: 'pro', label: Text('Pro')),
                  ],
                ),
          ),
        ),
      );

      await tester.tap(find.text('Pro'));
      await tester.pumpAndSettle();
      expect(selected, 'pro');

      await tester.tap(find.text('Free'));
      await tester.pumpAndSettle();
      expect(selected, 'free');
    });
  });

  group('CairnSlider', () {
    testWidgets('arrow keys move by one step', (WidgetTester tester) async {
      double value = 0.5;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  CairnSlider(
                    value: value,
                    step: 0.1,
                    focusNode: node,
                    onChanged: (double v) => setState(() => value = v),
                  ),
            ),
          ),
        ),
      );

      node.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(value, closeTo(0.6, 1e-9));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(value, closeTo(0.5, 1e-9));
    });

    testWidgets('Home and End jump to the bounds', (WidgetTester tester) async {
      double value = 0.5;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) =>
                  CairnSlider(
                    value: value,
                    focusNode: node,
                    onChanged: (double v) => setState(() => value = v),
                  ),
            ),
          ),
        ),
      );

      node.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(value, 1.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(value, 0.0);
    });
  });

  group('CairnToggle and CairnToggleGroup', () {
    testWidgets('toggle flips its value', (WidgetTester tester) async {
      bool on = false;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnToggle(
                  value: on,
                  onChanged: (bool v) => setState(() => on = v),
                  child: const Text('B'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(on, isTrue);
    });

    testWidgets('single-select group keeps at most one value', (
      WidgetTester tester,
    ) async {
      Set<String> values = <String>{'left'};
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnToggleGroup<String>(
                  values: values,
                  onChanged: (Set<String> v) => setState(() => values = v),
                  items: const <CairnToggleGroupItem<String>>[
                    CairnToggleGroupItem<String>(
                      value: 'left',
                      child: Text('L'),
                    ),
                    CairnToggleGroupItem<String>(
                      value: 'center',
                      child: Text('C'),
                    ),
                  ],
                ),
          ),
        ),
      );

      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();
      expect(values, <String>{'center'});
    });

    testWidgets('multi-select group accumulates values', (
      WidgetTester tester,
    ) async {
      Set<String> values = <String>{};
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnToggleGroup<String>(
                  type: CairnToggleGroupType.multiple,
                  values: values,
                  onChanged: (Set<String> v) => setState(() => values = v),
                  items: const <CairnToggleGroupItem<String>>[
                    CairnToggleGroupItem<String>(
                      value: 'bold',
                      child: Text('B'),
                    ),
                    CairnToggleGroupItem<String>(
                      value: 'italic',
                      child: Text('I'),
                    ),
                  ],
                ),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I'));
      await tester.pumpAndSettle();
      expect(values, <String>{'bold', 'italic'});
    });
  });

  group('CairnTabs', () {
    testWidgets('switches the selected tab', (WidgetTester tester) async {
      String tab = 'account';
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnTabs<String>(
                  value: tab,
                  onChanged: (String v) => setState(() => tab = v),
                  tabs: const <CairnTab<String>>[
                    CairnTab<String>(value: 'account', label: Text('Account')),
                    CairnTab<String>(
                      value: 'password',
                      label: Text('Password'),
                    ),
                  ],
                ),
          ),
        ),
      );

      await tester.tap(find.text('Password'));
      await tester.pumpAndSettle();
      expect(tab, 'password');
    });
  });

  group('CairnAccordion', () {
    testWidgets('expands and collapses a section', (WidgetTester tester) async {
      Set<String> open = <String>{};
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnAccordion(
                  expanded: open,
                  onChanged: (Set<String> v) => setState(() => open = v),
                  items: const <CairnAccordionItem>[
                    CairnAccordionItem(
                      value: 'a',
                      title: Text('Is it accessible?'),
                      content: Text('Yes it is.'),
                    ),
                  ],
                ),
          ),
        ),
      );

      expect(open, isEmpty);
      await tester.tap(find.text('Is it accessible?'));
      await tester.pumpAndSettle();
      expect(open, <String>{'a'});
      expect(find.text('Yes it is.'), findsOneWidget);

      await tester.tap(find.text('Is it accessible?'));
      await tester.pumpAndSettle();
      expect(open, isEmpty);
    });

    testWidgets('single mode closes the previous section', (
      WidgetTester tester,
    ) async {
      Set<String> open = <String>{'a'};
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnAccordion(
                  expanded: open,
                  onChanged: (Set<String> v) => setState(() => open = v),
                  items: const <CairnAccordionItem>[
                    CairnAccordionItem(
                      value: 'a',
                      title: Text('First'),
                      content: Text('One'),
                    ),
                    CairnAccordionItem(
                      value: 'b',
                      title: Text('Second'),
                      content: Text('Two'),
                    ),
                  ],
                ),
          ),
        ),
      );

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(open, <String>{'b'}, reason: 'single mode replaces');
    });
  });

  group('CairnPagination', () {
    testWidgets('pages forward and back', (WidgetTester tester) async {
      int page = 1;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnPagination(
                  page: page,
                  pageCount: 5,
                  showLabels: false,
                  onChanged: (int p) => setState(() => page = p),
                ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pumpAndSettle();
      expect(page, 2);

      await tester.tap(find.bySemanticsLabel('Previous page'));
      await tester.pumpAndSettle();
      expect(page, 1);
    });

    testWidgets('jumps to a numbered page', (WidgetTester tester) async {
      int page = 1;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                CairnPagination(
                  page: page,
                  pageCount: 5,
                  showLabels: false,
                  onChanged: (int p) => setState(() => page = p),
                ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(page, 3);
    });
  });
}
