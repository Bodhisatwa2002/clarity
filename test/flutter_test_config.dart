import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's real fonts so layout in tests matches the device
/// (the default test font is much wider than Manrope).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final families = <String, List<String>>{};
  for (final file in Directory('assets/fonts').listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    families.putIfAbsent(name.split('-').first, () => []).add(file.path);
  }
  for (final MapEntry(key: family, value: paths) in families.entries) {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
    }
    await loader.load();
  }
  await testMain();
}
