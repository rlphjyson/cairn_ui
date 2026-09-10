import 'package:flutter/widgets.dart';

import '../../internal/icons.dart';
import '../../internal/interaction.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// One crumb in a [CairnBreadcrumb].
@immutable
class CairnCrumb {
  /// Creates a navigable crumb.
  const CairnCrumb({required this.label, this.onTap, this.icon});

  /// Creates the non-navigable current-page crumb.
  ///
  /// Rendered `font-normal text-foreground` and marked `aria-current="page"`.
  const CairnCrumb.current({required this.label, this.icon}) : onTap = null;

  /// The crumb's text.
  final String label;

  /// Called when the crumb is activated. Null marks it as the current page.
  final VoidCallback? onTap;

  /// An optional leading icon.
  final Widget? icon;
}

/// A navigation trail matching shadcn/ui's `Breadcrumb`.
///
/// `flex flex-wrap items-center gap-1.5 text-sm text-muted-foreground
/// sm:gap-2.5` — crumbs are muted, the current page is `text-foreground`, and
/// separators are `size-3.5` chevrons.
///
/// The gap widens from 6 to 10 logical pixels at Tailwind's `sm` breakpoint
/// (640px), which is reproduced here from the ambient [MediaQuery].
///
/// ```dart
/// CairnBreadcrumb(
///   crumbs: [
///     CairnCrumb(label: 'Home', onTap: () {}),
///     CairnCrumb(label: 'Settings', onTap: () {}),
///     const CairnCrumb.current(label: 'Profile'),
///   ],
/// );
/// ```
class CairnBreadcrumb extends StatelessWidget {
  /// Creates a breadcrumb trail.
  const CairnBreadcrumb({super.key, required this.crumbs, this.separator});

  /// The crumbs, root first.
  final List<CairnCrumb> crumbs;

  /// Overrides the default chevron separator.
  final Widget? separator;

  /// Tailwind's `sm` breakpoint.
  static const double _smBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= _smBreakpoint;
    // `gap-1.5 sm:gap-2.5`.
    final double gap = wide ? CairnSpacing.s2p5 : CairnSpacing.s1p5;

    return Semantics(
      container: true,
      label: 'Breadcrumb',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: gap,
        runSpacing: gap,
        children: <Widget>[
          for (int i = 0; i < crumbs.length; i++) ...<Widget>[
            _Crumb(crumb: crumbs[i]),
            if (i != crumbs.length - 1)
              separator ??
                  CairnIcon(
                    CairnIconData.chevronRight,
                    // `[&>svg]:size-3.5`.
                    size: 14,
                    color: theme.mutedForeground,
                  ),
          ],
        ],
      ),
    );
  }
}

/// A single crumb.
class _Crumb extends StatelessWidget {
  const _Crumb({required this.crumb});

  final CairnCrumb crumb;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isCurrent = crumb.onTap == null;

    if (isCurrent) {
      return Semantics(
        header: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: CairnSpacing.s1p5,
          children: <Widget>[
            if (crumb.icon != null)
              IconTheme(
                data: IconThemeData(color: theme.foreground, size: 16),
                child: crumb.icon!,
              ),
            Text(
              crumb.label,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(
                    fontWeight: CairnTypography.normal,
                    color: theme.foreground,
                  ),
            ),
          ],
        ),
      );
    }

    return CairnInteractive(
      onTap: crumb.onTap,
      isButton: false,
      semanticLabel: crumb.label,
      builder: (BuildContext context, CairnStates states) =>
          AnimatedDefaultTextStyle(
            duration: CairnMotion.d150,
            curve: CairnMotion.standard,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  // `transition-colors hover:text-foreground`.
                  color: states.hovered || states.focused
                      ? theme.foreground
                      : theme.mutedForeground,
                ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: CairnSpacing.s1p5,
              children: <Widget>[
                if (crumb.icon != null)
                  IconTheme(
                    data: IconThemeData(
                      color: states.hovered
                          ? theme.foreground
                          : theme.mutedForeground,
                      size: 16,
                    ),
                    child: crumb.icon!,
                  ),
                Text(crumb.label),
              ],
            ),
          ),
    );
  }
}

/// The truncation marker for a long trail — `flex size-9 items-center`.
class CairnBreadcrumbEllipsis extends StatelessWidget {
  /// Creates a breadcrumb ellipsis.
  const CairnBreadcrumbEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Semantics(
      label: 'More',
      child: SizedBox.square(
        dimension: 36.0,
        child: Center(
          child: CairnIcon(
            CairnIconData.moreHorizontal,
            color: theme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
