import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// Progress, notifications and data components.
abstract final class FeedbackSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Feedback();
}

class _Feedback extends StatefulWidget {
  const _Feedback();

  @override
  State<_Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<_Feedback> {
  double _progress = 0.45;
  DateTime? _date;

  static final List<_Payment> _payments = <_Payment>[
    const _Payment('ken99@example.com', 'Success', 316.00),
    const _Payment('abe45@example.com', 'Success', 242.00),
    const _Payment('monserrat44@example.com', 'Processing', 837.00),
    const _Payment('silas22@example.com', 'Failed', 874.00),
    const _Payment('carmella@example.com', 'Success', 721.00),
    const _Payment('jason78@example.com', 'Processing', 450.00),
    const _Payment('nora12@example.com', 'Success', 129.00),
    const _Payment('devon@example.com', 'Failed', 98.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Progress',
          note:
              'The track is the primary colour at 20% alpha, not the muted '
              'token.',
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s4,
              children: <Widget>[
                CairnProgress(value: _progress, semanticLabel: 'Upload'),
                const CairnProgress(semanticLabel: 'Indeterminate'),
                Row(
                  spacing: CairnSpacing.s2,
                  children: <Widget>[
                    CairnButton(
                      variant: CairnButtonVariant.outline,
                      size: CairnButtonSize.sm,
                      onPressed: () => setState(
                        () => _progress = (_progress - 0.1).clamp(0.0, 1.0),
                      ),
                      child: const Text('-10%'),
                    ),
                    CairnButton(
                      variant: CairnButtonVariant.outline,
                      size: CairnButtonSize.sm,
                      onPressed: () => setState(
                        () => _progress = (_progress + 0.1).clamp(0.0, 1.0),
                      ),
                      child: const Text('+10%'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Toast notifications',
          note:
              'The toast host lives above every route, so a toast outlives '
              'the screen that fired it.',
          child: DemoRow(
            children: <Widget>[
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => CairnToast.show(
                  context,
                  const CairnToast(
                    title: 'Event created',
                    description: 'Friday, 12 September at 9:00 AM.',
                  ),
                ),
                child: const Text('Default'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => CairnToast.show(
                  context,
                  const CairnToast(
                    variant: CairnToastVariant.success,
                    title: 'Changes saved',
                    description: 'Your profile is up to date.',
                  ),
                ),
                child: const Text('Success'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => CairnToast.show(
                  context,
                  const CairnToast(
                    variant: CairnToastVariant.error,
                    title: 'Something went wrong',
                    description: 'Your changes were not saved.',
                  ),
                ),
                child: const Text('Error'),
              ),
              CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => CairnToast.show(
                  context,
                  CairnToast(
                    variant: CairnToastVariant.info,
                    title: 'Update available',
                    description: 'Version 0.2.0 is ready to install.',
                    action: 'Install',
                    onActionPressed: () {},
                  ),
                ),
                child: const Text('With action'),
              ),
            ],
          ),
        ),
        Demo(
          title: 'Data Table',
          note:
              'Built on CairnTable rather than rendering separately. Sortable '
              'columns are opt-in via a sortKey; sorting copies the list '
              'instead of mutating the caller\'s.',
          child: SizedBox(
            width: 620,
            child: CairnDataTable<_Payment>(
              rows: _payments,
              pageSize: 4,
              searchBy: (_Payment p) => p.email,
              searchPlaceholder: 'Filter emails...',
              columns: <CairnColumn<_Payment>>[
                CairnColumn<_Payment>(
                  label: 'Email',
                  flex: 3,
                  cell: (_Payment p) => Text(p.email),
                  sortKey: (_Payment p) => p.email,
                ),
                CairnColumn<_Payment>(
                  label: 'Status',
                  flex: 2,
                  cell: (_Payment p) => CairnBadge(
                    variant: switch (p.status) {
                      'Success' => CairnBadgeVariant.primary,
                      'Failed' => CairnBadgeVariant.destructive,
                      _ => CairnBadgeVariant.secondary,
                    },
                    label: Text(p.status),
                  ),
                  sortKey: (_Payment p) => p.status,
                ),
                CairnColumn<_Payment>(
                  label: 'Amount',
                  flex: 2,
                  alignment: Alignment.centerRight,
                  cell: (_Payment p) =>
                      Text('\$${p.amount.toStringAsFixed(2)}'),
                  sortKey: (_Payment p) => p.amount,
                ),
              ],
            ),
          ),
        ),
        Demo(
          title: 'Calendar and Date Picker',
          note:
              'The grid is a fixed 7 x 6, so paging between months never '
              'changes the popover height.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s6,
            children: <Widget>[
              CairnDatePicker(
                value: _date,
                onChanged: (DateTime d) => setState(() => _date = d),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: CairnTheme.of(context).border),
                  borderRadius: BorderRadius.circular(
                    CairnTheme.of(context).radiusScale.lg,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(CairnSpacing.s3),
                  child: CairnCalendar(
                    selected: _date,
                    onChanged: (DateTime d) => setState(() => _date = d),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Payment {
  const _Payment(this.email, this.status, this.amount);

  final String email;
  final String status;
  final double amount;
}
