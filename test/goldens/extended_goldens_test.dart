import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Golden sheets for the Extended components (0.2.0), kept apart from
/// `goldens_test.dart` so the original set stays untouched.
///
/// Nothing here pings, ticks or otherwise animates forever: a golden is a
/// single deterministic frame.
void main() {
  group('Extended', () {
    testWidgets('stat', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'stat_group',
        const SizedBox(
          width: 560,
          child: CairnStats(
            children: <Widget>[
              CairnStat(
                title: Text('Total revenue'),
                value: Text(r'$31,200'),
                description: Text('+12% from last month'),
              ),
              CairnStat(title: Text('Active users'), value: Text('4,200')),
            ],
          ),
        ),
        surfaceSize: const Size(592, 160),
      );
    });

    testWidgets('status tones', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'status_tones',
        GoldenRow(
          spacing: 16,
          children: <Widget>[
            for (final CairnTone t in CairnTone.values) CairnStatus(tone: t),
          ],
        ),
        surfaceSize: const Size(200, 48),
      );
    });

    testWidgets('steps', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'steps_horizontal',
        const SizedBox(
          width: 440,
          child: CairnSteps(
            current: 1,
            steps: <CairnStep>[
              CairnStep(label: 'Cart'),
              CairnStep(label: 'Shipping'),
              CairnStep(label: 'Payment'),
            ],
          ),
        ),
        surfaceSize: const Size(472, 96),
      );
    });

    testWidgets('timeline', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'timeline',
        const SizedBox(
          width: 320,
          child: CairnTimeline(
            items: <CairnTimelineItem>[
              CairnTimelineItem(
                tone: CairnTone.success,
                icon: CairnIcon(CairnIconData.check),
                title: Text('Deployed'),
                description: Text('Build 482 passed.'),
                time: Text('2m ago'),
              ),
              CairnTimelineItem(title: Text('Review approved')),
              CairnTimelineItem(
                tone: CairnTone.info,
                title: Text('Pull request opened'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(352, 220),
      );
    });

    testWidgets('chat bubbles', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'chat_bubbles',
        const SizedBox(
          width: 360,
          child: Column(
            spacing: 8,
            children: <Widget>[
              CairnChatBubble(
                author: Text('Ada'),
                child: Text('Did the release go out?'),
              ),
              CairnChatBubble(
                side: CairnChatSide.sent,
                footer: Text('Delivered'),
                child: Text('Shipped.'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(392, 160),
      );
    });

    testWidgets('rating', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'rating',
        const Column(
          spacing: 8,
          children: <Widget>[
            CairnRating(value: 0),
            CairnRating(value: 3.5),
            CairnRating(value: 5),
          ],
        ),
        surfaceSize: const Size(160, 110),
      );
    });

    testWidgets('radial progress', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'radial_progress',
        const GoldenRow(
          spacing: 16,
          children: <Widget>[
            CairnRadialProgress(value: 0.25, showValue: true),
            CairnRadialProgress(
              value: 0.7,
              tone: CairnTone.success,
              showValue: true,
            ),
          ],
        ),
        surfaceSize: const Size(190, 100),
      );
    });

    testWidgets('indicator', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'indicator',
        const Padding(
          padding: EdgeInsets.all(12),
          child: GoldenRow(
            spacing: 24,
            children: <Widget>[
              CairnIndicator(
                indicator: CairnBadge(label: Text('3')),
                child: CairnAvatar(fallback: Text('RB')),
              ),
              CairnIndicator(
                placement: CairnIndicatorPlacement.bottomEnd,
                indicator: CairnStatus(tone: CairnTone.success, size: 10),
                child: CairnAvatar(fallback: Text('AL')),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(190, 90),
      );
    });

    testWidgets('navbar and dock', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'navbar_dock',
        SizedBox(
          width: 400,
          child: Column(
            spacing: 16,
            children: <Widget>[
              const CairnNavbar(
                start: Text('Cairn'),
                center: CairnBadge(label: Text('v0.2')),
                end: CairnStatus(tone: CairnTone.success),
              ),
              CairnDock(
                index: 1,
                onChanged: (_) {},
                items: const <CairnDockItem>[
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.search),
                    label: 'Search',
                  ),
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.info),
                    label: 'Inbox',
                  ),
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.moreHorizontal),
                    label: 'More',
                  ),
                ],
              ),
            ],
          ),
        ),
        surfaceSize: const Size(432, 190),
      );
    });

    testWidgets('list', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'list_bordered',
        const SizedBox(
          width: 340,
          child: CairnList(
            bordered: true,
            children: <Widget>[
              CairnListItem(
                leading: CairnAvatar(fallback: Text('RB')),
                title: Text('Ralph'),
                subtitle: Text('Owner'),
                trailing: CairnBadge(label: Text('Admin')),
              ),
              CairnListItem(
                leading: CairnAvatar(fallback: Text('AL')),
                title: Text('Ada'),
                subtitle: Text('Maintainer'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(372, 176),
      );
    });

    testWidgets('file input and link', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'file_input_link',
        SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              CairnFileInput(onBrowse: () {}),
              CairnFileInput(
                fileName: 'quarterly-report.pdf',
                onBrowse: () {},
                onClear: () {},
              ),
              CairnLink(onPressed: () {}, child: const Text('Read the docs')),
              CairnLink(
                onPressed: () {},
                muted: true,
                underline: true,
                child: const Text('Privacy policy'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(352, 190),
      );
    });

    testWidgets('fab', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'fab',
        Padding(
          padding: const EdgeInsets.all(12),
          child: CairnFab(
            icon: const CairnIcon(CairnIconData.plus),
            onPressed: () {},
          ),
        ),
        surfaceSize: const Size(120, 120),
      );
    });

    testWidgets('mockups', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'mockups',
        const SizedBox(
          width: 360,
          child: Column(
            spacing: 12,
            children: <Widget>[
              CairnMockupBrowser(
                url: 'https://cairn.dev',
                child: SizedBox(height: 56),
              ),
              CairnMockupWindow(
                title: Text('Terminal'),
                child: SizedBox(height: 40),
              ),
              CairnMockupCode(
                lines: <String>['flutter pub add cairn_ui', 'flutter run'],
                highlight: <int>{0},
              ),
            ],
          ),
        ),
        surfaceSize: const Size(392, 360),
      );
    });

    testWidgets('hero', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'hero',
        const SizedBox(
          width: 520,
          child: CairnHero(
            muted: true,
            eyebrow: CairnBadge(label: Text('New')),
            title: Text('Build faster'),
            description: Text('Tokens first, widgets second.'),
            padding: EdgeInsets.all(32),
          ),
        ),
        surfaceSize: const Size(552, 230),
      );
    });
  });
}
