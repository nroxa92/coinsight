import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/models/trade_proposal.dart';
import 'package:coinsight/models/trade_result.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';

class TradeService {
  final BinanceService _binance;

  TradeService({BinanceService? binance})
      : _binance = binance ?? BinanceService();

  String _binanceSymbol(Coin coin) => '${coin.symbol.toUpperCase()}USDT';

  Future<TradeProposal> prepareTradeProposal({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  }) async {
    final symbol = _binanceSymbol(coin);
    final price = await _binance.getCurrentPrice(symbol);
    if (price <= 0) {
      throw BinanceException('Could not fetch price for $symbol');
    }
    final amount = riskParams.maxTradeAmountUsdt;
    final estimatedQty = amount / price;
    final stopLoss = price * (1 - riskParams.stopLossPercent / 100);
    final takeProfit = price * (1 + riskParams.takeProfitPercent / 100);

    return TradeProposal(
      coin: coin,
      amountUsdt: amount,
      estimatedQty: estimatedQty,
      currentPrice: price,
      stopLossPrice: stopLoss,
      takeProfitPrice: takeProfit,
      claudeRecommendation: claudeRecommendation,
      createdAt: DateTime.now(),
    );
  }

  Future<TradeResult> executeTrade(TradeProposal proposal) async {
    if (proposal.isExpired) {
      return TradeResult.failure(
          'Proposal expired (>60s). Fetch a new price.');
    }

    final riskParams = StorageService.getRiskParameters();
    final positions = StorageService.getPositions();
    if (positions.length >= riskParams.maxOpenPositions) {
      return TradeResult.failure(
          'Max open positions (${riskParams.maxOpenPositions}) reached');
    }
    if (positions.any((p) => p.coinId == proposal.coin.id)) {
      return TradeResult.failure(
          '${proposal.coin.symbol.toUpperCase()} position already open');
    }

    try {
      final balance = await _binance.getUsdtBalance();
      if (balance < proposal.amountUsdt) {
        return TradeResult.failure(
            'Insufficient USDT balance (have \$${balance.toStringAsFixed(2)})');
      }

      final symbol = _binanceSymbol(proposal.coin);
      final order =
          await _binance.placeBuyOrder(symbol, proposal.amountUsdt);

      if (order.executedQty <= 0) {
        return TradeResult.failure('Order not filled');
      }

      final position = CoinPosition(
        coinId: proposal.coin.id,
        symbol: proposal.coin.symbol.toUpperCase(),
        binanceSymbol: symbol,
        quantity: order.executedQty,
        entryPrice: order.avgPrice,
        entryTotal: order.cummulativeQuoteQty,
        entryTime: DateTime.now(),
        currentPrice: order.avgPrice,
      );
      await StorageService.savePosition(position);

      await StorageService.saveAnalysisLog(AnalysisLog(
        timestamp: DateTime.now(),
        coinId: proposal.coin.id,
        coinSymbol: proposal.coin.symbol.toUpperCase(),
        priceAtAnalysis: order.avgPrice,
        claudeRecommendation:
            '[ENTERED @ ${order.avgPrice.toStringAsFixed(6)}] ${proposal.claudeRecommendation}',
        recommendationType: 'ENTERED',
      ));

      return TradeResult(
        success: true,
        orderId: order.orderId,
        executedPrice: order.avgPrice,
        executedQty: order.executedQty,
        totalUsdt: order.cummulativeQuoteQty,
      );
    } on BinanceException catch (e) {
      return TradeResult.failure(e.message);
    }
  }

  Future<TradeResult?> autoExecuteIfEligible({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  }) async {
    if (!riskParams.autoTradeEnabled) return null;
    if (riskParams.isQuietHours) return null;
    if (!_binance.hasCredentials) return null;

    final positions = StorageService.getPositions();
    if (positions.length >= riskParams.maxOpenPositions) return null;
    if (positions.any((p) => p.coinId == coin.id)) return null;

    try {
      final proposal = await prepareTradeProposal(
        coin: coin,
        claudeRecommendation: claudeRecommendation,
        riskParams: riskParams,
      );
      return await executeTrade(proposal);
    } on BinanceException {
      return null;
    }
  }

  Future<void> checkStopLosses() async {
    if (!_binance.hasCredentials) return;
    final positions = StorageService.getPositions();
    if (positions.isEmpty) return;
    final riskParams = StorageService.getRiskParameters();

    for (final pos in positions) {
      try {
        final price = await _binance.getCurrentPrice(pos.binanceSymbol);
        if (price <= 0) continue;

        final slPrice = pos.entryPrice * (1 - riskParams.stopLossPercent / 100);
        final tpPrice =
            pos.entryPrice * (1 + riskParams.takeProfitPercent / 100);

        if (price <= slPrice || price >= tpPrice) {
          await closePosition(pos);
        }
      } on BinanceException {
        continue;
      }
    }
  }

  Future<TradeResult> closePosition(CoinPosition position) async {
    try {
      final order =
          await _binance.placeSellOrder(position.binanceSymbol, position.quantity);

      if (order.executedQty <= 0) {
        return TradeResult.failure('Sell order not filled');
      }

      await StorageService.removePosition(position.coinId);

      final exitTotal = order.cummulativeQuoteQty;
      final pnl = exitTotal - position.entryTotal;
      final pnlPct = position.entryTotal == 0
          ? 0
          : (pnl / position.entryTotal) * 100;

      final closedTrade = ClosedTrade(
        id: '${position.coinId}_${DateTime.now().millisecondsSinceEpoch}',
        tier: InvestmentTier.short,
        symbol: position.symbol,
        name: position.symbol,
        tradeType: ClosedTradeType.binance,
        openedAt: position.entryTime,
        closedAt: DateTime.now(),
        entryPrice: position.entryPrice,
        exitPrice: order.avgPrice,
        quantity: order.executedQty,
        investedUsdt: position.entryTotal,
        returnedUsdt: exitTotal,
        result: pnl > 0.01
            ? ClosedTradeResult.profit
            : pnl < -0.01
                ? ClosedTradeResult.loss
                : ClosedTradeResult.breakeven,
      );
      await StorageService.saveClosedTrade(closedTrade);

      await StorageService.saveAnalysisLog(AnalysisLog(
        timestamp: DateTime.now(),
        coinId: position.coinId,
        coinSymbol: position.symbol,
        priceAtAnalysis: order.avgPrice,
        claudeRecommendation:
            '[EXITED @ ${order.avgPrice.toStringAsFixed(6)}] P&L: ${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)} (${pnlPct.toStringAsFixed(2)}%)',
        recommendationType: 'EXITED',
      ));

      return TradeResult(
        success: true,
        orderId: order.orderId,
        executedPrice: order.avgPrice,
        executedQty: order.executedQty,
        totalUsdt: exitTotal,
      );
    } on BinanceException catch (e) {
      return TradeResult.failure(e.message);
    }
  }
}
