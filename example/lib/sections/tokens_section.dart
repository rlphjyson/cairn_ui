import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

/// The design token layer, rendered directly.
abstract final class TokensSection {
  /// Builds the section.
  static Widget build(BuildContext context) => const _Tokens();
}

class _Tokens extends StatelessWidget {
  const _Tokens();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Demo(
          title: 'Semantic colours',
          note:
              'shadcn/ui\'s Neutral base, authored in oklch() and converted to '
              'sRGB at build time. The greys land exactly on Tailwind\'s '
              'published neutral ramp.',
          child: Wrap(
            spacing: CairnSpacing.s3,
            runSpacing: CairnSpacing.s3,
            children: <Widget>[
              for (final (String name, Color color, String source)
                  in <(String, Color, String)>[
                    ('background', theme.background, 'oklch(1 0 0)'),
                    ('foreground', theme.foreground, 'oklch(0.145 0 0)'),
                    ('card', theme.card, '--card'),
                    ('popover', theme.popover, '--popover'),
                    ('primary', theme.primary, 'oklch(0.205 0 0)'),
                    (
                      'primary-fg',
                      theme.primaryForeground,
                      'oklch(0.985 0 0)',
                    ),
                    ('secondary', theme.secondary, 'oklch(0.97 0 0)'),
                    ('muted', theme.muted, '--muted'),
                    (
                      'muted-fg',
                      theme.mutedForeground,
                      'oklch(0.556 0 0)',
                    ),
                    ('accent', theme.accent, '--accent'),
                    (
                      'destructive',
                      theme.destructive,
                      'oklch(0.577 0.245 27.325)',
                    ),
                    ('border', theme.border, 'oklch(0.922 0 0)'),
                    ('input', theme.input, '--input'),
                    ('ring', theme.ring, 'oklch(0.708 0 0)'),
                  ])
                _Swatch(name: name, color: color, source: source),
            ],
          ),
        ),
        Demo(
          title: 'Spacing scale',
          note:
              'Tailwind\'s --spacing base is 0.25rem, so at a 16px root every '
              'step is a multiple of 4 logical pixels.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s2,
            children: <Widget>[
              for (final (String label, double value)
                  in <(String, double)>[
                    ('gap-1', CairnSpacing.s1),
                    ('gap-2', CairnSpacing.s2),
                    ('gap-3', CairnSpacing.s3),
                    ('gap-4', CairnSpacing.s4),
                    ('gap-6', CairnSpacing.s6),
                    ('gap-8', CairnSpacing.s8),
                  ])
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      child: Text(
                        label,
                        style: theme
                            .textStyle(CairnTypography.xs)
                            .copyWith(color: theme.mutedForeground),
                      ),
                    ),
                    Container(
                      width: value,
                      height: 16,
                      color: theme.primary,
                    ),
                    const SizedBox(width: CairnSpacing.s2),
                    Text(
                      '${value.toStringAsFixed(0)}px',
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Demo(
          title: 'Radius scale',
          note:
              'Derived from --radius: 0.625rem via the multiplier formula the '
              'current shadcn CLI writes (0.6 / 0.8 / 1 / 1.4).',
          child: Wrap(
            spacing: CairnSpacing.s4,
            runSpacing: CairnSpacing.s4,
            children: <Widget>[
              for (final (String label, double radius)
                  in <(String, double)>[
                    ('sm / 6', CairnRadius.sm),
                    ('md / 8', CairnRadius.md),
                    ('lg / 10', CairnRadius.lg),
                    ('xl / 14', CairnRadius.xl),
                    ('2xl / 18', CairnRadius.xl2),
                    ('full', CairnRadius.full),
                  ])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.muted,
                        border: Border.all(color: theme.border),
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                    const SizedBox(height: CairnSpacing.s2),
                    Text(
                      label,
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Demo(
          title: 'Type scale',
          note:
              'rem line heights become Flutter height multiples, so intrinsic '
              'heights stay correct when the user scales text.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s3,
            children: <Widget>[
              for (final (String label, TextStyle style)
                  in <(String, TextStyle)>[
                    ('text-xs / 12', CairnTypography.xs),
                    ('text-sm / 14', CairnTypography.sm),
                    ('text-base / 16', CairnTypography.base),
                    ('text-lg / 18', CairnTypography.lg),
                    ('text-xl / 20', CairnTypography.xl),
                    ('text-2xl / 24', CairnTypography.xl2),
                  ])
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      child: Text(
                        label,
                        style: theme
                            .textStyle(CairnTypography.xs)
                            .copyWith(color: theme.mutedForeground),
                      ),
                    ),
                    Text(
                      'The quick brown fox',
                      style: theme
                          .textStyle(style)
                          .copyWith(color: theme.foreground),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Demo(
          title: 'Shadow scale',
          note:
              'CSS blur is a Gaussian of half the stated radius; Flutter\'s is '
              'radius * 0.57735 + 0.5. Cairn inverts that so a shadow renders '
              'at the sigma a browser would produce.',
          child: Wrap(
            spacing: CairnSpacing.s6,
            runSpacing: CairnSpacing.s6,
            children: <Widget>[
              for (final (String label, List<BoxShadow> shadow)
                  in <(String, List<BoxShadow>)>[
                    ('xs', CairnShadows.xs),
                    ('sm', CairnShadows.sm),
                    ('md', CairnShadows.md),
                    ('lg', CairnShadows.lg),
                    ('xl', CairnShadows.xl),
                  ])
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.card,
                        border: Border.all(color: theme.border),
                        borderRadius: BorderRadius.circular(
                          theme.radiusScale.md,
                        ),
                        boxShadow: shadow,
                      ),
                    ),
                    const SizedBox(height: CairnSpacing.s3),
                    Text(
                      'shadow-$label',
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(color: theme.mutedForeground),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.name,
    required this.color,
    required this.source,
  });

  final String name;
  final Color color;
  final String source;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(theme.radiusScale.md),
            ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          Text(
            name,
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(
                  fontWeight: CairnTypography.medium,
                  color: theme.foreground,
                ),
          ),
          Text(
            source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(color: theme.mutedForeground),
          ),
        ],
      ),
    );
  }
}
