import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Oklch conversion', () {
    /// Every constant in [CairnColors] is baked as a literal so it can be
    /// `const`. These tests re-derive each one from the `oklch()` string that
    /// appears in shadcn/ui's registry, which is what makes the baked values
    /// verifiable rather than merely asserted.
    void expectOklch(
      String label,
      double l,
      double c,
      double h,
      Color expected, {
      double opacity = 1.0,
    }) {
      test('$label = oklch($l $c $h)', () {
        expect(Oklch.toColor(l, c, h, opacity: opacity), expected);
      });
    }

    expectOklch('background', 1, 0, 0, CairnColors.lightBackground);
    expectOklch('foreground', 0.145, 0, 0, CairnColors.lightForeground);
    expectOklch('primary', 0.205, 0, 0, CairnColors.lightPrimary);
    expectOklch(
      'primary-foreground',
      0.985,
      0,
      0,
      CairnColors.lightPrimaryForeground,
    );
    expectOklch('secondary', 0.97, 0, 0, CairnColors.lightSecondary);
    expectOklch(
      'muted-foreground',
      0.556,
      0,
      0,
      CairnColors.lightMutedForeground,
    );
    expectOklch('border', 0.922, 0, 0, CairnColors.lightBorder);
    expectOklch('ring', 0.708, 0, 0, CairnColors.lightRing);
    expectOklch(
      'destructive (light)',
      0.577,
      0.245,
      27.325,
      CairnColors.lightDestructive,
    );

    expectOklch('dark background', 0.145, 0, 0, CairnColors.darkBackground);
    expectOklch('dark primary', 0.922, 0, 0, CairnColors.darkPrimary);
    expectOklch('dark secondary', 0.269, 0, 0, CairnColors.darkSecondary);
    expectOklch(
      'dark destructive',
      0.704,
      0.191,
      22.216,
      CairnColors.darkDestructive,
    );
    expectOklch('chart-3', 0.439, 0, 0, CairnColors.chart3);
    expectOklch('chart-4', 0.371, 0, 0, CairnColors.chart4);

    test('dark border is oklch(1 0 0 / 10%)', () {
      expect(Oklch.toColor(1, 0, 0, opacity: 0.10), CairnColors.darkBorder);
    });

    test('dark input is oklch(1 0 0 / 15%)', () {
      expect(Oklch.toColor(1, 0, 0, opacity: 0.15), CairnColors.darkInput);
    });

    test('lands exactly on Tailwind\'s published neutral ramp', () {
      // An independent cross-check: shadcn/ui's OKLCH lightness steps are the
      // same colours as Tailwind's `neutral` palette hex values. If the OKLab
      // pipeline were subtly wrong these would drift by a few units.
      expect(Oklch.toColor(0.985, 0, 0), const Color(0xFFFAFAFA)); // neutral-50
      expect(Oklch.toColor(0.97, 0, 0), const Color(0xFFF5F5F5)); // neutral-100
      expect(Oklch.toColor(0.922, 0, 0), const Color(0xFFE5E5E5)); // -200
      expect(Oklch.toColor(0.87, 0, 0), const Color(0xFFD4D4D4)); // -300
      expect(Oklch.toColor(0.708, 0, 0), const Color(0xFFA1A1A1)); // -400
      expect(Oklch.toColor(0.556, 0, 0), const Color(0xFF737373)); // -500
      expect(Oklch.toColor(0.439, 0, 0), const Color(0xFF525252)); // -600
      expect(Oklch.toColor(0.371, 0, 0), const Color(0xFF404040)); // -700
      expect(Oklch.toColor(0.269, 0, 0), const Color(0xFF262626)); // -800
      expect(Oklch.toColor(0.205, 0, 0), const Color(0xFF171717)); // -900
      expect(Oklch.toColor(0.145, 0, 0), const Color(0xFF0A0A0A)); // -950
    });

    test('clips out-of-gamut values instead of overflowing', () {
      // A chroma far beyond sRGB should clamp per channel, not wrap.
      final Color c = Oklch.toColor(0.5, 0.9, 140);
      expect(c.a, 1.0);
      expect(c.r, inInclusiveRange(0.0, 1.0));
      expect(c.g, inInclusiveRange(0.0, 1.0));
      expect(c.b, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Spacing scale', () {
    test('matches Tailwind\'s 0.25rem base at a 16px root', () {
      expect(CairnSpacing.base, 4.0);
      expect(CairnSpacing.s1, 4.0);
      expect(CairnSpacing.s2, 8.0);
      expect(CairnSpacing.s3, 12.0);
      expect(CairnSpacing.s4, 16.0);
      expect(CairnSpacing.s6, 24.0);
    });

    test('step() resolves fractional Tailwind steps', () {
      expect(CairnSpacing.step(1.5), 6.0);
      expect(CairnSpacing.step(3.5), 14.0);
      expect(CairnSpacing.step(2.5), 10.0);
    });
  });

  group('Radius scale', () {
    test('uses shadcn/ui\'s current multiplier formula', () {
      // --radius: 0.625rem = 10px.
      expect(CairnRadius.base, 10.0);
      expect(CairnRadius.sm, 6.0); // * 0.6
      expect(CairnRadius.md, 8.0); // * 0.8
      expect(CairnRadius.lg, 10.0); // * 1
      expect(CairnRadius.xl, 14.0); // * 1.4
      expect(CairnRadius.xl2, 18.0); // * 1.8
    });

    test('scaled() keeps proportions for a custom --radius', () {
      const CairnRadiusScale tight = CairnRadiusScale(5.0);
      expect(tight.sm, closeTo(3.0, 1e-9));
      expect(tight.md, closeTo(4.0, 1e-9));
      expect(tight.lg, 5.0);
      expect(tight.xl, closeTo(7.0, 1e-9));
    });

    test('multiplier and legacy pixel-offset formulas agree at the default', () {
      // The old formula was calc(var(--radius) - 4px / - 2px / + 4px). It gives
      // identical results at --radius: 10px, which is why the change went
      // largely unnoticed; it only diverges for customised radii.
      const double r = CairnRadius.base;
      expect(CairnRadius.sm, r - 4);
      expect(CairnRadius.md, r - 2);
      expect(CairnRadius.xl, r + 4);
    });
  });

  group('Typography scale', () {
    test('converts rem line heights to Flutter height multiples', () {
      // text-sm is 0.875rem/1.25rem -> 14px on a 20px line -> height 20/14.
      expect(CairnTypography.sm.fontSize, 14.0);
      expect(CairnTypography.sm.height, closeTo(20 / 14, 1e-9));
      expect(CairnTypography.xs.fontSize, 12.0);
      expect(CairnTypography.xs.height, closeTo(16 / 12, 1e-9));
      expect(CairnTypography.lg.fontSize, 18.0);
      expect(CairnTypography.lg.height, closeTo(28 / 18, 1e-9));
    });

    test('tracking is converted from em to absolute pixels', () {
      expect(CairnTypography.trackingTight(16), closeTo(-0.4, 1e-9));
      expect(CairnTypography.trackingWidest(12), closeTo(1.2, 1e-9));
    });
  });

  group('Shadow conversion', () {
    test('inverts Flutter\'s radius-to-sigma formula', () {
      // CSS blur b means Gaussian sigma b/2. Flutter's sigma is
      // radius * 0.57735 + 0.5, so the radius that yields sigma b/2 is
      // (b/2 - 0.5) / 0.57735.
      double flutterSigma(double radius) => radius * 0.57735 + 0.5;

      for (final double cssBlur in <double>[2, 3, 4, 6, 15, 25, 50]) {
        expect(
          flutterSigma(CairnShadows.cssBlur(cssBlur)),
          closeTo(cssBlur / 2, 1e-9),
          reason: 'CSS blur ${cssBlur}px should render at sigma ${cssBlur / 2}',
        );
      }
    });

    test('clamps to zero where the inversion would go negative', () {
      expect(CairnShadows.cssBlur(1), 0.0);
      expect(CairnShadows.cssBlur(0), 0.0);
    });

    test('shadow-sm carries both CSS layers with their spreads', () {
      final List<BoxShadow> sm = CairnShadows.sm;
      expect(sm, hasLength(2));
      expect(sm[0].offset, const Offset(0, 1));
      expect(sm[0].spreadRadius, 0);
      expect(sm[1].offset, const Offset(0, 1));
      expect(sm[1].spreadRadius, -1);
    });

    test('naive copying would be materially wrong', () {
      // Documents why cssBlur exists: pasting the CSS number straight into
      // blurRadius inflates the rendered blur by ~50%.
      const double cssBlur = 6.0;
      final double correct = CairnShadows.cssBlur(cssBlur);
      expect(correct, lessThan(cssBlur));
      expect(correct, closeTo(4.33, 0.01));
    });
  });

  group('CairnTheme', () {
    test('exposes shadcn/ui\'s registry defaults, not the docs site\'s', () {
      // The docs site overrides --foreground and --primary to pure black; the
      // registry (what `npx shadcn init` writes) uses 0.145 / 0.205.
      expect(CairnTheme.light.foreground, const Color(0xFF0A0A0A));
      expect(CairnTheme.light.primary, const Color(0xFF171717));
      expect(CairnTheme.light.foreground, isNot(const Color(0xFF000000)));
    });

    test('focus ring is a 3px hard outset at 50% alpha', () {
      final List<BoxShadow> ring = CairnTheme.light.focusRing;
      expect(ring, hasLength(1));
      expect(ring.single.spreadRadius, 3.0);
      expect(ring.single.blurRadius, 0.0);
      expect(ring.single.offset, Offset.zero);
      expect(ring.single.color.a, closeTo(0.5, 0.01));
    });

    test('invalid ring alpha differs between light and dark', () {
      expect(CairnTheme.light.invalidRing.single.color.a, closeTo(0.2, 0.01));
      expect(CairnTheme.dark.invalidRing.single.color.a, closeTo(0.4, 0.01));
    });

    test('Tailwind\'s /N modifier scales alpha rather than replacing it', () {
      // `bg-primary/90` on an opaque token: scaling and replacing agree.
      expect(
        CairnTheme.light.primary.withOpacityModifier(0.9).a,
        closeTo(0.9, 0.01),
      );

      // `dark:bg-input/30` where --input is already oklch(1 0 0 / 15%).
      // color-mix gives 0.15 * 0.30 = 0.045, not 0.30.
      final Color darkInput = CairnTheme.dark.input;
      expect(darkInput.a, closeTo(0.15, 0.01));
      expect(
        darkInput.withOpacityModifier(0.3).a,
        closeTo(0.045, 0.005),
        reason: 'the modifier multiplies the existing alpha',
      );
      expect(
        darkInput.withOpacityModifier(0.3).a,
        isNot(closeTo(0.3, 0.01)),
        reason: 'replacing the alpha would be six times too strong',
      );
    });

    test('lerp interpolates colours and snaps brightness', () {
      final CairnTheme mid = CairnTheme.light.lerp(CairnTheme.dark, 0.5);
      expect(mid.brightness, Brightness.dark);
      expect(mid.background, isNot(CairnTheme.light.background));
      expect(mid.background, isNot(CairnTheme.dark.background));

      final CairnTheme quarter = CairnTheme.light.lerp(CairnTheme.dark, 0.25);
      expect(quarter.brightness, Brightness.light);
    });

    test('copyWith preserves unspecified slots', () {
      final CairnTheme custom = CairnTheme.light.copyWith(
        primary: const Color(0xFF3B82F6),
        radius: 4.0,
      );
      expect(custom.primary, const Color(0xFF3B82F6));
      expect(custom.radius, 4.0);
      expect(custom.background, CairnTheme.light.background);
      expect(custom.radiusScale.md, closeTo(3.2, 1e-9));
    });

    test('equality and hashCode cover the token set', () {
      expect(CairnTheme.light, equals(CairnTheme.light));
      expect(CairnTheme.light, isNot(equals(CairnTheme.dark)));
      expect(
        CairnTheme.light.hashCode,
        isNot(equals(CairnTheme.dark.hashCode)),
      );
    });
  });
}
