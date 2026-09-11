import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/shadows.dart';
import '../toggle/toggle.dart';

/// Whether a [CairnToggleGroup] allows one or many selections.
enum CairnToggleGroupType {
  /// At most one item may be selected, like a radio group.
  single,

  /// Any number of items may be selected.
  multiple,
}

/// A set of related toggles, joined or spaced.
///
/// `flex w-fit items-center rounded-md`, with the joined (`data-[spacing=0]`)
/// presentation squaring off inner corners so the group reads as one control:
/// `first:rounded-l-md last:rounded-r-md` plus `border-l-0` on all but the
/// first item, which prevents the doubled 2px seam you would otherwise get
/// where two 1px borders meet.
///
/// ```dart
/// CairnToggleGroup<String>(
///   type: CairnToggleGroupType.single,
///   values: {alignment},
///   onChanged: (v) => setState(() => alignment = v.firstOrNull ?? 'left'),
///   items: const [
///     CairnToggleGroupItem(value: 'left', child: Text('Left')),
///     CairnToggleGroupItem(value: 'center', child: Text('Center')),
///   ],
/// );
/// ```
class CairnToggleGroup<T> extends StatelessWidget {
  /// Creates a toggle group.
  const CairnToggleGroup({
    super.key,
    required this.values,
    required this.items,
    this.onChanged,
    this.type = CairnToggleGroupType.single,
    this.variant = CairnToggleVariant.normal,
    this.size = CairnToggleSize.md,
    this.joined = true,
    this.spacing = 0.0,
    this.semanticLabel,
  });

  /// The currently selected values.
  final Set<T> values;

  /// The items in this group.
  final List<CairnToggleGroupItem<T>> items;

  /// Called with the next selection set.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether one or many items may be selected.
  final CairnToggleGroupType type;

  /// The visual style applied to every item.
  final CairnToggleVariant variant;

  /// The size applied to every item.
  final CairnToggleSize size;

  /// Whether items are visually joined into one control.
  final bool joined;

  /// The gap between items when not [joined].
  final double spacing;

  /// The accessible name for the group.
  final String? semanticLabel;

  void _handle(T value) {
    if (onChanged == null) return;
    final Set<T> next = Set<T>.of(values);
    switch (type) {
      case CairnToggleGroupType.single:
        next
          ..clear()
          ..addAll(values.contains(value) ? <T>{} : <T>{value});
      case CairnToggleGroupType.multiple:
        if (!next.remove(value)) next.add(value);
    }
    onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(theme.radiusScale.md);

    if (!joined) {
      return Semantics(
        container: true,
        label: semanticLabel,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: <Widget>[
            for (final CairnToggleGroupItem<T> item in items)
              CairnToggle(
                value: values.contains(item.value),
                onChanged: onChanged == null || !item.enabled
                    ? null
                    : (_) => _handle(item.value),
                variant: variant,
                size: size,
                semanticLabel: item.semanticLabel,
                child: item.child,
              ),
          ],
        ),
      );
    }

    // Joined: clip the whole row once and draw a single outer border, so inner
    // seams are a single hairline rather than two adjacent borders.
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: variant == CairnToggleVariant.outline
              ? Border.all(color: theme.input)
              : null,
          boxShadow: variant == CairnToggleVariant.outline
              ? CairnShadows.xs
              : null,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                if (i > 0 && variant == CairnToggleVariant.outline)
                  SizedBox(
                    width: 1,
                    height: switch (size) {
                      CairnToggleSize.sm => 30.0,
                      CairnToggleSize.md => 34.0,
                      CairnToggleSize.lg => 38.0,
                    },
                    child: ColoredBox(color: theme.input),
                  ),
                CairnToggle(
                  value: values.contains(items[i].value),
                  onChanged: onChanged == null || !items[i].enabled
                      ? null
                      : (_) => _handle(items[i].value),
                  // The group draws the border; items must not double it.
                  variant: CairnToggleVariant.normal,
                  size: size,
                  semanticLabel: items[i].semanticLabel,
                  child: items[i].child,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One option inside a [CairnToggleGroup].
@immutable
class CairnToggleGroupItem<T> {
  /// Creates a toggle group item.
  const CairnToggleGroupItem({
    required this.value,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The value this item represents.
  final T value;

  /// The item's content.
  final Widget child;

  /// Whether this item is selectable.
  final bool enabled;

  /// The accessible name.
  final String? semanticLabel;
}
