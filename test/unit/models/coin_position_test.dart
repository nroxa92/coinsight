import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/coin_position.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('CoinPosition', () {
    test('pnlAbsolute calculates profit correctly', () {
      final pos = TestFixtures.openPosition();
      // currentValue = 4273.504 * 0.0028 = ~11.9658
      // pnlAbsolute = 11.9658 - 10.0 = ~1.9658
      expect(pos.pnlAbsolute, closeTo(1.9658, 0.001));
    });

    test('pnlPercent calculates correctly', () {
      final pos = TestFixtures.openPosition();
      // pnlPercent = (1.9658 / 10.0) * 100 = ~19.658%
      expect(pos.pnlPercent, closeTo(19.658, 0.1));
    });

    test('isProfit returns true when profitable', () {
      final pos = TestFixtures.openPosition();
      expect(pos.isProfit, true);
    });

    test('isProfit returns false when at loss', () {
      final pos = CoinPosition(
        coinId: 'test',
        symbol: 'TEST',
        binanceSymbol: 'TESTUSDT',
        quantity: 100,
        entryPrice: 1.0,
        entryTotal: 100.0,
        entryTime: DateTime.now(),
        currentPrice: 0.5,
      );
      expect(pos.isProfit, false);
      expect(pos.pnlAbsolute, closeTo(-50.0, 0.01));
    });

    test('currentValue uses entryPrice when currentPrice is null', () {
      final pos = CoinPosition(
        coinId: 'test',
        symbol: 'TEST',
        binanceSymbol: 'TESTUSDT',
        quantity: 100,
        entryPrice: 1.0,
        entryTotal: 100.0,
        entryTime: DateTime.now(),
        currentPrice: null,
      );
      expect(pos.currentValue, 100.0);
      expect(pos.pnlAbsolute, 0.0);
    });

    test('pnlPercent returns 0 when entryTotal is 0', () {
      final pos = CoinPosition(
        coinId: 'test',
        symbol: 'TEST',
        binanceSymbol: 'TESTUSDT',
        quantity: 0,
        entryPrice: 0,
        entryTotal: 0,
        entryTime: DateTime.now(),
      );
      expect(pos.pnlPercent, 0);
    });

    test('toMap and fromMap roundtrip', () {
      final original = TestFixtures.openPosition();
      final map = original.toMap();
      final restored = CoinPosition.fromMap(map);

      expect(restored.coinId, original.coinId);
      expect(restored.symbol, original.symbol);
      expect(restored.binanceSymbol, original.binanceSymbol);
      expect(restored.quantity, original.quantity);
      expect(restored.entryPrice, original.entryPrice);
      expect(restored.entryTotal, original.entryTotal);
      expect(restored.entryTime, original.entryTime);
      expect(restored.currentPrice, original.currentPrice);
    });
  });
}
