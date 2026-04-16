import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/dex_position.dart';

void main() {
  DexPosition makePosition({
    double entryPrice = 1.0,
    double quantity = 100.0,
    double entryAmountUsdt = 100.0,
    double? currentPrice,
    double? stopLossPrice,
    double? takeProfitPrice,
    DexPositionStatus status = DexPositionStatus.open,
  }) {
    return DexPosition(
      id: 'test-id',
      tokenSymbol: 'TEST',
      tokenName: 'Test Token',
      contractAddress: '0xabc123',
      chainId: 'ethereum',
      dexName: 'Uniswap',
      walletAddress: '0xwallet',
      entryPrice: entryPrice,
      quantity: quantity,
      entryAmountUsdt: entryAmountUsdt,
      entryTime: DateTime(2025, 1, 1),
      currentPrice: currentPrice,
      stopLossPrice: stopLossPrice,
      takeProfitPrice: takeProfitPrice,
      status: status,
    );
  }

  group('DexPosition', () {
    test('currentValue uses currentPrice when set', () {
      final pos = makePosition(
        quantity: 100,
        currentPrice: 2.0,
        entryPrice: 1.0,
      );
      expect(pos.currentValue, 200.0);
    });

    test('currentValue falls back to entryPrice when currentPrice is null', () {
      final pos = makePosition(
        quantity: 100,
        entryPrice: 1.5,
        currentPrice: null,
      );
      expect(pos.currentValue, 150.0);
    });

    test('pnlAbsolute positive when profit', () {
      final pos = makePosition(
        quantity: 100,
        entryAmountUsdt: 100.0,
        currentPrice: 2.0,
      );
      // currentValue = 100 * 2.0 = 200, pnl = 200 - 100 = 100
      expect(pos.pnlAbsolute, 100.0);
    });

    test('pnlPercent calculation', () {
      final pos = makePosition(
        quantity: 100,
        entryAmountUsdt: 100.0,
        currentPrice: 1.5,
      );
      // currentValue = 150, pnl = 50, percent = (50/100)*100 = 50%
      expect(pos.pnlPercent, 50.0);
    });

    test('isProfit true when pnlAbsolute > 0', () {
      final pos = makePosition(
        quantity: 100,
        entryAmountUsdt: 100.0,
        currentPrice: 2.0,
      );
      expect(pos.isProfit, true);
    });

    test('isProfit false when pnlAbsolute <= 0', () {
      final pos = makePosition(
        quantity: 100,
        entryAmountUsdt: 100.0,
        currentPrice: 0.5,
      );
      expect(pos.isProfit, false);
    });

    test('isStopLossHit true when currentPrice <= stopLossPrice', () {
      final pos = makePosition(
        currentPrice: 0.8,
        stopLossPrice: 0.9,
      );
      expect(pos.isStopLossHit, true);
    });

    test('isTakeProfitHit true when currentPrice >= takeProfitPrice', () {
      final pos = makePosition(
        currentPrice: 3.0,
        takeProfitPrice: 2.5,
      );
      expect(pos.isTakeProfitHit, true);
    });

    test('isStopLossHit false when no stopLossPrice set', () {
      final pos = makePosition(
        currentPrice: 0.5,
        stopLossPrice: null,
      );
      expect(pos.isStopLossHit, false);
    });

    test('toMap/fromMap roundtrip', () {
      final pos = makePosition(
        currentPrice: 1.5,
        stopLossPrice: 0.8,
        takeProfitPrice: 3.0,
        status: DexPositionStatus.closedTP,
      );
      final map = pos.toMap();
      final restored = DexPosition.fromMap(map);

      expect(restored.id, pos.id);
      expect(restored.tokenSymbol, pos.tokenSymbol);
      expect(restored.tokenName, pos.tokenName);
      expect(restored.contractAddress, pos.contractAddress);
      expect(restored.chainId, pos.chainId);
      expect(restored.dexName, pos.dexName);
      expect(restored.walletAddress, pos.walletAddress);
      expect(restored.entryPrice, pos.entryPrice);
      expect(restored.quantity, pos.quantity);
      expect(restored.entryAmountUsdt, pos.entryAmountUsdt);
      expect(restored.entryTime, pos.entryTime);
      expect(restored.currentPrice, pos.currentPrice);
      expect(restored.stopLossPrice, pos.stopLossPrice);
      expect(restored.takeProfitPrice, pos.takeProfitPrice);
      expect(restored.status, pos.status);
    });

    test('copyWith only changes specified fields', () {
      final pos = makePosition(currentPrice: 1.0);
      final updated = pos.copyWith(tokenSymbol: 'NEW', currentPrice: 5.0);

      expect(updated.tokenSymbol, 'NEW');
      expect(updated.currentPrice, 5.0);
      // Unchanged fields
      expect(updated.id, pos.id);
      expect(updated.tokenName, pos.tokenName);
      expect(updated.contractAddress, pos.contractAddress);
      expect(updated.chainId, pos.chainId);
      expect(updated.dexName, pos.dexName);
      expect(updated.entryPrice, pos.entryPrice);
      expect(updated.quantity, pos.quantity);
      expect(updated.entryAmountUsdt, pos.entryAmountUsdt);
      expect(updated.entryTime, pos.entryTime);
      expect(updated.status, pos.status);
    });
  });
}
