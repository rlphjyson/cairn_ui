import 'dart:math' as math;
import 'dart:ui' show Color;

/// Converts colors expressed in the CSS `oklch()` color function into
/// Flutter [Color] values.
///
/// shadcn/ui migrated its default theme from HSL to OKLCH. Every semantic color
/// token in [CairnColors] is therefore authored as an `oklch()` triple, exactly
/// as it appears in shadcn/ui's registry, and converted here.
///
/// Keeping the conversion in the package (rather than pasting pre-computed hex
/// values) means the provenance of every color is checkable: the doc comment on
/// each token records the literal `oklch()` string from shadcn/ui's source, and
/// `test/tokens/oklch_test.dart` re-derives the baked constants from it.
///
/// The pipeline is the standard one from Björn Ottosson's OKLab specification:
///
/// ```text
/// OKLCH -> OKLab -> LMS' -> LMS -> linear sRGB -> gamma-encoded sRGB
/// ```
///
/// Out-of-gamut results are clipped per channel, which matches how browsers
/// render these particular tokens (all of shadcn/ui's defaults are in-gamut for
/// sRGB, so clipping is a safety net rather than a routine operation).
abstract final class Oklch {
  /// Converts an `oklch(L C H)` triple to a [Color].
  ///
  /// [l] is perceptual lightness in the range 0..1, [c] is chroma (0 for the
  /// achromatic greys that make up most of shadcn/ui's neutral base), and [h]
  /// is the hue angle in degrees. [opacity] maps to the `/ <alpha>` component
  /// of the CSS function and defaults to fully opaque.
  ///
  /// ```dart
  /// // --background: oklch(1 0 0)  ->  #FFFFFF
  /// Oklch.toColor(1, 0, 0);
  /// ```
  static Color toColor(double l, double c, double h, {double opacity = 1.0}) {
    // OKLCH (polar) -> OKLab (cartesian).
    final double hRad = h * math.pi / 180.0;
    final double a = c * math.cos(hRad);
    final double b = c * math.sin(hRad);

    // OKLab -> non-linear LMS.
    final double lPrime = l + 0.3963377774 * a + 0.2158037573 * b;
    final double mPrime = l - 0.1055613458 * a - 0.0638541728 * b;
    final double sPrime = l - 0.0894841775 * a - 1.2914855480 * b;

    // Undo the cube-root compression.
    final double lLms = lPrime * lPrime * lPrime;
    final double mLms = mPrime * mPrime * mPrime;
    final double sLms = sPrime * sPrime * sPrime;

    // LMS -> linear sRGB.
    final double rLin =
        4.0767416621 * lLms - 3.3077115913 * mLms + 0.2309699292 * sLms;
    final double gLin =
        -1.2684380046 * lLms + 2.6097574011 * mLms - 0.3413193965 * sLms;
    final double bLin =
        -0.0041960863 * lLms - 0.7034186147 * mLms + 1.7076147010 * sLms;

    return Color.fromARGB(
      (opacity.clamp(0.0, 1.0) * 255).round(),
      _encode(rLin),
      _encode(gLin),
      _encode(bLin),
    );
  }

  /// Applies the sRGB transfer function and quantises to an 8-bit channel.
  static int _encode(double linear) {
    final double clamped = linear.clamp(0.0, 1.0);
    final double encoded = clamped <= 0.0031308
        ? 12.92 * clamped
        : 1.055 * math.pow(clamped, 1 / 2.4) - 0.055;
    return (encoded * 255).round().clamp(0, 255);
  }
}
