import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// One section of a [CairnAccordion].
@immutable
class CairnAccordionItem {
  /// Creates an accordion section.
  const CairnAccordionItem({
    required this.value,
    required this.title,
    required this.content,
    this.enabled = true,
  });

  /// A unique identifier for this section.
  final String value;

  /// The always-visible header.
  final Widget title;

  /// The collapsible body.
  final Widget content;

  /// Whether the section can be toggled.
  final bool enabled;
}

/// A vertical stack of collapsible sections.
///
/// Each item is separated by `border-b last:border-b-0`. The trigger is
/// `flex flex-1 items-start justify-between gap-4 py-4 text-sm font-medium`
/// with a `size-4 text-muted-foreground` chevron that rotates 180 degrees over
/// 200ms when open. The body is `pt-0 pb-4`.
///
/// Note the trigger uses `items-start`, not `items-center` — with a wrapping
/// multi-line title the chevron stays aligned to the first line rather than
/// drifting to the vertical middle. The chevron also carries
/// `translate-y-0.5` for optical alignment.
///
/// ```dart
/// CairnAccordion(
///   expanded: openSections,
///   onChanged: (v) => setState(() => openSections = v),
///   items: const [
///     CairnAccordionItem(
///       value: 'a',
///       title: Text('Is it accessible?'),
///       content: Text('Yes. It follows the WAI-ARIA pattern.'),
///     ),
///   ],
/// );
/// ```
class CairnAccordion extends StatelessWidget {
  /// Creates an accordion.
  const CairnAccordion({
    super.key,
    required this.items,
    required this.expanded,
    this.onChanged,
    this.multiple = false,
  });

  /// The sections.
  final List<CairnAccordionItem> items;

  /// The values of the currently open sections.
  final Set<String> expanded;

  /// Called with the next open set.
  final ValueChanged<Set<String>>? onChanged;

  /// Whether more than one section may be open at once.
  ///
  /// Single mode closes the open section when another is opened, which keeps
  /// the control's height predictable; multiple mode lets any number of
  /// sections stand open at once.
  final bool multiple;

  void _toggle(String value) {
    if (onChanged == null) return;
    final Set<String> next = Set<String>.of(expanded);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      if (!multiple) next.clear();
      next.add(value);
    }
    onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < items.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              border: i == items.length - 1
                  // `last:border-b-0`.
                  ? null
                  : Border(bottom: BorderSide(color: theme.border)),
            ),
            child: _AccordionSection(
              item: items[i],
              open: expanded.contains(items[i].value),
              onToggle: items[i].enabled && onChanged != null
                  ? () => _toggle(items[i].value)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// A single expandable section.
class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.item,
    required this.open,
    required this.onToggle,
  });

  final CairnAccordionItem item;
  final bool open;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CairnInteractive(
          enabled: onToggle != null,
          onTap: onToggle,
          builder: (BuildContext context, CairnStates states) => Opacity(
            opacity: states.disabled ? 0.5 : 1.0,
            // The trigger has no fill, so the focus ring must be clipped to
            // its exterior or it paints over the title.
            child: CairnShadowed(
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
              shadows: states.focused ? theme.focusRing : const <BoxShadow>[],
              child: Container(
                // `py-4`.
                padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(theme.radiusScale.md),
                ),
                child: Row(
                  // `items-start` keeps the chevron on the first line.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CairnSpacing.s4,
                  children: <Widget>[
                    Expanded(
                      child: DefaultTextStyle(
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              fontWeight: CairnTypography.medium,
                              color: theme.foreground,
                              decoration: states.hovered
                                  ? TextDecoration.underline
                                  : null,
                              decorationColor: theme.foreground,
                            ),
                        child: item.title,
                      ),
                    ),
                    // `translate-y-0.5` optical nudge.
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AnimatedRotation(
                        turns: open ? 0.5 : 0.0,
                        duration: CairnMotion.d200,
                        curve: CairnMotion.standard,
                        child: CairnIcon(
                          CairnIconData.chevronDown,
                          color: theme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // `animate-accordion-down` / `-up` over 200ms.
        AnimatedSize(
          duration: CairnMotion.d200,
          curve: CairnMotion.standard,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  // `pt-0 pb-4`.
                  padding: const EdgeInsets.only(bottom: CairnSpacing.s4),
                  child: DefaultTextStyle(
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(color: theme.foreground),
                    child: item.content,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// A single show/hide region.
///
/// This is the primitive the Accordion is built on. It carries no chrome of its
/// own — it only animates its child's height over the same 200ms curve — so it
/// drops into whatever surface the caller already has.
class CairnCollapsible extends StatelessWidget {
  /// Creates a collapsible region.
  const CairnCollapsible({
    super.key,
    required this.open,
    required this.child,
    this.trigger,
    this.onToggle,
  });

  /// Whether the region is expanded.
  final bool open;

  /// The collapsible content.
  final Widget child;

  /// An optional always-visible trigger.
  final Widget? trigger;

  /// Called when the trigger is activated.
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      if (trigger != null)
        CairnInteractive(
          enabled: onToggle != null,
          onTap: onToggle,
          builder: (BuildContext context, CairnStates states) => trigger!,
        ),
      AnimatedSize(
        duration: CairnMotion.d200,
        curve: CairnMotion.standard,
        alignment: Alignment.topCenter,
        child: open ? child : const SizedBox(width: double.infinity),
      ),
    ],
  );
}
