import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// The components ported from daisyUI's catalogue.
abstract final class ExtendedSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Extended();
}

class _Extended extends StatefulWidget {
  const _Extended();

  @override
  State<_Extended> createState() => _ExtendedState();
}

class _ExtendedState extends State<_Extended> {
  double _rating = 3.5;
  bool _swap = false;
  int _dock = 0;
  String? _file;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Demo(
          title: 'Stat',
          note:
              'A figure with its label and context, divided into one object '
              'by CairnStats.',
          child: SizedBox(
            width: 640,
            child: CairnStats(
              children: <Widget>[
                CairnStat(
                  title: Text('Total revenue'),
                  value: Text(r'$31,200'),
                  description: Text('+12% from last month'),
                ),
                CairnStat(
                  title: Text('Active users'),
                  value: Text('4,200'),
                  description: Text('+180 this week'),
                ),
                CairnStat(
                  title: Text('Error rate'),
                  value: Text('0.4%'),
                  description: Text('Within budget'),
                ),
              ],
            ),
          ),
        ),
        const Demo(
          title: 'Status',
          note:
              'Tones extend the token layer: success, warning and info join '
              'primary and destructive.',
          child: DemoRow(
            spacing: 20,
            children: <Widget>[
              _Labelled(CairnStatus(tone: CairnTone.neutral), 'Offline'),
              _Labelled(
                CairnStatus(tone: CairnTone.success, ping: true),
                'Online',
              ),
              _Labelled(CairnStatus(tone: CairnTone.warning), 'Away'),
              _Labelled(CairnStatus(tone: CairnTone.info), 'Syncing'),
              _Labelled(CairnStatus(tone: CairnTone.destructive), 'Failing'),
            ],
          ),
        ),
        const Demo(
          title: 'Steps',
          child: SizedBox(
            width: 520,
            child: CairnSteps(
              current: 1,
              steps: <CairnStep>[
                CairnStep(label: 'Cart', description: 'Review items'),
                CairnStep(label: 'Shipping', description: 'Where to?'),
                CairnStep(label: 'Payment', description: 'Pay securely'),
                CairnStep(label: 'Done'),
              ],
            ),
          ),
        ),
        const Demo(
          title: 'Timeline',
          child: SizedBox(
            width: 380,
            child: CairnTimeline(
              items: <CairnTimelineItem>[
                CairnTimelineItem(
                  tone: CairnTone.success,
                  icon: CairnIcon(CairnIconData.check),
                  title: Text('Deployed to production'),
                  description: Text('Build 482 passed all checks.'),
                  time: Text('2m ago'),
                ),
                CairnTimelineItem(
                  tone: CairnTone.info,
                  title: Text('Review approved'),
                  time: Text('1h ago'),
                ),
                CairnTimelineItem(
                  title: Text('Pull request opened'),
                  description: Text('Add the extended components.'),
                  time: Text('Yesterday'),
                ),
              ],
            ),
          ),
        ),
        const Demo(
          title: 'Chat bubble',
          child: SizedBox(
            width: 420,
            child: Column(
              spacing: 8,
              children: <Widget>[
                CairnChatBubble(
                  author: Text('Ada'),
                  footer: Text('10:02'),
                  child: Text('Did the release go out?'),
                ),
                CairnChatBubble(
                  side: CairnChatSide.sent,
                  footer: Text('Delivered'),
                  child: Text('Shipped. Watching the dashboards now.'),
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Rating',
          note: 'Click or use the arrow keys. The second row is read-only.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              CairnRating(
                value: _rating,
                allowHalf: true,
                onChanged: (double v) => setState(() => _rating = v),
              ),
              const CairnRating(value: 4.5),
            ],
          ),
        ),
        const Demo(
          title: 'Radial progress',
          child: DemoRow(
            spacing: 20,
            children: <Widget>[
              CairnRadialProgress(value: 0.25, showValue: true),
              CairnRadialProgress(
                value: 0.7,
                tone: CairnTone.success,
                showValue: true,
              ),
              CairnRadialProgress(
                value: 1,
                size: 80,
                tone: CairnTone.info,
                child: CairnIcon(CairnIconData.check, size: 24),
              ),
            ],
          ),
        ),
        const Demo(
          title: 'Countdown',
          child: CairnCountdown(duration: Duration(hours: 26, minutes: 14)),
        ),
        Demo(
          title: 'Indicator',
          child: DemoRow(
            spacing: 32,
            children: <Widget>[
              const CairnIndicator(
                indicator: CairnBadge(label: Text('3')),
                child: CairnAvatar(fallback: Text('RB')),
              ),
              CairnIndicator(
                placement: CairnIndicatorPlacement.bottomEnd,
                offset: const Offset(-4, -4),
                indicator: const CairnStatus(tone: CairnTone.success, size: 10),
                child: const CairnAvatar(fallback: Text('AL')),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Stack',
          child: SizedBox(
            width: 220,
            child: CairnStack(
              children: <Widget>[
                for (int i = 0; i < 3; i++)
                  CairnCard(
                    children: <Widget>[
                      CairnCardHeader(title: Text('Card ${i + 1}')),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Swap',
          child: DemoRow(
            spacing: 24,
            children: <Widget>[
              for (final CairnSwapEffect e in CairnSwapEffect.values)
                CairnSwap(
                  effect: e,
                  value: _swap,
                  onChanged: (bool v) => setState(() => _swap = v),
                  semanticLabel: 'Swap ${e.name}',
                  on: CairnBadge(label: Text('${e.name}: on')),
                  off: CairnBadge(
                    variant: CairnBadgeVariant.outline,
                    label: Text('${e.name}: off'),
                  ),
                ),
            ],
          ),
        ),
        Demo(
          title: 'Navbar',
          child: SizedBox(
            width: 640,
            child: ClipRRectBox(
              child: CairnNavbar(
                start: Text(
                  'Cairn',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.foreground,
                  ),
                ),
                center: const CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text('v0.2'),
                ),
                end: CairnButton(
                  size: CairnButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Sign in'),
                ),
              ),
            ),
          ),
        ),
        Demo(
          title: 'Dock',
          child: SizedBox(
            width: 360,
            child: ClipRRectBox(
              child: CairnDock(
                index: _dock,
                onChanged: (int i) => setState(() => _dock = i),
                items: const <CairnDockItem>[
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.search),
                    label: 'Search',
                  ),
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.info),
                    label: 'Inbox',
                    badge: CairnStatus(tone: CairnTone.destructive),
                  ),
                  CairnDockItem(
                    icon: CairnIcon(CairnIconData.moreHorizontal),
                    label: 'More',
                  ),
                ],
              ),
            ),
          ),
        ),
        const Demo(
          title: 'Hero',
          child: SizedBox(
            width: 640,
            child: CairnHero(
              muted: true,
              eyebrow: CairnBadge(label: Text('New')),
              title: Text('Build interfaces that hold together'),
              description: Text(
                'Tokens first, widgets second — so a theme change is one '
                'edit, not a hunt.',
              ),
              actions: <Widget>[
                CairnButton(onPressed: _noop, child: Text('Get started')),
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: _noop,
                  child: Text('Browse components'),
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Diff',
          note: 'Drag the grip, or focus it and use the arrow keys.',
          child: SizedBox(
            width: 420,
            child: CairnDiff(
              aspectRatio: 16 / 9,
              before: ColoredBox(
                color: theme.muted,
                child: Center(
                  child: Text(
                    'Before',
                    style: TextStyle(color: theme.mutedForeground),
                  ),
                ),
              ),
              after: ColoredBox(
                color: theme.primary,
                child: Center(
                  child: Text(
                    'After',
                    style: TextStyle(color: theme.primaryForeground),
                  ),
                ),
              ),
            ),
          ),
        ),
        Demo(
          title: 'File input',
          note:
              'Draws the control; wire onBrowse to file_picker or similar. '
              'Cairn takes no dependencies.',
          child: SizedBox(
            width: 360,
            child: CairnFileInput(
              fileName: _file,
              onBrowse: () => setState(() => _file = 'quarterly-report.pdf'),
              onClear: () => setState(() => _file = null),
            ),
          ),
        ),
        const Demo(
          title: 'List',
          child: SizedBox(
            width: 420,
            child: CairnList(
              bordered: true,
              children: <Widget>[
                CairnListItem(
                  leading: CairnAvatar(fallback: Text('RB')),
                  title: Text('Ralph'),
                  subtitle: Text('Owner'),
                  trailing: CairnBadge(label: Text('Admin')),
                  onTap: _noop,
                ),
                CairnListItem(
                  leading: CairnAvatar(fallback: Text('AL')),
                  title: Text('Ada'),
                  subtitle: Text('Maintainer'),
                  trailing: CairnBadge(
                    variant: CairnBadgeVariant.secondary,
                    label: Text('Member'),
                  ),
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ),
        const Demo(
          title: 'Link',
          child: DemoRow(
            spacing: 24,
            children: <Widget>[
              CairnLink(onPressed: _noop, child: Text('Read the docs')),
              CairnLink(
                onPressed: _noop,
                muted: true,
                underline: true,
                child: Text('Privacy policy'),
              ),
              CairnLink(onPressed: null, child: Text('Disabled')),
            ],
          ),
        ),
        const Demo(
          title: 'Floating action button',
          note: 'Tap the second one to open its speed dial.',
          child: SizedBox(
            height: 220,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 48,
                children: <Widget>[
                  CairnFab(
                    icon: CairnIcon(CairnIconData.plus),
                    onPressed: _noop,
                    semanticLabel: 'Create',
                  ),
                  CairnFab(
                    icon: CairnIcon(CairnIconData.plus),
                    semanticLabel: 'Create',
                    actions: <CairnFabAction>[
                      CairnFabAction(
                        icon: CairnIcon(CairnIconData.search),
                        label: 'Document',
                        onPressed: _noop,
                      ),
                      CairnFabAction(
                        icon: CairnIcon(CairnIconData.info),
                        label: 'Folder',
                        onPressed: _noop,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Demo(
          title: 'Mockups',
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 360,
                child: Column(
                  spacing: 16,
                  children: <Widget>[
                    CairnMockupBrowser(
                      url: 'https://cairn.dev',
                      child: SizedBox(height: 96),
                    ),
                    CairnMockupWindow(
                      title: Text('Terminal'),
                      child: SizedBox(height: 56),
                    ),
                    CairnMockupCode(
                      lines: <String>[
                        'flutter pub add cairn_ui',
                        'flutter run',
                      ],
                      highlight: <int>{0},
                    ),
                  ],
                ),
              ),
              CairnMockupPhone(
                width: 200,
                child: Center(child: Text('Your app')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop() {}

class _Labelled extends StatelessWidget {
  const _Labelled(this.dot, this.label);

  final Widget dot;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 8,
    children: <Widget>[dot, Text(label)],
  );
}

/// Rounds and outlines a full-width bar so it reads as a component on the page
/// rather than bleeding into it.
class ClipRRectBox extends StatelessWidget {
  /// Creates the wrapper.
  const ClipRRectBox({super.key, required this.child});

  /// The bar.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        border: Border.all(color: theme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
        child: child,
      ),
    );
  }
}
