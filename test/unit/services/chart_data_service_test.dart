import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/services/chart_data_service.dart';
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/long_term_holding.dart';

void main() {
  late ChartDataService service;

  setUp(() {
    service = ChartDataService();
  });

  group('parsePredictionFromClaude', () {
    test('extracts PREDICTION_DATA block (bullish)', () {
      const response = '''
      Analysis: BTC looks strong.
      PREDICTION_DATA: {"target": 75000, "confidence": 0.8, "direction": true}
      Overall sentiment positive.
      ''';

      final points = service.parsePredictionFromClaude(
        claudeResponse: response,
        currentPrice: 60000,
        tier: InvestmentTier.short,
      );

      expect(points, isNotEmpty);
      // First point should start near current price
      expect(points.first.price, closeTo(60000, 1));
      // Last point should reach target
      expect(points.last.price, closeTo(75000, 1));
      // All points should have prediction bands
      for (final p in points) {
        expect(p.priceMin, isNotNull);
        expect(p.priceMax, isNotNull);
      }
    });

    test('falls back to sentiment keywords when no PREDICTION_DATA', () {
      // Contains bullish keywords: INTERESTING, ENTER, momentum
      const response = 'This coin is INTERESTING with ENTER signal and momentum';

      final points = service.parsePredictionFromClaude(
        claudeResponse: response,
        currentPrice: 100,
        tier: InvestmentTier.mid,
      );

      expect(points, isNotEmpty);
      // Bullish: last price should be above current
      expect(points.last.price, greaterThan(100));
    });

    test('returns empty-like prediction for no signal', () {
      // No bullish or bearish keywords at all
      const response = 'This is a neutral analysis with no clear direction.';

      final points = service.parsePredictionFromClaude(
        claudeResponse: response,
        currentPrice: 100,
        tier: InvestmentTier.short,
      );

      // Should still return points (sentiment fallback with 0.5 confidence)
      // but since bullScore == bearScore == 0, confidence = 0.5
      // isBullish = false (0 > 0 is false), so bearish default
      expect(points, isNotEmpty);
    });

    test('bearish keywords produce lower target', () {
      const response = 'SKIP this coin, AVOID, pump and dump, rizik, negativno';

      final points = service.parsePredictionFromClaude(
        claudeResponse: response,
        currentPrice: 100,
        tier: InvestmentTier.short,
      );

      expect(points, isNotEmpty);
      expect(points.last.price, lessThan(100));
    });
  });

  group('buildTradeEventsFromHolding', () {
    test('creates DCA events from LongTermHolding with purchases', () {
      final holding = LongTermHolding(
        id: 'test-1',
        symbol: 'ETH',
        name: 'Ethereum',
        firstResearchDate: DateTime(2025, 1, 1),
        status: LongTermStatus.accumulating,
        purchases: [
          LongTermPurchase(
            id: 'p1',
            date: DateTime(2025, 2, 1),
            price: 2500,
            quantity: 1.0,
            amountUsdt: 2500,
          ),
          LongTermPurchase(
            id: 'p2',
            date: DateTime(2025, 3, 1),
            price: 2200,
            quantity: 1.5,
            amountUsdt: 3300,
          ),
        ],
        targetPriceMin: 5000,
        targetPriceMax: 8000,
      );

      final events = service.buildTradeEventsFromHolding(holding);

      expect(events.length, 2);

      expect(events[0].type, TradeEventType.dca);
      expect(events[0].price, 2500);
      expect(events[0].amountUsdt, 2500);
      expect(events[0].timestamp, DateTime(2025, 2, 1));

      expect(events[1].type, TradeEventType.dca);
      expect(events[1].price, 2200);
      expect(events[1].amountUsdt, 3300);
      expect(events[1].timestamp, DateTime(2025, 3, 1));
    });

    test('returns empty list when no purchases', () {
      final holding = LongTermHolding(
        id: 'test-2',
        symbol: 'BTC',
        name: 'Bitcoin',
        firstResearchDate: DateTime(2025, 1, 1),
        status: LongTermStatus.researching,
        purchases: [],
        targetPriceMin: 100000,
        targetPriceMax: 150000,
      );

      final events = service.buildTradeEventsFromHolding(holding);
      expect(events, isEmpty);
    });
  });
}
