import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('Intrinsic sizing', () {
    testWidgets('a button hugs its label rather than filling the row', (
      WidgetTester tester,
    ) async {
      // shadcn/ui buttons are `inline-flex`, i.e. width-of-content. Given a
      // wide but loose box they must not stretch.
      await tester.pumpWidget(
        harness(
          center: false,
          child: SizedBox(
            width: 600,
            child: Align(
              alignment: Alignment.topLeft,
              child: CairnButton(onPressed: () {}, child: const Text('OK')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double width = tester
          .getSize(find.byType(AnimatedContainer).first)
          .width;
      expect(
        width,
        lessThan(120),
        reason: 'a two-character button must not fill 600px',
      );
      // px-4 either side of a short label.
      expect(width, greaterThan(32));
    });

    testWidgets('expand:true does fill the available width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: SizedBox(
            width: 600,
            child: CairnButton(
              expand: true,
              onPressed: () {},
              child: const Text('OK'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(AnimatedContainer).first).width, 600);
    });

    testWidgets('a badge hugs its label', (WidgetTester tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: const SizedBox(
            width: 600,
            child: Align(
              alignment: Alignment.topLeft,
              child: CairnBadge(label: Text('New')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(CairnBadge)).width, lessThan(120));
    });

    testWidgets('a toggle hugs its label but respects min-w', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: SizedBox(
            width: 600,
            child: Align(
              alignment: Alignment.topLeft,
              child: CairnToggle(
                value: false,
                onChanged: (_) {},
                child: const Text('B'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double width = tester
          .getSize(find.byType(AnimatedContainer).first)
          .width;
      // `min-w-9` on the default size.
      expect(width, 36.0);
    });

    testWidgets('a select trigger with no width hugs its content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: const SizedBox(
            width: 600,
            child: Align(
              alignment: Alignment.topLeft,
              child: CairnSelect<String>(
                placeholder: 'Pick',
                options: <CairnSelectOption<String>>[
                  CairnSelectOption<String>(value: 'a', label: 'A'),
                ],
                onChanged: null,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(AnimatedContainer).first).width,
        lessThan(200),
        reason: 'Select is w-fit unless given an explicit width',
      );
    });
  });
}
