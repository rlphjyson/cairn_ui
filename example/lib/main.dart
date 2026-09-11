import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import 'sections/display_section.dart';
import 'sections/feedback_section.dart';
import 'sections/forms_section.dart';
import 'sections/navigation_section.dart';
import 'sections/overlays_section.dart';
import 'sections/tokens_section.dart';

void main() => runApp(const CairnCatalogApp());

/// The Cairn component catalogue.
///
/// Doubles as living documentation — every component in the library appears
/// here, in both themes — and as the primary way to eyeball a component while
/// building it.
class CairnCatalogApp extends StatefulWidget {
  /// Creates the catalogue app.
  const CairnCatalogApp({super.key});

  @override
  State<CairnCatalogApp> createState() => _CairnCatalogAppState();
}

class _CairnCatalogAppState extends State<CairnCatalogApp> {
  late ThemeMode _mode = _initialMode();

  /// Reads `?theme=dark` from the URL so a section can be linked directly.
  ///
  /// Also what makes the catalogue screenshottable head-lessly: a CI job or a
  /// docs build can point a browser at one section in one theme without having
  /// to drive the UI.
  static ThemeMode _initialMode() => Uri.base.queryParameters['theme'] == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;

  void _toggleTheme() => setState(
    () => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cairn UI',
      debugShowCheckedModeBanner: false,
      // The whole integration story in two lines: build a ThemeData from each
      // Cairn theme and let Flutter animate between them.
      theme: CairnTheme.materialTheme(CairnTheme.light),
      darkTheme: CairnTheme.materialTheme(CairnTheme.dark),
      themeMode: _mode,
      // The toast host sits above every route so a toast outlives the screen
      // that fired it.
      builder: (BuildContext context, Widget? child) =>
          CairnToaster(child: child ?? const SizedBox.shrink()),
      home: CatalogHome(onToggleTheme: _toggleTheme, mode: _mode),
    );
  }
}

/// One entry in the catalogue's sidebar.
class CatalogSection {
  /// Creates a catalogue section.
  const CatalogSection({
    required this.title,
    required this.description,
    required this.builder,
  });

  /// The sidebar label.
  final String title;

  /// A one-line summary shown at the top of the section.
  final String description;

  /// Builds the section's body.
  final WidgetBuilder builder;
}

/// The catalogue shell: a sidebar of sections and a scrolling detail pane.
class CatalogHome extends StatefulWidget {
  /// Creates the catalogue shell.
  const CatalogHome({
    super.key,
    required this.onToggleTheme,
    required this.mode,
  });

  /// Flips between light and dark.
  final VoidCallback onToggleTheme;

  /// The active theme mode.
  final ThemeMode mode;

  @override
  State<CatalogHome> createState() => _CatalogHomeState();
}

class _CatalogHomeState extends State<CatalogHome> {
  late int _index = _initialIndex();

  /// Reads `?section=overlays` from the URL, matching on the section title.
  static int _initialIndex() {
    final String? name = Uri.base.queryParameters['section']?.toLowerCase();
    if (name == null) return 0;
    for (int i = 0; i < _sections.length; i++) {
      if (_sections[i].title.toLowerCase().startsWith(name)) return i;
    }
    return 0;
  }

