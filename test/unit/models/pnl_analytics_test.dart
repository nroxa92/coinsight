import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/pnl_analytics.dart';
import 'package:coinsight/models/investment_tier.dart';

void main() {
  ClosedTrade makeTrade({
    required String id,
    double investedUsdt = 10.0,
    double returnedUsdt = 13.0,
    ClosedTradeResult result = ClosedTradeResult.profit,
    DateTime? closedAt,
  }) {
    return ClosedTrade(
      id: id,
      tier: InvestmentTier.short,
      symbol: 'TEST',
      name: 'TestCoin',
      tradeType: ClosedTradeType.dex,
      openedAt: DateTime(2025, 1, 1),
      closedAt: closedAt ?? DateTime(2025, 1, 2),
      entryPrice: 1.0,
      exitPrice: 1.3,
      quantity: 10.0,
      investedUsdt: investedUsdt,
      returnedUsdt: returnedUsdt,
      result: result,
    );
  }

  PnlAnalytics makeAnalytics(List<ClosedTrade> trades) {
    return PnlAnalytics(
      closedTrades: trades,
      openBinancePositions: [],
      openDexPositions: [],
      activeMidProjects: [],
      activeLongHoldings: [],
    );
  }

  group('PnlAnalytics', () {
    test('totalRealizedPnl sums all trades', () {
      final analytics = makeAnalytics([
        makeTrade(id: '1', investedUsdt: 10, returnedUsdt: 13), // +3
        makeTrade(id: '2', investedUsdt: 10, returnedUsdt: 8),  // -2
      ]);
      expect(analytics.totalRealizedPnl, closeTo(1.0, 0.001));
    });

    test('winRate 50% for 1 win 1 loss', () {
      final analytics = makeAnalytics([
        makeTrade(id: '1', result: ClosedTradeResult.profit),
        makeTrade(id: '2', result: ClosedTradeResult.loss),
      ]);
      expect(analytics.winRate, closeTo(50.0, 0.001));
    });

    test('winRate 100% for all profits', () {
      final analytics = makeAnalytics([
        makeTrade(id: '1', result: ClosedTradeResult.profit),
        makeTrade(id: '2', result: ClosedTradeResult.profit),
        makeTrade(id: '3', result: ClosedTradeResult.profit),
      ]);
      expect(analytics.winRate, closeTo(100.0, 0.001));
    });

    test('winCount and lossCount correct', () {
      final analytics = makeAnalytics([
        makeTrade(id: '1', result: ClosedTradeResult.profit),
        makeTrade(id: '2', result: ClosedTradeResult.loss),
        makeTrade(id: '3', result: ClosedTradeResult.profit),
        makeTrade(id: '4', result: ClosedTradeResult.breakeven),
      ]);
      expect(analytics.winCount, 2);
      expect(analytics.lossCount, 1);
    });

    test('equityCurve is chronological', () {
      final analytics = makeAnalytics([
        makeTrade(id: '2', closedAt: DateTime(2025, 1, 3)),
        makeTrade(id: '1', closedAt: DateTime(2025, 1, 1)),
        makeTrade(id: '3', closedAt: DateTime(2025, 1, 5)),
      ]);
      final curve = analytics.equityCurve;
      expect(curve.length, 3);
      expect(curve[0].timestamp.isBefore(curve[1].timestamp), true);
      expect(curve[1].timestamp.isBefore(curve[2].timestamp), true);
    });

    test('equityCurve cumulative increases on profit', () {
      final analytics = makeAnalytics([
        makeTrade(
          id: '1',
          investedUsdt: 10,
          returnedUsdt: 15,
          result: ClosedTradeResult.profit,
          closedAt: DateTime(2025, 1, 1),
        ),
        makeTrade(
          id: '2',
          investedUsdt: 10,
          returnedUsdt: 12,
          result: ClosedTradeResult.profit,
          closedAt: DateTime(2025, 1, 2),
        ),
      ]);
      final curve = analytics.equityCurve;
      expect(curve.length, 2);
      // First: cumulative = +5
      expect(curve[0].cumulativePnl, closeTo(5.0, 0.001));
      // Second: cumulative = +5 + 2 = +7
      expect(curve[1].cumulativePnl, closeTo(7.0, 0.001));
      // Second is greater than first
      expect(curve[1].cumulativePnl, greaterThan(curve[0].cumulativePnl));
    });
  });
}
