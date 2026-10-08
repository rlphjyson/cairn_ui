import 'package:flutter/widgets.dart';

import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// One destination in a [CairnDock].
@immutable
class CairnDockItem {
  /// Creates a dock item.
  const CairnDockItem({required this.icon, required this.label, this.badge});

  /// The glyph. Sized to 20px by the dock.
  final Widget icon;

  /// The caption, also used as the accessible name.
  final String label;

  /// An optional [CairnBadge] / [CairnStatus] pinned to the icon.
  final Widget? badge;
}

/// A bottom navigation bar for mobile layouts.
///
/// A 64px bar on the `background` surface with a 1px top hairline. Each item is
/// an icon above a 12px label; the selected item takes `foreground` colour and
/// semibold weight with a 2px primary bar above it, while the rest stay
/// `mutedForeground`. Items share the width equally and the whole item is the
/// tap target, which keeps them above the 48px touch minimum.
///
/// Pair with `SafeArea` so the bar clears the home indicator.
///
/// ```dart
/// CairnDock(
///   index: _tab,
///   onChanged: (i) => setState(() => _tab = i),
///   items: const [
///     CairnDockItem(icon: Icon(Icons.home), label: 'Home'),
///     CairnDockItem(icon: Icon(Icons.search), label: 'Search'),
///   ],
/// );
/// ```
class CairnDock extends StatelessWidget {
  /// Creates a dock.
  const CairnDock({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.height = 64.0,
  }) : assert(items.length >= 2, 'a dock needs at least two items');

  /// The destinations.
  final List<CairnDockItem> items;

  /// The selected item.
  final int index;

  /// Called with the tapped item's index.
  final ValueChanged<int> onChanged;

  /// The bar height (`h-16`).
  final double height;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.background,
          border: Border(top: BorderSide(color: theme.border)),
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _DockButton(
                  item: items[i],
                  selected: i == index,
                  onTap: () => onChanged(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CairnDockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final Color color = selected ? theme.foreground : theme.mutedForeground;

    return Semantics(
      selected: selected,
      child: CairnInteractive(
        onTap: onTap,
        semanticLabel: item.label,
        builder: (BuildContext context, CairnStates states) {
          Widget icon = IconTheme(
            data: IconThemeData(color: color, size: 20),
            child: SizedBox.square(dimension: 20, child: item.icon),
          );
          if (item.badge != null) {
            icon = Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                icon,
                Positioned(top: -4, right: -8, child: item.badge!),
              ],
            );
          }
          return DecoratedBox(
            decoration: BoxDecoration(
              color: states.hovered ? theme.accent : null,
              border: Border(
                top: BorderSide(
                  color: selected ? theme.primary : const Color(0x00000000),
                  width: 2,
                ),
              ),
            ),
            child: AnimatedDefaultTextStyle(
              duration: CairnMotion.d150,
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(
                    color: color,
                    fontWeight: selected
                        ? CairnTypography.semibold
                        : CairnTypography.medium,
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: CairnSpacing.s1,
                children: <Widget>[
                  icon,
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
