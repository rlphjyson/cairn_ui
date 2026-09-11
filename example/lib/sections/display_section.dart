import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// Static display components.
abstract final class DisplaySection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Display();
}

class _Display extends StatelessWidget {
  const _Display();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Card',
          note:
              'rounded-xl (14px) with py-6 on the card and px-6 on each slot, '
              'so a full-bleed child can still span edge to edge.',
          child: CairnCard(
            width: 380,
            children: <Widget>[
              const CairnCardHeader(
                title: Text('Deploy your project'),
                description: Text('Ship to production in one click.'),
              ),
              const CairnCardContent(
                child: Text(
                  'Your changes have been reviewed and are ready to go live.',
                ),
              ),
              CairnCardFooter(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  CairnButton(
                    onPressed: () {},
                    child: const Text('Deploy'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Demo(
          title: 'Badge',
          note:
              'A transparent 1px border on filled variants keeps their outer '
              'size identical to the outline variant.',
          child: DemoRow(
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
              CairnBadge(
                leading: CairnIcon(CairnIconData.check, size: 12),
                label: Text('Verified'),
              ),
            ],
          ),
        ),
        const Demo(
          title: 'Avatar',
          child: DemoRow(
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
        ),
        const Demo(
          title: 'Alert',
          note:
              'The icon is nudged down 2px (translate-y-0.5) so it aligns to '
              'the title cap height rather than its line box.',
          child: SizedBox(
            width: 440,
            child: Column(
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
                  description: Text('Update your billing details to continue.'),
                ),
              ],
            ),
          ),
        ),
        const Demo(
          title: 'Separator, Skeleton, Spinner and Kbd',
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: <Widget>[
                CairnSeparator(),
                DemoRow(
                  children: <Widget>[
                    CairnSkeleton.circle(size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: <Widget>[
                        CairnSkeleton(width: 200, height: 12),
                        CairnSkeleton(width: 140, height: 12),
                      ],
                    ),
                  ],
                ),
                DemoRow(
                  spacing: 20,
                  children: <Widget>[
                    CairnSpinner(),
                    CairnSpinner(size: 24),
                    CairnKbdGroup(keys: <String>['Ctrl', 'K']),
                  ],
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Table',
          note: 'Cells are p-2 and the header row is h-10 - tighter than a '
              'Material DataTable.',
          child: SizedBox(
            width: 480,
            child: CairnTable<_Invoice>(
              caption: const Text('A list of recent invoices.'),
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
                  cell: (_Invoice i) => CairnBadge(
                    variant: i.status == 'Paid'
                        ? CairnBadgeVariant.primary
                        : CairnBadgeVariant.secondary,
                    label: Text(i.status),
                  ),
                ),
                CairnColumn<_Invoice>(
                  label: 'Amount',
                  alignment: Alignment.centerRight,
                  cell: (_Invoice i) => Text(i.amount),
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Aspect Ratio and Empty',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: <Widget>[
                CairnAspectRatio(
                  ratio: 16 / 9,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CairnTheme.of(context).muted,
                      borderRadius: BorderRadius.circular(
                        CairnTheme.of(context).radiusScale.md,
                      ),
                    ),
                    child: const Center(child: Text('16 : 9')),
                  ),
                ),
                CairnEmpty(
                  media: const CairnIcon(CairnIconData.search, size: 32),
                  title: 'No results',
                  description:
                      'Try adjusting your filters, or clear them to start '
                      'over.',
                  actions: <Widget>[
                    CairnButton(
                      variant: CairnButtonVariant.outline,
                      onPressed: () {},
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Invoice {
  const _Invoice(this.id, this.status, this.amount);

  final String id;
  final String status;
  final String amount;
}
