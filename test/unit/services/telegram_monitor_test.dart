import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:coinsight/services/storage_service.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() async {
    registerFallbacks();
    final dir = Directory.systemTemp.createTempSync('telegram_monitor_test');
    Hive.init(dir.path);
    await Hive.openBox('settings');
    await Hive.openBox('watchlist');
    await Hive.openBox('analysis_logs');
    await Hive.openBox('positions');
  });

  setUp(() async {
    await StorageService.deleteTelegramMonitorToken();
    await StorageService.saveMonitoredChannels([]);
  });

  group('TelegramMonitor', () {
    test('isConfigured returns false when token is empty', () {
      final monitor = TelegramMonitor();
      expect(monitor.isConfigured, false);
    });

    test('isConfigured returns true when token is set', () async {
      await StorageService.saveTelegramMonitorToken('test-token');
      final monitor = TelegramMonitor();
      expect(monitor.isConfigured, true);
    });

    test('startMonitoring does nothing if not configured', () {
      final monitor = TelegramMonitor();
      // Should not throw
      monitor.startMonitoring();
      monitor.stopMonitoring();
    });

    test('testConnection returns bot username on success', () async {
      await StorageService.saveTelegramMonitorToken('test-token');
      final client = HttpClientFactory.returning(json.encode({
        'ok': true,
        'result': {'username': 'test_bot', 'id': 123},
      }));
      final monitor = TelegramMonitor(client: client);
      final result = await monitor.testConnection();
      expect(result, 'test_bot');
    });

    test('testConnection returns null on invalid token', () async {
      await StorageService.saveTelegramMonitorToken('bad-token');
      final client = HttpClientFactory.returning('', statusCode: 401);
      final monitor = TelegramMonitor(client: client);
      final result = await monitor.testConnection();
      expect(result, isNull);
    });

    test('testConnection returns null when not configured', () async {
      final monitor = TelegramMonitor();
      final result = await monitor.testConnection();
      expect(result, isNull);
    });
  });
}
