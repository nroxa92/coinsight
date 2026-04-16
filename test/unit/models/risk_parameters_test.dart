import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/risk_parameters.dart';

void main() {
  group('RiskParameters', () {
    test('default values are correct', () {
      const rp = RiskParameters();
      expect(rp.maxTradeAmountUsdt, 10.0);
      expect(rp.maxOpenPositions, 3);
      expect(rp.stopLossPercent, 15.0);
      expect(rp.takeProfitPercent, 30.0);
      expect(rp.autoTradeEnabled, false);
      expect(rp.telegramMonitorEnabled, false);
      expect(rp.quietHoursStart, 23);
      expect(rp.quietHoursEnd, 7);
    });

    test('copyWith replaces specified fields', () {
      const original = RiskParameters();
      final modified = original.copyWith(
        maxTradeAmountUsdt: 50.0,
        autoTradeEnabled: true,
      );

      expect(modified.maxTradeAmountUsdt, 50.0);
      expect(modified.autoTradeEnabled, true);
      expect(modified.maxOpenPositions, 3); // unchanged
      expect(modified.stopLossPercent, 15.0); // unchanged
    });

    test('toMap and fromMap roundtrip', () {
      const original = RiskParameters(
        maxTradeAmountUsdt: 25.0,
        maxOpenPositions: 5,
        stopLossPercent: 10.0,
        takeProfitPercent: 50.0,
        autoTradeEnabled: true,
        telegramMonitorEnabled: true,
        quietHoursStart: 22,
        quietHoursEnd: 8,
      );
      final map = original.toMap();
      final restored = RiskParameters.fromMap(map);

      expect(restored.maxTradeAmountUsdt, original.maxTradeAmountUsdt);
      expect(restored.maxOpenPositions, original.maxOpenPositions);
      expect(restored.stopLossPercent, original.stopLossPercent);
      expect(restored.takeProfitPercent, original.takeProfitPercent);
      expect(restored.autoTradeEnabled, original.autoTradeEnabled);
      expect(restored.telegramMonitorEnabled, original.telegramMonitorEnabled);
      expect(restored.quietHoursStart, original.quietHoursStart);
      expect(restored.quietHoursEnd, original.quietHoursEnd);
    });

    test('fromMap uses defaults for missing fields', () {
      final rp = RiskParameters.fromMap({});
      expect(rp.maxTradeAmountUsdt, 10.0);
      expect(rp.maxOpenPositions, 3);
      expect(rp.autoTradeEnabled, false);
      expect(rp.telegramMonitorEnabled, false);
    });
  });
}
