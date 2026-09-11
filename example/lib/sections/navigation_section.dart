import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// Navigation and disclosure components.
abstract final class NavigationSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Navigation();
}

class _Navigation extends StatefulWidget {
  const _Navigation();

  @override
  State<_Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<_Navigation> {
  String _tab = 'account';
  String _lineTab = 'overview';
  Set<String> _open = <String>{'a'};
  bool _collapsed = false;
  int _page = 3;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Tabs',
          note:
              'The filled track is p-[3px] - an arbitrary value, not a spacing '
              'step. The line variant underlines 5px below the trigger.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s5,
            children: <Widget>[
              CairnTabs<String>(
                value: _tab,
                onChanged: (String v) => setState(() => _tab = v),
                tabs: const <CairnTab<String>>[
                  CairnTab<String>(value: 'account', label: Text('Account')),
                  CairnTab<String>(value: 'password', label: Text('Password')),
                  CairnTab<String>(value: 'team', label: Text('Team')),
                ],
              ),
              CairnTabs<String>(
                value: _lineTab,
                variant: CairnTabsVariant.line,
                onChanged: (String v) => setState(() => _lineTab = v),
                tabs: const <CairnTab<String>>[
                  CairnTab<String>(value: 'overview', label: Text('Overview')),
                  CairnTab<String>(
                    value: 'analytics',
                    label: Text('Analytics'),
                  ),
                  CairnTab<String>(value: 'reports', label: Text('Reports')),
                ],
              ),
            ],
          ),
        ),
        Demo(
          title: 'Accordion and Collapsible',
          child: SizedBox(
            width: 440,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: CairnSpacing.s6,
              children: <Widget>[
                CairnAccordion(
                  expanded: _open,
                  onChanged: (Set<String> v) => setState(() => _open = v),
                  items: const <CairnAccordionItem>[
                    CairnAccordionItem(
                      value: 'a',
                      title: Text('Is it accessible?'),
                      content: Text(
                        'Yes. It follows the WAI-ARIA disclosure pattern and '
                        'is fully keyboard operable.',
                      ),
                    ),
                    CairnAccordionItem(
                      value: 'b',
                      title: Text('Is it styled?'),
                      content: Text(
                        'Yes, to shadcn/ui measurements, down to the 2px '
                        'chevron nudge.',
                      ),
                    ),
                    CairnAccordionItem(
                      value: 'c',
                      title: Text('Is it animated?'),
                      content: Text(
                        'Yes, the body animates over 200ms with Tailwind\'s '
                        'default easing curve.',
                      ),
                    ),
                  ],
                ),
                CairnCollapsible(
                  open: _collapsed,
                  onToggle: () => setState(() => _collapsed = !_collapsed),
                  trigger: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: CairnSpacing.s2,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Starred repositories',
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(
                                  fontWeight: CairnTypography.medium,
                                  color: theme.foreground,
                                ),
                          ),
                        ),
                        CairnIcon(
                          _collapsed
                              ? CairnIconData.chevronUp
                              : CairnIconData.chevronDown,
                          color: theme.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: CairnSpacing.s2),
                    child: Text('@cairn_ui/starred'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Breadcrumb and Pagination',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s6,
            children: <Widget>[
              CairnBreadcrumb(
                crumbs: <CairnCrumb>[
                  CairnCrumb(label: 'Home', onTap: () {}),
                  CairnCrumb(label: 'Components', onTap: () {}),
                  const CairnCrumb.current(label: 'Breadcrumb'),
                ],
              ),
              CairnPagination(
                page: _page,
                pageCount: 12,
                onChanged: (int p) => setState(() => _page = p),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Menubar and Navigation Menu',
          note:
              'Once a menubar menu is open, hovering a sibling switches to it '
              'without a click, as every native menu bar does.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s6,
            children: <Widget>[
              CairnMenubar(
                menus: <CairnMenubarMenu>[
                  CairnMenubarMenu(
                    label: 'File',
                    items: <Widget>[
                      CairnMenuItem(
                        onPressed: () {},
                        shortcut: 'Ctrl+N',
                        child: const Text('New tab'),
                      ),
                      CairnMenuItem(
                        onPressed: () {},
                        shortcut: 'Ctrl+O',
                        child: const Text('Open...'),
                      ),
                      const CairnMenuSeparator(),
                      CairnMenuItem(
                        onPressed: () {},
                        child: const Text('Print'),
                      ),
                    ],
                  ),
                  CairnMenubarMenu(
                    label: 'Edit',
                    items: <Widget>[
                      CairnMenuItem(
                        onPressed: () {},
                        shortcut: 'Ctrl+Z',
                        child: const Text('Undo'),
                      ),
                      CairnMenuItem(
                        onPressed: () {},
                        shortcut: 'Ctrl+Y',
                        child: const Text('Redo'),
                      ),
                    ],
                  ),
                  CairnMenubarMenu(
                    label: 'View',
                    items: <Widget>[
                      CairnMenuItem(
                        onPressed: () {},
                        child: const Text('Reload'),
                      ),
                    ],
                  ),
                ],
              ),
              CairnNavigationMenu(
                items: <CairnNavigationItem>[
                  CairnNavigationItem(
                    label: 'Getting started',
                    content: SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: CairnSpacing.s2,
                        children: <Widget>[
                          Text(
                            'Introduction',
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(fontWeight: CairnTypography.medium),
                          ),
                          Text(
                            'Re-usable components built to shadcn/ui\'s '
                            'exact measurements.',
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CairnNavigationItem(label: 'Docs', onPressed: () {}),
                  CairnNavigationItem(label: 'Blog', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        Demo(
          title: 'Scroll Area',
          note:
              'Configures Flutter\'s scrollbar rather than reimplementing '
              'scrolling: the thumb is bg-border on a w-2.5 track.',
          child: SizedBox(
            width: 320,
            child: CairnScrollArea(
              height: 180,
              alwaysVisible: true,
              padding: const EdgeInsets.only(right: CairnSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int i = 1; i <= 20; i++) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: CairnSpacing.s2,
                      ),
                      child: Text('Tag $i'),
                    ),
                    if (i != 20) const CairnSeparator(),
                  ],
                ],
              ),
            ),
          ),
        ),
        Demo(
          title: 'Carousel',
          child: SizedBox(
            width: 420,
            child: CairnCarousel(
              height: 160,
              items: <Widget>[
                for (int i = 1; i <= 5; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.muted,
                      borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: theme
                            .textStyle(CairnTypography.xl3)
                            .copyWith(
                              fontWeight: CairnTypography.semibold,
                              color: theme.foreground,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
