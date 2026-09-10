import 'package:flutter/widgets.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A keyboard shortcut chip matching shadcn/ui's `Kbd`.
///
/// `pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center
/// gap-1 rounded-sm bg-muted px-1 font-sans text-xs font-medium
/// text-muted-foreground select-none` — a 20 logical pixel tall chip with a
/// `min-w-5` so a single character still renders square.
///
/// Note `font-sans`: shadcn/ui deliberately does *not* use a monospace face
/// here, despite this being a `<kbd>` element.
///
/// ```dart
/// const CairnKbdGroup(keys: ['Ctrl', 'K']);
/// ```
class CairnKbd extends StatelessWidget {
  /// Creates a single key chip.
  const CairnKbd(this.label, {super.key});

  /// The key's text, such as `Ctrl` or `K`.
  final String label;

  /// `h-5` and `min-w-5`.
  static const double _extent = 20.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      height: _extent,
      constraints: const BoxConstraints(minWidth: _extent),
      padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.muted,
        borderRadius: BorderRadius.circular(theme.radiusScale.sm),
      ),
      child: Text(
        label,
        style: theme
            .textStyle(CairnTypography.xs)
            .copyWith(
              fontWeight: CairnTypography.medium,
              color: theme.mutedForeground,
              height: CairnTypography.leadingNone,
            ),
      ),
    );
  }
}

/// A run of [CairnKbd] chips — `inline-flex items-center gap-1`.
class CairnKbdGroup extends StatelessWidget {
  /// Creates a group of key chips.
  const CairnKbdGroup({super.key, required this.keys});

  /// The keys, in press order.
  final List<String> keys;

  @override
  Widget build(BuildContext context) => Semantics(
    label: keys.join(' plus '),
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: CairnSpacing.s1,
      children: <Widget>[for (final String k in keys) CairnKbd(k)],
    ),
  );
}
