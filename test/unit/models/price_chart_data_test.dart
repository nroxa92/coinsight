import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/models/investment_tier.dart';

void main() {
  group('PriceChartData', () {
    final now = DateTime(2026, 4, 16);

    PriceChartData makeChart({
      List<PricePoint>? historical,
      List<PricePoint>? prediction,
    }) =>
        PriceChartData(
          symbol: 'BTC',
          tier: InvestmentTier.short,
          historical: historical ?? [],
          prediction: prediction ?? [],
          tradeEvents: [],
          generatedAt: now,
        );

    group('minPrice', () {
      test('returns 5% below lowest including historical and prediction priceMin', () {
        final chart = makeChart(
          historical: [
            PricePoint(timestamp: now, price: 100),
            PricePoint(timestamp: now, price: 120),
          ],
          prediction: [
            PricePoint(timestamp: now, price: 110, priceMin: 80, priceMax: 130),
          ],
        );
        // lowest is prediction priceMin 80, so 80 * 0.95 = 76
        expect(chart.minPrice, closeTo(76.0, 0.01));
      });

      test('returns 0 when all lists empty', () {
        final chart = makeChart();
        expect(chart.minPrice, 0);
      });
    });

    group('maxPrice', () {
      test('returns 5% above highest including prediction priceMax', () {
        final chart = makeChart(
          historical: [
            PricePoint(timestamp: now, price: 100),
            PricePoint(timestamp: now, price: 120),
          ],
          prediction: [
            PricePoint(timestamp: now, price: 110, priceMin: 90, priceMax: 150),
          ],
        );
        // highest is prediction priceMax 150, so 150 * 1.05 = 157.5
        expect(chart.maxPrice, closeTo(157.5, 0.01));
      });

      test('returns 0 when all lists empty', () {
        final chart = makeChart();
        expect(chart.maxPrice, 0);
      });
    });

    group('currentPrice', () {
      test('returns last historical price', () {
        final chart = makeChart(
          historical: [
            PricePoint(timestamp: now, price: 100),
            PricePoint(timestamp: now, price: 200),
          ],
        );
        expect(chart.currentPrice, 200);
      });

      test('returns 0 when historical is empty', () {
        final chart = makeChart();
        expect(chart.currentPrice, 0);
      });
    });

    group('expectedReturnPercent', () {
      test('positive when bullish prediction', () {
        final chart = makeChart(
          historical: [
            PricePoint(timestamp: now, price: 100),
          ],
          prediction: [
            PricePoint(timestamp: now, price: 130, priceMin: 120, priceMax: 140),
          ],
        );
        // (130 - 100) / 100 * 100 = 30%
        expect(chart.expectedReturnPercent, closeTo(30.0, 0.01));
      });

      test('negative when bearish prediction', () {
        final chart = makeChart(
          historical: [
            PricePoint(timestamp: now, price: 100),
          ],
          prediction: [
            PricePoint(timestamp: now, price: 70, priceMin: 60, priceMax: 80),
          ],
        );
        // (70 - 100) / 100 * 100 = -30%
        expect(chart.expectedReturnPercent, closeTo(-30.0, 0.01));
      });

      test('returns 0 when currentPrice is 0', () {
        final chart = makeChart(
          prediction: [
            PricePoint(timestamp: now, price: 130, priceMin: 120, priceMax: 140),
          ],
        );
        expect(chart.expectedReturnPercent, 0);
      });
    });

    group('isPredictionBullish', () {
      test('true when predicted end price above current', () {
        final chart = makeChart(
          historical: [PricePoint(timestamp: now, price: 100)],
          prediction: [PricePoint(timestamp: now, price: 120, priceMin: 110, priceMax: 130)],
        );
        expect(chart.isPredictionBullish, isTrue);
      });

      test('false when predicted end price below current', () {
        final chart = makeChart(
          historical: [PricePoint(timestamp: now, price: 100)],
          prediction: [PricePoint(timestamp: now, price: 80, priceMin: 70, priceMax: 90)],
        );
        expect(chart.isPredictionBullish, isFalse);
      });

      test('false when predicted end price equals current', () {
        final chart = makeChart(
          historical: [PricePoint(timestamp: now, price: 100)],
          prediction: [PricePoint(timestamp: now, price: 100, priceMin: 90, priceMax: 110)],
        );
        expect(chart.isPredictionBullish, isFalse);
      });
    });
  });

  group('PricePoint', () {
    test('isPrediction true when priceMin set', () {
      final p = PricePoint(
        timestamp: DateTime.now(),
        price: 100,
        priceMin: 90,
      );
      expect(p.isPrediction, isTrue);
    });

    test('isPrediction true when priceMax set', () {
      final p = PricePoint(
        timestamp: DateTime.now(),
        price: 100,
        priceMax: 110,
      );
      expect(p.isPrediction, isTrue);
    });

    test('isPrediction false when no min/max', () {
      final p = PricePoint(
        timestamp: DateTime.now(),
        price: 100,
      );
      expect(p.isPrediction, isFalse);
    });
  });

  group('TradeEventType', () {
    test('all types have non-null label', () {
      for (final type in TradeEventType.values) {
        expect(type.label, isNotNull);
        expect(type.label, isNotEmpty);
      }
    });

    test('all types have non-null color', () {
      for (final type in TradeEventType.values) {
        expect(type.color, isA<Color>());
      }
    });

    test('label values are correct', () {
      expect(TradeEventType.buy.label, 'BUY');
      expect(TradeEventType.sell.label, 'SELL');
      expect(TradeEventType.stopLoss.label, 'SL');
      expect(TradeEventType.takeProfit.label, 'TP');
      expect(TradeEventType.dca.label, 'DCA');
    });
  });
}
