import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Behaviour and layout tests for the components added after 0.1.1, which were
/// ported from daisyUI's catalogue into Cairn's token system.
void main() {
  group('CairnToneColors', () {
    test('resolves every tone in both themes', () {
      for (final CairnTheme theme in <CairnTheme>[
        CairnTheme.light,
        CairnTheme.dark,
      ]) {
        for (final CairnTone tone in CairnTone.values) {
          final CairnToneColor c = CairnToneColors.resolve(theme, tone);
          expect(c.fill.a, 1.0, reason: '$tone is opaque');
        }
      }
    });

    test('primary and destructive follow the theme tokens', () {
      expect(
        CairnToneColors.resolve(CairnTheme.light, CairnTone.primary).fill,
        CairnTheme.light.primary,
      );
      expect(
        CairnToneColors.resolve(CairnTheme.dark, CairnTone.destructive).fill,
        CairnTheme.dark.destructive,
      );
    });

    test('success is green-dominant', () {
      final Color c = CairnToneColors.resolve(
        CairnTheme.light,
        CairnTone.success,
      ).fill;
      expect(c.g, greaterThan(c.r));
      expect(c.g, greaterThan(c.b));
    });
  });

  group('CairnStat', () {
    testWidgets('renders title, value and description', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 600,
            child: CairnStats(
              children: <Widget>[
                CairnStat(
                  title: Text('Revenue'),
                  value: Text('\$31,200'),
                  description: Text('+12%'),
                ),
                CairnStat(title: Text('Users'), value: Text('4,200')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('\$31,200'), findsOneWidget);
      expect(find.text('+12%'), findsOneWidget);
      expect(find.text('4,200'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('CairnStatus', () {
    testWidgets('is 8px by default and sizes to itself', (tester) async {
      await tester.pumpWidget(
        harness(child: const CairnStatus(tone: CairnTone.success)),
      );
      expect(tester.getSize(find.byType(CairnStatus)), const Size(8, 8));
    });

    testWidgets('toggling ping does not throw', (tester) async {
      Widget build(bool ping) => harness(
        child: CairnStatus(ping: ping, semanticLabel: 'Online'),
      );
      await tester.pumpWidget(build(true));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(build(false));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes cleanly when it never pinged', (tester) async {
      await tester.pumpWidget(harness(child: const CairnStatus()));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });

  group('CairnSteps', () {
    const List<CairnStep> steps = <CairnStep>[
      CairnStep(label: 'Cart'),
      CairnStep(label: 'Shipping'),
      CairnStep(label: 'Payment'),
    ];

    testWidgets('numbers upcoming steps and checks completed ones', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 400,
            child: CairnSteps(steps: steps, current: 1),
          ),
        ),
      );
      expect(find.text('1'), findsNothing, reason: 'step 1 shows a check');
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('only completed steps are tappable', (tester) async {
      final List<int> taps = <int>[];
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 400,
            child: CairnSteps(steps: steps, current: 1, onStepTap: taps.add),
          ),
        ),
      );
      await tester.tap(find.text('3'), warnIfMissed: false);
      expect(taps, isEmpty);
      // The completed first marker is the only tappable circle.
      await tester.tapAt(
        tester.getCenter(find.text('Cart')) - const Offset(0, 24),
      );
      expect(taps, <int>[0]);
    });

    testWidgets('lays out vertically', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const CairnSteps(
            steps: steps,
            current: 5,
            direction: Axis.vertical,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final double a = tester.getTopLeft(find.text('Cart')).dy;
      final double b = tester.getTopLeft(find.text('Payment')).dy;
      expect(b, greaterThan(a));
    });
  });

  group('CairnTimeline', () {
    testWidgets('stacks events top to bottom', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 320,
            child: CairnTimeline(
              items: <CairnTimelineItem>[
                CairnTimelineItem(
                  title: Text('Created'),
                  description: Text('Opened by Ralph'),
                  time: Text('9:00'),
                ),
                CairnTimelineItem(
                  tone: CairnTone.success,
                  icon: CairnIcon(CairnIconData.check),
                  title: Text('Deployed'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Deployed')).dy,
        greaterThan(tester.getTopLeft(find.text('Created')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CairnChatBubble', () {
    testWidgets('aligns by side', (tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: const SizedBox(
            width: 400,
            child: Column(
              children: <Widget>[
                CairnChatBubble(child: Text('left')),
                CairnChatBubble(side: CairnChatSide.sent, child: Text('right')),
              ],
            ),
          ),
        ),
      );
      expect(tester.getTopLeft(find.text('left')).dx, lessThan(100));
      expect(tester.getTopRight(find.text('right')).dx, greaterThan(300));
    });

    testWidgets('caps width at 75% of the available space', (tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: SizedBox(
            width: 400,
            child: CairnChatBubble(child: Text('word ' * 100)),
          ),
        ),
      );
      final Size size = tester.getSize(find.byType(DecoratedBox).first);
      expect(size.width, lessThanOrEqualTo(300.0 + 0.01));
    });
  });

  group('CairnRating', () {
    testWidgets('tapping a star reports its value', (tester) async {
      double? got;
      await tester.pumpWidget(
        harness(child: CairnRating(value: 0, onChanged: (v) => got = v)),
      );
      final Rect r = tester.getRect(find.byType(CairnRating));
      // Third star: 3 * (20 + 2) - 11 from the left edge.
      await tester.tapAt(Offset(r.left + 2 * 22 + 10, r.center.dy));
      expect(got, 3.0);
    });

    testWidgets('half stars when allowed', (tester) async {
      double? got;
      await tester.pumpWidget(
        harness(
          child: CairnRating(
            value: 0,
            allowHalf: true,
            onChanged: (v) => got = v,
          ),
        ),
      );
      final Rect r = tester.getRect(find.byType(CairnRating));
      await tester.tapAt(Offset(r.left + 22 + 4, r.center.dy));
      expect(got, 1.5);
    });

    testWidgets('read-only ignores taps', (tester) async {
      await tester.pumpWidget(harness(child: const CairnRating(value: 3.5)));
      await tester.tap(find.byType(CairnRating));
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrow keys step the value', (tester) async {
      double value = 2;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) => CairnRating(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CairnRating));
      await tester.pump();
      expect(value, 3, reason: 'the tap landed on the middle star');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, 4);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 0);
    });
  });

  group('CairnRadialProgress', () {
    testWidgets('shows the rounded percentage', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const CairnRadialProgress(value: 0.724, showValue: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('72%'), findsOneWidget);
    });

    testWidgets('has the requested size', (tester) async {
      await tester.pumpWidget(
        harness(child: const CairnRadialProgress(value: 0.5, size: 96)),
      );
      expect(
        tester.getSize(find.byType(CairnRadialProgress)),
        const Size(96, 96),
      );
    });
  });

  group('CairnCountdown', () {
    testWidgets('ticks down and completes once', (tester) async {
      int done = 0;
      await tester.pumpWidget(
        harness(
          child: CairnCountdown(
            duration: const Duration(seconds: 3),
            onComplete: () => done++,
          ),
        ),
      );
      expect(find.text('03'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('02'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('00'), findsNWidgets(2));
      await tester.pump(const Duration(seconds: 5));
      expect(done, 1);
    });

    testWidgets('only shows hours when the duration needs them', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(child: const CairnCountdown(duration: Duration(minutes: 5))),
      );
      expect(find.text('hours'), findsNothing);
      await tester.pumpWidget(
        harness(child: const CairnCountdown(duration: Duration(hours: 5))),
      );
      expect(find.text('hours'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('disposing cancels the timer', (tester) async {
      await tester.pumpWidget(
        harness(child: const CairnCountdown(duration: Duration(minutes: 1))),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });

  group('CairnIndicator', () {
    testWidgets('does not change the child size', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const CairnIndicator(
            indicator: CairnBadge(label: Text('99+')),
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      expect(tester.getSize(find.byType(CairnIndicator)), const Size(40, 40));
    });

    testWidgets('top end badge is centred on the corner', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const CairnIndicator(
            indicator: CairnStatus(),
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      final Offset corner = tester.getTopRight(find.byType(CairnIndicator));
      final Offset dot = tester.getCenter(find.byType(CairnStatus));
      expect(dot.dx, closeTo(corner.dx, 0.01));
      expect(dot.dy, closeTo(corner.dy, 0.01));
    });
  });

  group('CairnStack', () {
    testWidgets('takes the size of its top child plus the offset', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const CairnStack(
            offset: Offset(0, 8),
            children: <Widget>[
              SizedBox(width: 100, height: 60),
              SizedBox(width: 100, height: 60),
              SizedBox(width: 100, height: 60),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(CairnStack)), const Size(100, 76));
    });
  });

  group('CairnSwap', () {
    testWidgets('toggles through onChanged', (tester) async {
      bool v = false;
      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) => CairnSwap(
              value: v,
              onChanged: (n) => setState(() => v = n),
              on: const Text('on'),
              off: const Text('off'),
            ),
          ),
        ),
      );
      expect(find.text('off'), findsOneWidget);
      await tester.tap(find.text('off'));
      await tester.pumpAndSettle();
      expect(v, isTrue);
      expect(find.text('on'), findsOneWidget);
      expect(find.text('off'), findsNothing);
    });

    testWidgets('every effect builds and animates', (tester) async {
      for (final CairnSwapEffect effect in CairnSwapEffect.values) {
        bool v = false;
        await tester.pumpWidget(
          harness(
            child: StatefulBuilder(
              builder: (context, setState) => CairnSwap(
                effect: effect,
                value: v,
                onChanged: (n) => setState(() => v = n),
                on: const Text('on'),
                off: const Text('off'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('off'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$effect');
      }
    });
  });

  group('CairnNavbar', () {
    testWidgets('centres the middle region on the bar', (tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: const SizedBox(
            width: 600,
            child: CairnNavbar(
              start: SizedBox(width: 200, height: 10),
              center: SizedBox(key: Key('mid'), width: 40, height: 10),
              end: SizedBox(width: 20, height: 10),
            ),
          ),
        ),
      );
      final double mid = tester.getCenter(find.byKey(const Key('mid'))).dx;
      final double bar = tester.getCenter(find.byType(CairnNavbar)).dx;
      expect(mid, closeTo(bar, 0.01));
      expect(tester.getSize(find.byType(CairnNavbar)).height, 56);
    });
  });

  group('CairnDock', () {
    testWidgets('reports taps by index', (tester) async {
      int? picked;
      await tester.pumpWidget(
        harness(
          center: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CairnDock(
              index: 0,
              onChanged: (i) => picked = i,
              items: const <CairnDockItem>[
                CairnDockItem(icon: SizedBox(), label: 'Home'),
                CairnDockItem(icon: SizedBox(), label: 'Search'),
                CairnDockItem(icon: SizedBox(), label: 'Inbox'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Inbox'));
      expect(picked, 2);
    });
  });

  group('CairnHero', () {
    testWidgets('renders every slot', (tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: SingleChildScrollView(
            child: CairnHero(
              eyebrow: const Text('New'),
              title: const Text('Build faster'),
              description: const Text('Everything you need.'),
              actions: <Widget>[
                CairnButton(onPressed: () {}, child: const Text('Start')),
              ],
            ),
          ),
        ),
      );
      for (final String s in <String>[
        'New',
        'Build faster',
        'Everything you need.',
        'Start',
      ]) {
        expect(find.text(s), findsOneWidget);
      }
    });
  });

  group('CairnDiff', () {
    testWidgets('dragging moves the divider and reports it', (tester) async {
      double? last;
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 400,
            child: CairnDiff(
              aspectRatio: 2,
              before: const ColoredBox(color: Colors.red),
              after: const ColoredBox(color: Colors.blue),
              onChanged: (v) => last = v,
            ),
          ),
        ),
      );
      final Offset grip = tester.getCenter(find.byType(CairnIcon).first);
      await tester.dragFrom(Offset(grip.dx + 6, grip.dy), const Offset(100, 0));
      await tester.pump();
      // Touch slop swallows the first ~18px of the drag.
      expect(last, closeTo(0.75, 0.06));
    });

    testWidgets('arrow keys move it and it clamps', (tester) async {
      double? last;
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 400,
            child: CairnDiff(
              aspectRatio: 2,
              initialPosition: 0.98,
              before: const SizedBox(),
              after: const SizedBox(),
              onChanged: (v) => last = v,
            ),
          ),
        ),
      );
      final Offset grip = tester.getCenter(find.byType(CairnIcon).first);
      await tester.tapAt(grip);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(last, 1.0);
    });
  });

  group('CairnFileInput', () {
    testWidgets('shows the placeholder, then the file name', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 320,
            child: CairnFileInput(onBrowse: _noop),
          ),
        ),
      );
      expect(find.text('No file chosen'), findsOneWidget);
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 320,
            child: CairnFileInput(fileName: 'report.pdf', onBrowse: _noop),
          ),
        ),
      );
      expect(find.text('report.pdf'), findsOneWidget);
    });

    testWidgets('is 36px tall, like CairnInput', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const SizedBox(
            width: 320,
            child: CairnFileInput(onBrowse: _noop),
          ),
        ),
      );
      expect(tester.getSize(find.byType(CairnFileInput)).height, 36);
    });

    testWidgets('tapping browses; clear clears', (tester) async {
      int browse = 0;
      int clear = 0;
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 320,
            child: CairnFileInput(
              fileName: 'a.png',
              onBrowse: () => browse++,
              onClear: () => clear++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Choose file'));
      expect(browse, 1);
      await tester.tap(find.byType(CairnIcon));
      expect(clear, 1);
    });

    testWidgets('a null onBrowse disables it', (tester) async {
      await tester.pumpWidget(
        harness(child: const SizedBox(width: 320, child: CairnFileInput())),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('CairnList', () {
    testWidgets('separates rows and handles taps', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        harness(
          child: SizedBox(
            width: 320,
            child: CairnList(
              bordered: true,
              children: <Widget>[
                CairnListItem(
                  title: const Text('One'),
                  subtitle: const Text('first'),
                  trailing: const Text('x'),
                  onTap: () => taps++,
                ),
                const CairnListItem(title: Text('Two')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('One'));
      expect(taps, 1);
      expect(find.text('first'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });
  });

  group('CairnLink', () {
    testWidgets('fires onPressed', (tester) async {
      int n = 0;
      await tester.pumpWidget(
        harness(
          child: CairnLink(onPressed: () => n++, child: const Text('Docs')),
        ),
      );
      await tester.tap(find.text('Docs'));
      expect(n, 1);
    });

    testWidgets('underlines on hover', (tester) async {
      await tester.pumpWidget(
        harness(
          child: CairnLink(onPressed: () {}, child: const Text('Docs')),
        ),
      );
      TextDecoration? decoration() => tester
          .widget<DefaultTextStyle>(
            find
                .descendant(
                  of: find.byType(CairnLink),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style
          .decoration;
      expect(decoration(), TextDecoration.none);

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Docs')));
      await tester.pump();
      expect(decoration(), TextDecoration.underline);
    });
  });

  group('CairnFab', () {
    testWidgets('is a 56px circle that fires onPressed', (tester) async {
      int n = 0;
      await tester.pumpWidget(
        harness(
          child: CairnFab(
            icon: const CairnIcon(CairnIconData.plus),
            semanticLabel: 'Create',
            onPressed: () => n++,
          ),
        ),
      );
      expect(tester.getSize(find.byType(CairnFab)), const Size(56, 56));
      await tester.tap(find.byType(CairnFab));
      expect(n, 1);
    });

    testWidgets('speed dial opens, picks and closes', (tester) async {
      int picked = 0;
      await tester.pumpWidget(
        harness(
          child: CairnFab(
            icon: const CairnIcon(CairnIconData.plus),
            actions: <CairnFabAction>[
              CairnFabAction(
                icon: const SizedBox(),
                label: 'Document',
                onPressed: () => picked++,
              ),
              CairnFabAction(
                icon: const SizedBox(),
                label: 'Folder',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('Document'), findsNothing);
      await tester.tap(find.byType(CairnIcon));
      await tester.pumpAndSettle();
      expect(find.text('Document'), findsOneWidget);
      expect(find.text('Folder'), findsOneWidget);
      await tester.tap(find.text('Document'));
      await tester.pumpAndSettle();
      expect(picked, 1);
      expect(find.text('Document'), findsNothing);
    });
  });

  group('Mockups', () {
    testWidgets('window, browser, code and phone all lay out', (tester) async {
      await tester.pumpWidget(
        harness(
          center: false,
          child: const SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CairnMockupWindow(
                  title: Text('Untitled'),
                  child: SizedBox(height: 40),
                ),
                CairnMockupBrowser(
                  url: 'https://cairn.dev',
                  child: SizedBox(height: 40),
                ),
                CairnMockupCode(
                  lines: <String>['flutter pub add cairn_ui', 'flutter run'],
                  highlight: <int>{0},
                ),
                CairnMockupPhone(child: Center(child: Text('Hi'))),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('https://cairn.dev'), findsOneWidget);
      expect(find.text('flutter run'), findsOneWidget);
      expect(tester.getSize(find.byType(CairnMockupPhone)).width, 280);
    });
  });
}

void _noop() {}
