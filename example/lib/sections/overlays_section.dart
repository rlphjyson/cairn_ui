import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// Floating and modal surfaces.
abstract final class OverlaysSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Overlays();
}

class _Overlays extends StatefulWidget {
  const _Overlays();

  @override
  State<_Overlays> createState() => _OverlaysState();
}

class _OverlaysState extends State<_Overlays> {
  final CairnOverlayController _popover = CairnOverlayController();
  final CairnOverlayController _menu = CairnOverlayController();
  String? _framework;
  String? _combo;

  @override
  void dispose() {
    _popover.dispose();
    _menu.dispose();
    super.dispose();
  }

  static const List<CairnSelectOption<String>> _frameworks =
      <CairnSelectOption<String>>[
        CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
        CairnSelectOption<String>(value: 'react', label: 'React'),
        CairnSelectOption<String>(value: 'svelte', label: 'Svelte'),
        CairnSelectOption<String>(value: 'vue', label: 'Vue'),
        CairnSelectOption<String>(
          value: 'ember',
          label: 'Ember (unavailable)',
          enabled: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Dialog, Alert Dialog, Sheet and Drawer',
          note:
              'Modal surfaces push a PopupRoute, so Flutter supplies focus '
              'trapping, focus restore and back-gesture dismissal.',
          child: DemoRow(
            children: <Widget>[
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => _showDialog(context),
                child: const Text('Open dialog'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => _showAlert(context),
                child: const Text('Open alert dialog'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => _showSheet(context, CairnSheetSide.right),
                child: const Text('Sheet (right)'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => _showSheet(context, CairnSheetSide.left),
                child: const Text('Sheet (left)'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => _showDrawer(context),
                child: const Text('Drawer'),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Popover, Tooltip and Hover Card',
          note:
              'Anchored surfaces use OverlayPortal and flip to the opposite '
              'side when they would overflow the viewport.',
          child: DemoRow(
            children: <Widget>[
              CairnPopover(
                controller: _popover,
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: <Widget>[
                    CairnPopoverTitle('Dimensions'),
                    CairnPopoverDescription('Set the layout bounds.'),
                  ],
                ),
                child: CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: _popover.toggle,
                  child: const Text('Open popover'),
                ),
              ),
              CairnTooltip(
                message: 'Copy to clipboard',
                openDelay: const Duration(milliseconds: 300),
                child: CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Hover for tooltip'),
                ),
              ),
              CairnHoverCard(
                openDelay: const Duration(milliseconds: 300),
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: <Widget>[
                    CairnAvatar(fallback: Text('CA')),
                    Text('Cairn UI'),
                    Text('A Flutter library with real design tokens.'),
                  ],
                ),
                child: CairnButton(
                  variant: CairnButtonVariant.link,
                  onPressed: () {},
                  child: const Text('@cairn_ui'),
                ),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Dropdown Menu and Context Menu',
          note:
              'Menu panels are p-1 with min-w-[8rem]. Menu items use '
              'cursor-default, not a pointer, the way a native menu does.',
          child: DemoRow(
            children: <Widget>[
              CairnDropdownMenu(
                controller: _menu,
                items: <Widget>[
                  const CairnMenuLabel('My account'),
                  const CairnMenuSeparator(),
                  CairnMenuItem(
                    onPressed: () {},
                    shortcut: 'Ctrl+P',
                    child: const Text('Profile'),
                  ),
                  CairnMenuItem(
                    onPressed: () {},
                    shortcut: 'Ctrl+S',
                    child: const Text('Settings'),
                  ),
                  const CairnMenuSeparator(),
                  CairnMenuItem(
                    variant: CairnMenuItemVariant.destructive,
                    onPressed: () {},
                    child: const Text('Sign out'),
                  ),
                ],
                child: CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: _menu.toggle,
                  child: const Text('Open menu'),
                ),
              ),
              CairnContextMenu(
                items: <Widget>[
                  CairnMenuItem(onPressed: () {}, child: const Text('Back')),
                  CairnMenuItem(onPressed: () {}, child: const Text('Forward')),
                  const CairnMenuSeparator(),
                  CairnMenuItem(
                    onPressed: () {},
                    shortcut: 'Ctrl+R',
                    child: const Text('Reload'),
                  ),
                ],
                child: Container(
                  width: 240,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: CairnTheme.of(context).border),
                    borderRadius: BorderRadius.circular(
                      CairnTheme.of(context).radiusScale.md,
                    ),
                  ),
                  child: const Text('Right-click or long-press here'),
                ),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Select and Combobox',
          note:
              'The menu is always at least as wide as its trigger, so it '
              'never reads as a misplaced tooltip.',
          child: DemoRow(
            children: <Widget>[
              CairnSelect<String>(
                value: _framework,
                width: 240,
                placeholder: 'Select a framework',
                options: _frameworks,
                onChanged: (String v) => setState(() => _framework = v),
              ),
              CairnCombobox<String>(
                value: _combo,
                placeholder: 'Search frameworks',
                options: _frameworks,
                onChanged: (String v) => setState(() => _combo = v),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Command palette',
          note:
              'Focus stays in the input; arrow keys move a highlight through '
              'the list, exactly as cmdk does.',
          child: CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => _showCommand(context),
            trailing: const CairnKbdGroup(keys: <String>['Ctrl', 'K']),
            child: const Text('Open command palette'),
          ),
        ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context) => showCairnDialog<void>(
    context: context,
    builder: (BuildContext context) => CairnDialog(
      title: const Text('Edit profile'),
      description: const Text(
        'Make changes to your profile here. Click save when you are done.',
      ),
      content: const SizedBox(
        width: double.infinity,
        child: Column(
          spacing: 12,
          children: <Widget>[
            CairnFormField(label: 'Name', child: CairnInput()),
            CairnFormField(label: 'Username', child: CairnInput()),
          ],
        ),
      ),
      actions: <Widget>[
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CairnButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save changes'),
        ),
      ],
    ),
  );

  Future<void> _showAlert(BuildContext context) => showCairnAlertDialog<void>(
    context: context,
    builder: (BuildContext context) => CairnAlertDialog(
      title: const Text('Are you absolutely sure?'),
      description: const Text(
        'This permanently deletes your account and removes your data '
        'from our servers.',
      ),
      actions: <Widget>[
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CairnButton(
          variant: CairnButtonVariant.destructive,
          onPressed: () => Navigator.pop(context),
          child: const Text('Delete account'),
        ),
      ],
    ),
  );

  Future<void> _showSheet(BuildContext context, CairnSheetSide side) =>
      showCairnSheet<void>(
        context: context,
        side: side,
        builder: (BuildContext context) => CairnSheet(
          side: side,
          title: const Text('Filters'),
          description: const Text('Narrow the results.'),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              CairnFormField(label: 'Query', child: CairnInput()),
              CairnRadioGroup<String>(
                value: 'all',
                onChanged: null,
                children: <Widget>[
                  CairnRadioItem<String>(value: 'all', label: Text('All')),
                  CairnRadioItem<String>(value: 'open', label: Text('Open')),
                ],
              ),
            ],
          ),
          footer: <Widget>[
            CairnButton(
              expand: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
        ),
      );

  Future<void> _showDrawer(BuildContext context) => showCairnDrawer<void>(
    context: context,
    builder: (BuildContext context) => CairnDrawer(
      title: const Text('Move goal'),
      description: const Text('Set your daily activity goal.'),
      content: const Text('Drag down to dismiss.'),
      footer: <Widget>[
        CairnButton(
          expand: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Submit'),
        ),
      ],
    ),
  );

  Future<void> _showCommand(BuildContext context) => showCairnCommandPalette(
    context: context,
    items: <CairnCommandItem>[
      CairnCommandItem(
        label: 'New file',
        group: 'Actions',
        shortcut: 'Ctrl+N',
        onSelected: () {},
      ),
      CairnCommandItem(
        label: 'Open settings',
        group: 'Actions',
        keywords: const <String>['preferences', 'config'],
        onSelected: () {},
      ),
      CairnCommandItem(
        label: 'Sign out',
        group: 'Account',
        keywords: const <String>['logout'],
        onSelected: () {},
      ),
      CairnCommandItem(label: 'Profile', group: 'Account', onSelected: () {}),
    ],
  );
}
