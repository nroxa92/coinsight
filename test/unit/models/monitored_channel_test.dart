import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/monitored_channel.dart';

void main() {
  group('MonitoredChannel', () {
    test('reliabilityScore is -1 when signalsReceived < 10', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 5,
        signalsRelevant: 3,
      );
      expect(ch.reliabilityScore, -1);
    });

    test('reliabilityScore calculates correctly with >10 signals', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 100,
        signalsRelevant: 40,
      );
      expect(ch.reliabilityScore, closeTo(0.4, 0.01));
    });

    test('reliabilityLabel is Visoka when score > 0.3', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 100,
        signalsRelevant: 40,
      );
      expect(ch.reliabilityLabel, 'Visoka');
    });

    test('reliabilityLabel is Srednja when score 0.1-0.3', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 100,
        signalsRelevant: 15,
      );
      expect(ch.reliabilityLabel, 'Srednja');
    });

    test('reliabilityLabel is Niska when score < 0.1', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 100,
        signalsRelevant: 5,
      );
      expect(ch.reliabilityLabel, 'Niska');
    });

    test('reliabilityLabel is Novo when insufficient data', () {
      const ch = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 3,
        signalsRelevant: 1,
      );
      expect(ch.reliabilityLabel, 'Novo');
    });

    test('toMap and fromMap roundtrip', () {
      final original = MonitoredChannel(
        username: '@binance',
        displayName: 'Binance Official',
        isDefault: true,
        signalsReceived: 50,
        signalsRelevant: 20,
        lastSignal: DateTime(2026, 4, 16, 10, 0),
        isActive: true,
      );
      final map = original.toMap();
      final restored = MonitoredChannel.fromMap(map);

      expect(restored.username, original.username);
      expect(restored.displayName, original.displayName);
      expect(restored.isDefault, original.isDefault);
      expect(restored.signalsReceived, original.signalsReceived);
      expect(restored.signalsRelevant, original.signalsRelevant);
      expect(restored.lastSignal, original.lastSignal);
      expect(restored.isActive, original.isActive);
    });

    test('copyWith updates only specified fields', () {
      const original = MonitoredChannel(
        username: '@test',
        displayName: 'Test',
        signalsReceived: 10,
        signalsRelevant: 5,
        isActive: true,
      );
      final modified = original.copyWith(
        signalsReceived: 20,
        isActive: false,
      );

      expect(modified.username, '@test');
      expect(modified.signalsReceived, 20);
      expect(modified.signalsRelevant, 5); // unchanged
      expect(modified.isActive, false);
    });
  });
}
