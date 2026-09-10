import 'package:flutter/widgets.dart';

/// Tailwind CSS's box-shadow scale, translated to Flutter [BoxShadow] lists.
///
/// ## Why this is not a direct field-for-field copy
///
/// CSS and Flutter disagree about what "blur radius" means, so copying the
/// numbers out of `box-shadow` straight into [BoxShadow.blurRadius] produces a
/// visibly softer, larger shadow than the browser draws.
///
/// * **CSS** specifies that a shadow's blur is a Gaussian whose *standard
///   deviation is half the blur-radius value*. So `0 1px 3px` means sigma 1.5.
/// * **Flutter** converts [BoxShadow.blurRadius] to a sigma with
///   `sigma = radius * 0.57735 + 0.5` (`BoxShadow.blurSigma`, inherited from
///   Skia's `convertRadiusToSigma`).
///
/// Setting `blurRadius: 3` in Flutter therefore yields sigma `2.23`, roughly
/// 50% wider than the browser's `1.5`. [cssBlur] inverts Flutter's formula so
/// the rendered sigma matches the CSS one:
///
/// ```text
/// blurRadius = (cssBlurPx / 2 - 0.5) / 0.57735
/// ```
///
/// CSS's fourth `box-shadow` length — spread — maps cleanly onto
/// [BoxShadow.spreadRadius], including the negative spreads Tailwind uses to
/// keep large shadows tight against their element.
abstract final class CairnShadows {
  /// Flutter's `radius -> sigma` coefficient, from `BoxShadow.blurSigma`.
  static const double _sigmaCoefficient = 0.57735;

  /// Flutter's `radius -> sigma` constant term, from `BoxShadow.blurSigma`.
  static const double _sigmaOffset = 0.5;

  /// Converts a CSS blur-radius in px to the [BoxShadow.blurRadius] that makes
  /// Flutter render the same Gaussian sigma a browser would.
  ///
  /// Returns 0 for CSS blurs of 1px or less, where the inverted formula would
  /// go negative — such shadows are effectively hard edges in both engines.
  static double cssBlur(double cssBlurPx) {
    final double targetSigma = cssBlurPx / 2.0;
    if (targetSigma <= _sigmaOffset) return 0.0;
    return (targetSigma - _sigmaOffset) / _sigmaCoefficient;
  }

  /// Black at a given opacity — every Tailwind shadow is `rgb(0 0 0 / a)`.
  static Color _black(double opacity) =>
      Color.fromARGB((opacity * 255).round(), 0, 0, 0);

  /// `shadow-none`.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// `shadow-2xs` — `0 1px rgb(0 0 0 / 0.05)`.
  static List<BoxShadow> get xs2 => <BoxShadow>[
    BoxShadow(color: _black(0.05), offset: const Offset(0, 1)),
  ];

  /// `shadow-xs` — `0 1px 2px 0 rgb(0 0 0 / 0.05)`.
  ///
  /// The default resting elevation for Input, Textarea, Select trigger,
  /// Checkbox, Switch and the outline Button variant.
  static List<BoxShadow> get xs => <BoxShadow>[
    BoxShadow(
      color: _black(0.05),
      offset: const Offset(0, 1),
      blurRadius: cssBlur(2),
    ),
  ];

  /// `shadow-sm` —
  /// `0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)`.
  ///
  /// Used by Card and the active Tabs trigger.
  static List<BoxShadow> get sm => <BoxShadow>[
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 1),
      blurRadius: cssBlur(3),
    ),
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 1),
      blurRadius: cssBlur(2),
      spreadRadius: -1,
    ),
  ];

  /// `shadow-md` —
  /// `0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)`.
  ///
  /// Used by Popover, Dropdown Menu, Select and Hover Card content.
  static List<BoxShadow> get md => <BoxShadow>[
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 4),
      blurRadius: cssBlur(6),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 2),
      blurRadius: cssBlur(4),
      spreadRadius: -2,
    ),
  ];

  /// `shadow-lg` —
  /// `0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)`.
  ///
  /// Used by Dialog, Alert Dialog, Sheet and submenu content.
  static List<BoxShadow> get lg => <BoxShadow>[
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 10),
      blurRadius: cssBlur(15),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 4),
      blurRadius: cssBlur(6),
      spreadRadius: -4,
    ),
  ];

  /// `shadow-xl` —
  /// `0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)`.
  static List<BoxShadow> get xl => <BoxShadow>[
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 20),
      blurRadius: cssBlur(25),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: _black(0.1),
      offset: const Offset(0, 8),
      blurRadius: cssBlur(10),
      spreadRadius: -6,
    ),
  ];

  /// `shadow-2xl` — `0 25px 50px -12px rgb(0 0 0 / 0.25)`.
  static List<BoxShadow> get xl2 => <BoxShadow>[
    BoxShadow(
      color: _black(0.25),
      offset: const Offset(0, 25),
      blurRadius: cssBlur(50),
      spreadRadius: -12,
    ),
  ];
}
