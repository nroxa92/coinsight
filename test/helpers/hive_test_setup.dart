import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// List of all boxes StorageService expects to exist (see StorageService.init).
/// Kept in sync manually — if you add a box, update both places.
const _boxes = <String>[
  'settings',
  'watchlist',
  'analysis_logs',
  'positions',
  'monitored_channels_detail',
  'mid_term_projects',
  'long_term_holdings',
  'dex_positions',
  'closed_trades',
];

Directory? _tempDir;

/// Initializes Hive in a fresh temp directory and opens all boxes
/// StorageService expects. Also stubs the flutter_local_notifications
/// platform channel so provider/widget code that hits NotificationService
/// doesn't blow up in a host test environment. Call in test setUp.
/// Pair with [tearDownHive] in tearDown to clean up.
Future<void> setUpHive() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dexterous.com/flutter/local_notifications'),
    (call) async => null,
  );

  _tempDir = await Directory.systemTemp.createTemp('coinsight_hive_test_');
  Hive.init(_tempDir!.path);
  for (final name in _boxes) {
    await Hive.openBox(name);
  }
}

/// Closes all Hive boxes and wipes the temp directory.
Future<void> tearDownHive() async {
  await Hive.close();
  final dir = _tempDir;
  if (dir != null && dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
  _tempDir = null;
}