  static const List<CatalogSection> _sections = <CatalogSection>[
    CatalogSection(
      title: 'Forms',
      description:
          'Button, Input, Textarea, Label, Checkbox, Switch, Radio Group, '
          'Slider, Toggle, Toggle Group, Input OTP and the Form field wrapper.',
      builder: FormsSection.build,
    ),
    CatalogSection(
      title: 'Display',
      description:
          'Card, Badge, Avatar, Alert, Separator, Skeleton, Spinner, Kbd, '
          'Aspect Ratio, Empty and Table.',
      builder: DisplaySection.build,
    ),
    CatalogSection(
      title: 'Overlays',
      description:
          'Dialog, Alert Dialog, Sheet, Drawer, Popover, Tooltip, Hover Card, '
          'Dropdown Menu, Context Menu, Select, Combobox and the Command '
          'palette.',
      builder: OverlaysSection.build,
    ),
    CatalogSection(
      title: 'Navigation',
      description:
          'Tabs, Accordion, Collapsible, Breadcrumb, Pagination, Menubar, '
          'Navigation Menu, Scroll Area and Carousel.',
      builder: NavigationSection.build,
    ),
    CatalogSection(
      title: 'Feedback & data',
      description:
          'Progress, Toast notifications, Data Table, Calendar and Date '
          'Picker.',
      builder: FeedbackSection.build,
    ),
    CatalogSection(
      title: 'Tokens',
      description:
          'The semantic colour palette, spacing, radius, type and shadow '
          'scales every component reads from.',
      builder: TokensSection.build,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (wide)
              _Sidebar(
                sections: _sections,
                index: _index,
                onSelect: (int i) => setState(() => _index = i),
                onToggleTheme: widget.onToggleTheme,
                mode: widget.mode,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!wide)
                    _CompactHeader(
                      sections: _sections,
                      index: _index,
                      onSelect: (int i) => setState(() => _index = i),
                      onToggleTheme: widget.onToggleTheme,
                      mode: widget.mode,
                    ),
                  Expanded(child: _SectionBody(section: _sections[_index])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wide-layout sidebar.
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.sections,
    required this.index,
    required this.onSelect,
    required this.onToggleTheme,
    required this.mode,
  });

  final List<CatalogSection> sections;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleTheme;
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(right: BorderSide(color: theme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CairnSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Cairn UI',
                    style: theme
                        .textStyle(CairnTypography.lg)
                        .copyWith(
                          fontWeight: CairnTypography.semibold,
                          color: theme.foreground,
                        ),
                  ),
                ),
                const CairnBadge(
                  variant: CairnBadgeVariant.secondary,
                  label: Text('0.1.0'),
                ),
              ],
            ),
            const SizedBox(height: CairnSpacing.s2),
            Text(
              'shadcn/ui, measured and rebuilt in Flutter.',
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
            ),
            const SizedBox(height: CairnSpacing.s4),
            const CairnSeparator(),
            const SizedBox(height: CairnSpacing.s4),
            Expanded(
              child: CairnScrollArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: CairnSpacing.s1,
                  children: <Widget>[
                    for (int i = 0; i < sections.length; i++)
                      _NavItem(
                        label: sections[i].title,
                        selected: i == index,
                        onTap: () => onSelect(i),
                      ),
                  ],
                ),
              ),
            ),
            const CairnSeparator(),
            const SizedBox(height: CairnSpacing.s4),
            CairnButton(
              variant: CairnButtonVariant.outline,
              expand: true,
              onPressed: onToggleTheme,
              child: Text(
                mode == ThemeMode.light ? 'Dark theme' : 'Light theme',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A sidebar row.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: CairnMotion.d150,
          curve: CairnMotion.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: CairnSpacing.s3,
            vertical: CairnSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.accent
                : (_hovered
                      ? theme.accent.withValues(alpha: 0.5)
                      : const Color(0x00000000)),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: Text(
            widget.label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  fontWeight: widget.selected
                      ? CairnTypography.medium
                      : CairnTypography.normal,
                  color: widget.selected
                      ? theme.accentForeground
                      : theme.mutedForeground,
                ),
          ),
        ),
      ),
    );
  }
}

/// The narrow-layout header, using Tabs instead of a sidebar.
class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.sections,
    required this.index,
    required this.onSelect,
    required this.onToggleTheme,
    required this.mode,
  });

  final List<CatalogSection> sections;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleTheme;
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: CairnSpacing.s3,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Cairn UI',
                  style: theme
                      .textStyle(CairnTypography.lg)
                      .copyWith(
                        fontWeight: CairnTypography.semibold,
                        color: theme.foreground,
                      ),
                ),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                size: CairnButtonSize.sm,
                onPressed: onToggleTheme,
                child: Text(mode == ThemeMode.light ? 'Dark' : 'Light'),
              ),
            ],
          ),
          CairnScrollArea(
            axis: Axis.horizontal,
            child: CairnTabs<int>(
              value: index,
              onChanged: onSelect,
              tabs: <CairnTab<int>>[
                for (int i = 0; i < sections.length; i++)
                  CairnTab<int>(value: i, label: Text(sections[i].title)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The scrolling detail pane.
class _SectionBody extends StatelessWidget {
  const _SectionBody({required this.section});

  final CatalogSection section;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return CairnScrollArea(
      padding: const EdgeInsets.all(CairnSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: theme
                .textStyle(CairnTypography.xl2)
                .copyWith(
                  fontWeight: CairnTypography.semibold,
                  letterSpacing: CairnTypography.trackingTight(24),
                  color: theme.foreground,
                ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              section.description,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
            ),
          ),
          const SizedBox(height: CairnSpacing.s8),
          Builder(builder: section.builder),
          const SizedBox(height: CairnSpacing.s16),
        ],
      ),
    );
  }
}

/// A labelled demo block used by every section.
class Demo extends StatelessWidget {
  /// Creates a demo block.
  const Demo({super.key, required this.title, required this.child, this.note});

  /// The component's name.
  final String title;

  /// The demo content.
  final Widget child;

  /// An optional note about a measurement or behaviour worth calling out.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme
                .textStyle(CairnTypography.base)
                .copyWith(
                  fontWeight: CairnTypography.semibold,
                  color: theme.foreground,
                ),
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: CairnSpacing.s1),
            Text(
              note!,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(color: theme.mutedForeground),
            ),
          ],
          const SizedBox(height: CairnSpacing.s4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CairnSpacing.s6),
            decoration: BoxDecoration(
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(theme.radiusScale.lg),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A horizontal run of demo widgets that wraps on narrow layouts.
class DemoRow extends StatelessWidget {
  /// Creates a wrapping demo row.
  const DemoRow({super.key, required this.children, this.spacing = 12.0});

  /// The widgets to lay out.
  final List<Widget> children;

  /// The gap between them.
  final double spacing;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: spacing,
    runSpacing: spacing,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}
