import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness configuration, picked up automatically by `flutter test`.
///
/// This exists to make golden tests reproducible. Two things make golden files
/// differ between a developer's machine and a CI runner, and both are handled
/// here.
///
/// ## 1. Fonts
///
/// `flutter test` does not load any real font by default — text is laid out
/// with a placeholder where every glyph is an identical box. Goldens taken that
/// way tell you nothing about typography, and the moment a real font *is*
/// present the images all change.
///
/// So Cairn bundles Geist (SIL OFL 1.1) under `test/fonts/` and registers it
/// here for every test. Because the font
/// comes from the repository rather than the host operating system, text shapes
/// identically on Windows, macOS and the Linux CI runner.
///
/// The family is registered twice: once as `Geist` and once as the ambient
/// fallback, so widgets that specify no family still get deterministic text.
///
/// ## 2. Rasterization
///
/// Even with identical fonts, anti-aliasing can differ marginally between
/// engine builds. Golden *comparison* is therefore restricted to Linux — see
/// `test/support/golden.dart` — which is what CI runs, so the images are
/// enforced on exactly the platform they were generated on.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadGeist();
  return testMain();
}

/// Registers the bundled Geist weights with the test font collection.
Future<void> _loadGeist() async {
  const Map<String, String> weights = <String, String>{
    'Geist-Regular': 'test/fonts/Geist-Regular.ttf',
    'Geist-Medium': 'test/fonts/Geist-Medium.ttf',
    'Geist-SemiBold': 'test/fonts/Geist-SemiBold.ttf',
    'Geist-Bold': 'test/fonts/Geist-Bold.ttf',
  };

  // A single family with four weights, so `fontWeight` selects the right face
  // instead of Flutter synthesising a fake bold.
  final FontLoader loader = FontLoader('Geist');
  for (final String path in weights.values) {
    loader.addFont(_read(path));
  }
  await loader.load();
}

/// Reads a font file relative to the package root.
///
/// `flutter test` sets the current directory to the package root, so these
/// relative paths resolve regardless of which test file is running.
Future<ByteData> _read(String path) async {
  final Uint8List bytes = await File(path).readAsBytes();
  return ByteData.view(bytes.buffer);
}
