import 'package:flutter/widgets.dart';

/// Cairn's transition durations and easing curves.
///
/// The default is `150ms` on a `cubic-bezier(0.4, 0, 0.2, 1)` curve — an
/// asymmetric ease that leaves quickly and arrives slowly, which is what makes
/// a hover or press state feel responsive rather than sluggish. Note that this
/// is *not* the CSS keyword `ease-in-out` (`cubic-bezier(0.42, 0, 0.58, 1)`),
/// which is symmetric and reads as noticeably lazier on short transitions.
///
/// Individual components override the duration where the distance travelled
/// justifies it: Dialog and Alert Dialog use 200ms, Accordion animates its
/// height over 200ms, and Sheet is deliberately asymmetric — 500ms to open,
/// 300ms to close.
///
/// Flutter ships no built-in [Curve] with those control points, so [standard]
/// constructs one with [Cubic].
abstract final class CairnMotion {
  /// `duration-75`.
  static const Duration d75 = Duration(milliseconds: 75);

  /// `duration-100`.
  static const Duration d100 = Duration(milliseconds: 100);

  /// `duration-150` — Tailwind's `transition` default.
  static const Duration d150 = Duration(milliseconds: 150);

  /// `duration-200` — Dialog, Alert Dialog, Accordion, Popover.
  static const Duration d200 = Duration(milliseconds: 200);

  /// `duration-300` — Sheet and Drawer closing.
  static const Duration d300 = Duration(milliseconds: 300);

  /// `duration-500` — Sheet and Drawer opening.
  static const Duration d500 = Duration(milliseconds: 500);

  /// `duration-1000` — the Input OTP caret blink.
  static const Duration d1000 = Duration(milliseconds: 1000);

  /// Tailwind's default easing, `cubic-bezier(0.4, 0, 0.2, 1)`.
  ///
  /// Applied to colour, shadow and transform transitions across the library.
  /// Identical in value to Flutter's [Curves.fastOutSlowIn]'s intent but
  /// spelled out so the provenance is unambiguous.
  static const Cubic standard = Cubic(0.4, 0.0, 0.2, 1.0);

  /// `ease-out` — `cubic-bezier(0, 0, 0.2, 1)`. Entrance transitions.
  static const Cubic easeOut = Cubic(0.0, 0.0, 0.2, 1.0);

  /// `ease-in` — `cubic-bezier(0.4, 0, 1, 1)`. Exit transitions.
  static const Cubic easeIn = Cubic(0.4, 0.0, 1.0, 1.0);

  /// `linear` — used by the Spinner and the indeterminate Progress sweep.
  static const Curve linear = Curves.linear;

  /// The `animate-pulse` keyframe duration used by Skeleton (`2s`).
  static const Duration pulse = Duration(seconds: 2);

  /// The `animate-spin` rotation period used by Spinner (`1s`).
  static const Duration spin = Duration(seconds: 1);
}
