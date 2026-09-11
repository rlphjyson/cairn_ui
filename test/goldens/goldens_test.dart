import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Golden sheets — the continuously-enforced half of Cairn's pixel accuracy.
///
/// Token extraction (see `lib/src/tokens/`) is what makes the *initial*
/// implementation match shadcn/ui. These goldens are what stop it drifting
/// afterwards: every component is rendered in both themes and byte-compared
/// against a committed reference image.
///
/// Each test captures a *sheet* — all of a component's variants and states in
/// one image — rather than one file per variant. That keeps the reference set
/// reviewable (a diff shows the whole component at once) and the file count
/// manageable.
void main() {
  group('Button', () {
    testWidgets('variants', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'button_variants',
        const _ButtonVariants(),
        surfaceSize: const Size(560, 180),
      );
    });

    testWidgets('sizes', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'button_sizes',
        const _ButtonSizes(),
        surfaceSize: const Size(480, 160),
      );
    });

    testWidgets('disabled', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'button_disabled',
        const GoldenRow(
          children: <Widget>[
            CairnButton(onPressed: null, child: Text('Primary')),
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: null,
              child: Text('Outline'),
            ),
            CairnButton(
              variant: CairnButtonVariant.secondary,
              onPressed: null,
              child: Text('Secondary'),
            ),
          ],
        ),
        surfaceSize: const Size(420, 80),
      );
    });
  });

  group('Form controls', () {
    testWidgets('checkbox states', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'checkbox_states',
        _noop(
          const GoldenRow(
            spacing: 16,
            children: <Widget>[
              CairnCheckbox(value: false, onChanged: _ignoreBool),
              CairnCheckbox(value: true, onChanged: _ignoreBool),
              CairnCheckbox(
                value: null,
                tristate: true,
                onChanged: _ignoreBool,
              ),
              CairnCheckbox(value: true, onChanged: null),
              CairnCheckbox(
                value: false,
                hasError: true,
                onChanged: _ignoreBool,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(240, 64),
      );
    });

    testWidgets('switch states', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'switch_states',
        const GoldenRow(
          spacing: 16,
          children: <Widget>[
            CairnSwitch(value: false, onChanged: _ignoreBool),
            CairnSwitch(value: true, onChanged: _ignoreBool),
            CairnSwitch(
              value: true,
              size: CairnSwitchSize.sm,
              onChanged: _ignoreBool,
            ),
            CairnSwitch(value: true, onChanged: null),
          ],
        ),
        surfaceSize: const Size(240, 64),
      );
    });

    testWidgets('radio group', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'radio_group',
        const CairnRadioGroup<String>(
          value: 'pro',
          onChanged: _ignoreString,
          children: <Widget>[
            CairnRadioItem<String>(value: 'free', label: Text('Free')),
            CairnRadioItem<String>(value: 'pro', label: Text('Pro')),
            CairnRadioItem<String>(
              value: 'team',
              label: Text('Team'),
              enabled: false,
            ),
          ],
        ),
        surfaceSize: const Size(240, 140),
      );
    });

    testWidgets('input and textarea', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'input_textarea',
        const SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              CairnLabel('Email'),
              CairnInput(placeholder: 'name@example.com'),
              CairnInput(placeholder: 'Invalid', hasError: true),
              CairnInput(placeholder: 'Disabled', enabled: false),
              CairnTextarea(placeholder: 'Tell us more...'),
            ],
          ),
        ),
        surfaceSize: const Size(360, 300),
      );
    });

    testWidgets('slider', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'slider',
        const SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              CairnSlider(value: 0.3, onChanged: _ignoreDouble),
              CairnSlider(value: 0.75, onChanged: _ignoreDouble),
              CairnSlider(value: 0.5, onChanged: null),
            ],
          ),
        ),
        surfaceSize: const Size(320, 160),
      );
    });

    testWidgets('toggle and toggle group', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'toggle',
        const GoldenSheet(
          children: <Widget>[
            GoldenRow(
              children: <Widget>[
                CairnToggle(
                  value: false,
                  onChanged: _ignoreBool,
                  child: Text('Off'),
                ),
                CairnToggle(
                  value: true,
                  onChanged: _ignoreBool,
                  child: Text('On'),
                ),
                CairnToggle(
                  value: true,
                  variant: CairnToggleVariant.outline,
                  onChanged: _ignoreBool,
                  child: Text('Outline'),
                ),
              ],
            ),
            CairnToggleGroup<String>(
              values: <String>{'center'},
              onChanged: _ignoreStringSet,
              variant: CairnToggleVariant.outline,
              items: <CairnToggleGroupItem<String>>[
                CairnToggleGroupItem<String>(
                  value: 'left',
                  child: Text('Left'),
                ),
                CairnToggleGroupItem<String>(
                  value: 'center',
                  child: Text('Center'),
                ),
                CairnToggleGroupItem<String>(
                  value: 'right',
                  child: Text('Right'),
                ),
              ],
            ),
          ],
        ),
        surfaceSize: const Size(420, 160),
      );
    });

    testWidgets('input otp', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'input_otp',
        const CairnInputOtp(length: 6, groupSizes: <int>[3, 3]),
        surfaceSize: const Size(300, 80),
      );
    });
  });

  group('Display', () {
    testWidgets('badge variants', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'badge_variants',
        const GoldenRow(
          children: <Widget>[
            CairnBadge(label: Text('Default')),
            CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('Secondary'),
            ),
            CairnBadge(
              variant: CairnBadgeVariant.destructive,
              label: Text('Failed'),
            ),
            CairnBadge(
              variant: CairnBadgeVariant.outline,
              label: Text('Outline'),
            ),
          ],
        ),
        surfaceSize: const Size(400, 64),
      );
    });

    testWidgets('card', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'card',
        const CairnCard(
          width: 340,
          children: <Widget>[
            CairnCardHeader(
              title: Text('Deploy your project'),
              description: Text('Ship to production in one click.'),
            ),
            CairnCardContent(child: Text('Your changes are ready to go live.')),
            CairnCardFooter(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: _ignoreVoid,
                  child: Text('Cancel'),
                ),
                CairnButton(onPressed: _ignoreVoid, child: Text('Deploy')),
              ],
            ),
          ],
        ),
        surfaceSize: const Size(400, 280),
      );
    });

    testWidgets('alert', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'alert',
        const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              CairnAlert(
                icon: CairnIcon(CairnIconData.info),
                title: Text('Heads up!'),
                description: Text('Your trial ends in three days.'),
              ),
              CairnAlert(
                variant: CairnAlertVariant.destructive,
                icon: CairnIcon(CairnIconData.alert),
                title: Text('Payment failed'),
                description: Text('Update your billing details.'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(440, 220),
      );
    });

    testWidgets('avatar', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'avatar',
        const GoldenRow(
          spacing: 16,
          children: <Widget>[
            CairnAvatar(size: CairnAvatarSize.sm, fallback: Text('RJ')),
            CairnAvatar(fallback: Text('AB')),
            CairnAvatar(size: CairnAvatarSize.lg, fallback: Text('CD')),
            CairnAvatarGroup(
              children: <Widget>[
                CairnAvatar(fallback: Text('A')),
                CairnAvatar(fallback: Text('B')),
                CairnAvatar(fallback: Text('+3')),
              ],
            ),
          ],
        ),
        surfaceSize: const Size(380, 80),
      );
    });

    testWidgets('progress and skeleton', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'progress_skeleton',
        const SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              CairnProgress(value: 0.6),
              CairnSeparator(),
              GoldenRow(
                spacing: 12,
                children: <Widget>[
                  CairnSkeleton.circle(size: 40),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: <Widget>[
                      CairnSkeleton(width: 180, height: 12),
                      CairnSkeleton(width: 120, height: 12),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        surfaceSize: const Size(340, 180),
      );
    });

    testWidgets('kbd and empty', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'kbd_empty',
        const SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              CairnKbdGroup(keys: <String>['Ctrl', 'K']),
              CairnEmpty(
                media: CairnIcon(CairnIconData.search, size: 32),
                title: 'No results',
                description: 'Try adjusting your filters.',
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 320),
      );
    });
  });

  group('Navigation', () {
    testWidgets('tabs', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'tabs',
        const GoldenSheet(
          children: <Widget>[
            CairnTabs<String>(
              value: 'account',
              onChanged: _ignoreString,
              tabs: <CairnTab<String>>[
                CairnTab<String>(value: 'account', label: Text('Account')),
                CairnTab<String>(value: 'password', label: Text('Password')),
                CairnTab<String>(value: 'team', label: Text('Team')),
              ],
            ),
            CairnTabs<String>(
              value: 'password',
              variant: CairnTabsVariant.line,
              onChanged: _ignoreString,
              tabs: <CairnTab<String>>[
                CairnTab<String>(value: 'account', label: Text('Account')),
                CairnTab<String>(value: 'password', label: Text('Password')),
              ],
            ),
          ],
        ),
        surfaceSize: const Size(420, 160),
      );
    });

    testWidgets('breadcrumb and pagination', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'breadcrumb_pagination',
        const SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: <Widget>[
              CairnBreadcrumb(
                crumbs: <CairnCrumb>[
                  CairnCrumb(label: 'Home', onTap: _ignoreVoid),
                  CairnCrumb(label: 'Settings', onTap: _ignoreVoid),
                  CairnCrumb.current(label: 'Profile'),
                ],
              ),
              CairnPagination(
                page: 3,
                pageCount: 12,
                showLabels: false,
                onChanged: _ignoreInt,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(500, 160),
      );
    });

    testWidgets('accordion', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'accordion',
        const SizedBox(
          width: 380,
          child: CairnAccordion(
            expanded: <String>{'a'},
            onChanged: _ignoreStringSet,
            items: <CairnAccordionItem>[
              CairnAccordionItem(
                value: 'a',
                title: Text('Is it accessible?'),
                content: Text('Yes. It follows the WAI-ARIA pattern.'),
              ),
              CairnAccordionItem(
                value: 'b',
                title: Text('Is it styled?'),
                content: Text('Yes, to shadcn/ui measurements.'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(420, 220),
      );
    });

    testWidgets('table', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'table',
        SizedBox(
          width: 420,
          child: CairnTable<_Invoice>(
            rows: const <_Invoice>[
              _Invoice('INV001', 'Paid', r'$250.00'),
              _Invoice('INV002', 'Pending', r'$150.00'),
              _Invoice('INV003', 'Unpaid', r'$350.00'),
            ],
            columns: <CairnColumn<_Invoice>>[
              CairnColumn<_Invoice>(
                label: 'Invoice',
                cell: (_Invoice i) => Text(i.id),
              ),
              CairnColumn<_Invoice>(
                label: 'Status',
                cell: (_Invoice i) => Text(i.status),
              ),
              CairnColumn<_Invoice>(
                label: 'Amount',
                alignment: Alignment.centerRight,
                cell: (_Invoice i) => Text(i.amount),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(460, 220),
      );
    });
  });

  group('Surfaces', () {
    testWidgets('popover surface and menu panel', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'surfaces',
        const GoldenRow(
          spacing: 16,
          children: <Widget>[
            CairnSurface(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: <Widget>[
                  CairnPopoverTitle('Dimensions'),
                  CairnPopoverDescription('Set the layout bounds.'),
                ],
              ),
            ),
            CairnMenuPanel(
              minWidth: 180,
              children: <Widget>[
                CairnMenuLabel('My account'),
                CairnMenuSeparator(),
                CairnMenuItem(
                  onPressed: _ignoreVoid,
                  shortcut: 'Ctrl+P',
                  child: Text('Profile'),
                ),
                CairnMenuItem(
                  onPressed: _ignoreVoid,
                  shortcut: 'Ctrl+S',
                  child: Text('Settings'),
                ),
                CairnMenuSeparator(),
                CairnMenuItem(
                  variant: CairnMenuItemVariant.destructive,
                  onPressed: _ignoreVoid,
                  child: Text('Sign out'),
                ),
              ],
            ),
          ],
        ),
        surfaceSize: const Size(460, 260),
      );
    });

    testWidgets('dialog panel', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'dialog_panel',
        const SizedBox(
          width: 420,
          child: CairnDialog(
            title: Text('Delete project'),
            description: Text(
              'This permanently removes the project and all of its data.',
            ),
            actions: <Widget>[
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: _ignoreVoid,
                child: Text('Cancel'),
              ),
              CairnButton(
                variant: CairnButtonVariant.destructive,
                onPressed: _ignoreVoid,
                child: Text('Delete'),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(460, 300),
      );
    });

    testWidgets('select and date picker triggers', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'triggers',
        const SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              CairnSelect<String>(
                width: 240,
                placeholder: 'Select a framework',
                options: <CairnSelectOption<String>>[
                  CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
                ],
                onChanged: _ignoreString,
              ),
              CairnSelect<String>(
                width: 240,
                value: 'flutter',
                options: <CairnSelectOption<String>>[
                  CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
                ],
                onChanged: _ignoreString,
              ),
              CairnDatePicker(onChanged: _ignoreDate),
              CairnCombobox<String>(
                placeholder: 'Pick a framework',
                options: <CairnSelectOption<String>>[
                  CairnSelectOption<String>(value: 'flutter', label: 'Flutter'),
                ],
                onChanged: _ignoreString,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(300, 240),
      );
    });

    testWidgets('calendar', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'calendar',
        CairnCalendar(
          initialMonth: DateTime(2026, 3),
          selected: DateTime(2026, 3, 15),
          onChanged: _ignoreDate,
        ),
        surfaceSize: const Size(300, 340),
      );
    });

    testWidgets('form field states', (WidgetTester tester) async {
      await goldenPair(
        tester,
        'form_field',
        const SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: <Widget>[
              CairnFormField(
                label: 'Username',
                description: 'This is your public display name.',
                child: CairnInput(placeholder: 'shadcn'),
              ),
              CairnFormField(
                label: 'Email',
                error: 'Enter a valid email address.',
                child: CairnInput(
                  placeholder: 'you@example.com',
                  hasError: true,
                ),
              ),
            ],
          ),
        ),
        surfaceSize: const Size(360, 260),
      );
    });
  });

  group('Theme tokens', () {
    testWidgets('semantic color swatches', (WidgetTester tester) async {
      // A direct visual record of every token, so a change to the palette shows
      // up as an obvious diff rather than a subtle shift inside a component.
      await goldenPair(
        tester,
        'token_swatches',
        const _TokenSwatches(),
        surfaceSize: const Size(560, 260),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

/// Callbacks that exist only to put a component in its enabled state.
///
/// Passing null would render the disabled variant, so the golden sheets need
/// non-null handlers that do nothing. They are top-level functions so the
/// widgets above can stay `const`.
void _ignoreVoid() {}
void _ignoreBool(bool? _) {}
void _ignoreString(String _) {}
void _ignoreStringSet(Set<String> _) {}
void _ignoreDouble(double _) {}
void _ignoreInt(int _) {}
void _ignoreDate(DateTime _) {}

/// Identity helper, used where a const expression needs wrapping.
Widget _noop(Widget child) => child;

class _Invoice {
  const _Invoice(this.id, this.status, this.amount);

  final String id;
  final String status;
  final String amount;
}

class _ButtonVariants extends StatelessWidget {
  const _ButtonVariants();

  @override
  Widget build(BuildContext context) => const GoldenSheet(
    children: <Widget>[
      GoldenRow(
        children: <Widget>[
          CairnButton(onPressed: _ignoreVoid, child: Text('Primary')),
          CairnButton(
            variant: CairnButtonVariant.secondary,
            onPressed: _ignoreVoid,
            child: Text('Secondary'),
          ),
          CairnButton(
            variant: CairnButtonVariant.destructive,
            onPressed: _ignoreVoid,
            child: Text('Destructive'),
          ),
        ],
      ),
      GoldenRow(
        children: <Widget>[
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: _ignoreVoid,
            child: Text('Outline'),
          ),
          CairnButton(
            variant: CairnButtonVariant.ghost,
            onPressed: _ignoreVoid,
            child: Text('Ghost'),
          ),
          CairnButton(
            variant: CairnButtonVariant.link,
            onPressed: _ignoreVoid,
            child: Text('Link'),
          ),
        ],
      ),
      GoldenRow(
        children: <Widget>[
          CairnButton(
            onPressed: _ignoreVoid,
            leading: CairnIcon(CairnIconData.check),
            child: Text('With icon'),
          ),
          CairnButton.icon(
            icon: CairnIcon(CairnIconData.close),
            semanticLabel: 'Close',
            variant: CairnButtonVariant.outline,
            onPressed: _ignoreVoid,
          ),
          CairnButton(
            onPressed: _ignoreVoid,
            leading: CairnSpinner(),
            child: Text('Loading'),
          ),
        ],
      ),
    ],
  );
}

class _ButtonSizes extends StatelessWidget {
  const _ButtonSizes();

  @override
  Widget build(BuildContext context) => const GoldenSheet(
    children: <Widget>[
      GoldenRow(
        children: <Widget>[
          CairnButton(
            size: CairnButtonSize.xs,
            onPressed: _ignoreVoid,
            child: Text('xs / h-6'),
          ),
          CairnButton(
            size: CairnButtonSize.sm,
            onPressed: _ignoreVoid,
            child: Text('sm / h-8'),
          ),
          CairnButton(onPressed: _ignoreVoid, child: Text('md / h-9')),
          CairnButton(
            size: CairnButtonSize.lg,
            onPressed: _ignoreVoid,
            child: Text('lg / h-10'),
          ),
        ],
      ),
      GoldenRow(
        children: <Widget>[
          CairnButton.icon(
            icon: CairnIcon(CairnIconData.check, size: 12),
            semanticLabel: 'xs',
            size: CairnButtonSize.iconXs,
            onPressed: _ignoreVoid,
          ),
          CairnButton.icon(
            icon: CairnIcon(CairnIconData.check),
            semanticLabel: 'sm',
            size: CairnButtonSize.iconSm,
            onPressed: _ignoreVoid,
          ),
          CairnButton.icon(
            icon: CairnIcon(CairnIconData.check),
            semanticLabel: 'md',
            onPressed: _ignoreVoid,
          ),
          CairnButton.icon(
            icon: CairnIcon(CairnIconData.check),
            semanticLabel: 'lg',
            size: CairnButtonSize.iconLg,
            onPressed: _ignoreVoid,
          ),
        ],
      ),
    ],
  );
}

/// A grid of every semantic token, labelled.
class _TokenSwatches extends StatelessWidget {
  const _TokenSwatches();

  @override
  Widget build(BuildContext context) {
    final CairnTheme t = CairnTheme.of(context);
    final List<(String, Color)> tokens = <(String, Color)>[
      ('background', t.background),
      ('foreground', t.foreground),
      ('card', t.card),
      ('popover', t.popover),
      ('primary', t.primary),
      ('primary-fg', t.primaryForeground),
      ('secondary', t.secondary),
      ('muted', t.muted),
      ('muted-fg', t.mutedForeground),
      ('accent', t.accent),
      ('destructive', t.destructive),
      ('border', t.border),
      ('input', t.input),
      ('ring', t.ring),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final (String name, Color color) in tokens)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 64,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: t.border),
                  borderRadius: BorderRadius.circular(CairnRadius.sm),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 64,
                child: Text(
                  name,
                  style: t
                      .textStyle(CairnTypography.xs)
                      .copyWith(color: t.mutedForeground),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
