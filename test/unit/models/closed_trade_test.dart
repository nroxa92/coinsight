import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/dex_position.dart';

void main() {
  group('ClosedTrade', () {
    ClosedTrade makeTrade({
      double investedUsdt = 10.0,
      double returnedUsdt = 13.0,
      DateTime? openedAt,
      DateTime? closedAt,
      ClosedTradeResult result = ClosedTradeResult.profit,
    }) {
      final open = openedAt ?? DateTime(2025, 1, 1, 12, 0);
      final close = closedAt ?? DateTime(2025, 1, 2, 12, 0);
      return ClosedTrade(
        id: 'test_1',
        tier: InvestmentTier.short,
        symbol: 'TEST',
        name: 'TestCoin',
        tradeType: ClosedTradeType.dex,
        openedAt: open,
        closedAt: close,
        entryPrice: 1.0,
        exitPrice: 1.3,
        quantity: 10.0,
        investedUsdt: investedUsdt,
        returnedUsdt: returnedUsdt,
        result: result,
      );
    }

    test('pnlAbsolute = returned - invested', () {
      final trade = makeTrade(investedUsdt: 10.0, returnedUsdt: 13.0);
      expect(trade.pnlAbsolute, closeTo(3.0, 0.001));
    });

    test('pnlPercent correct for 10 -> 13 USDT (30%)', () {
      final trade = makeTrade(investedUsdt: 10.0, returnedUsdt: 13.0);
      expect(trade.pnlPercent, closeTo(30.0, 0.001));
    });

    test('isProfit true when returnedUsdt > investedUsdt', () {
      final trade = makeTrade(investedUsdt: 10.0, returnedUsdt: 13.0);
      expect(trade.isProfit, true);
    });

    test('isProfit false when returnedUsdt < investedUsdt', () {
      final trade = makeTrade(investedUsdt: 10.0, returnedUsdt: 7.0);
      expect(trade.isProfit, false);
    });

    test('holdDays correct (1 for 24h)', () {
      final trade = makeTrade(
        openedAt: DateTime(2025, 1, 1, 12, 0),
        closedAt: DateTime(2025, 1, 2, 12, 0),
      );
      expect(trade.holdDays, 1);
    });

    test('toMap/fromMap roundtrip', () {
      final original = makeTrade();
      final map = original.toMap();
      final restored = ClosedTrade.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.tier, original.tier);
      expect(restored.symbol, original.symbol);
      expect(restored.name, original.name);
      expect(restored.tradeType, original.tradeType);
      expect(restored.openedAt, original.openedAt);
      expect(restored.closedAt, original.closedAt);
      expect(restored.entryPrice, original.entryPrice);
      expect(restored.exitPrice, original.exitPrice);
      expect(restored.quantity, original.quantity);
      expect(restored.investedUsdt, original.investedUsdt);
      expect(restored.returnedUsdt, original.returnedUsdt);
      expect(restored.result, original.result);
      expect(restored.notes, original.notes);
    });

    test('fromDexPosition factory creates correct ClosedTrade', () {
      final pos = DexPosition(
        id: 'dex_1',
        tokenSymbol: 'PEPE',
        tokenName: 'Pepe Token',
        contractAddress: '0xabc',
        chainId: 'ethereum',
        dexName: 'Uniswap',
        walletAddress: '0x123',
        entryPrice: 0.001,
        quantity: 10000.0,
        entryAmountUsdt: 10.0,
        entryTime: DateTime(2025, 1, 1),
      );

      final closed = ClosedTrade.fromDexPosition(
        pos,
        0.0015, // exitPrice
        ClosedTradeResult.profit,
      );

      expect(closed.id, 'dex_1_closed');
      expect(closed.tier, InvestmentTier.short);
      expect(closed.symbol, 'PEPE');
      expect(closed.name, 'Pepe Token');
      expect(closed.tradeType, ClosedTradeType.dex);
      expect(closed.entryPrice, 0.001);
      expect(closed.exitPrice, 0.0015);
      expect(closed.quantity, 10000.0);
      expect(closed.investedUsdt, 10.0);
      expect(closed.returnedUsdt, closeTo(15.0, 0.001)); // 10000 * 0.0015
      expect(closed.result, ClosedTradeResult.profit);
    });
  });
}
