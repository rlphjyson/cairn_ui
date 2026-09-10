import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// Wraps a widget under test in a minimal Cairn app.
///
/// Behaviour tests do not need [MaterialApp]'s full chrome, but they do need a
/// [Navigator] (dialogs and sheets push routes), an [Overlay] (popovers and
/// menus mount there) and a registered [CairnTheme].
///
/// The Geist font loaded by `flutter_test_config.dart` is applied so text
/// metrics match the golden tests, keeping layout assertions consistent between
/// the two suites.
Widget harness({
  required Widget child,
  CairnTheme theme = CairnTheme.light,
  Size? surfaceSize,
  bool center = true,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: CairnTheme.materialTheme(theme.copyWith(fontFamily: 'Geist')),
    home: Scaffold(body: center ? Center(child: child) : child),
  );
}

/// Wraps a widget in a [CairnToaster], for toast tests.
Widget toastHarness({
  required Widget child,
  CairnTheme theme = CairnTheme.light,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: CairnTheme.materialTheme(theme.copyWith(fontFamily: 'Geist')),
    home: CairnToaster(
      child: Scaffold(body: Center(child: child)),
    ),
  );
}
