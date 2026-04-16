import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/services/storage_service.dart';

/// Analytics model — svi P&L podatci agregirani
///
/// Buildas ga s PnlAnalyticsBuilder koji cita iz StorageService
class PnlAnalytics {
  // Zatvoreni tradovi — osnova za sve metrike
  final List<ClosedTrade> closedTrades;

  // Trenutno otvorene pozicije (unrealized P&L)
  final List<CoinPosition> openBinancePositions;
  final List<DexPosition> openDexPositions;
  final List<MidTermProject> activeMidProjects;
  final List<LongTermHolding> activeLongHoldings;

  const PnlAnalytics({
    required this.closedTrades,
    required this.openBinancePositions,
    required this.openDexPositions,
    required this.activeMidProjects,
    required this.activeLongHoldings,
  });

  // --- REALIZED P&L (zatvorene pozicije) ---

  double get totalRealizedPnl =>
      closedTrades.fold(0, (sum, t) => sum + t.pnlAbsolute);

  double get totalInvested =>
      closedTrades.fold(0, (sum, t) => sum + t.investedUsdt);

  double get totalReturned =>
      closedTrades.fold(0, (sum, t) => sum + t.returnedUsdt);

  int get totalTrades => closedTrades.length;

  int get winCount => closedTrades
      .where((t) => t.result == ClosedTradeResult.profit).length;

  int get lossCount => closedTrades
      .where((t) => t.result == ClosedTradeResult.loss).length;

  double get winRate => totalTrades > 0
      ? (winCount / totalTrades) * 100 : 0;

  double get avgReturnPercent {
    if (closedTrades.isEmpty) return 0;
    return closedTrades
        .map((t) => t.pnlPercent)
        .fold(0.0, (sum, pnl) => sum + pnl) / closedTrades.length;
  }

  double get avgWinPercent {
    final wins = closedTrades
        .where((t) => t.result == ClosedTradeResult.profit)
        .toList();
    if (wins.isEmpty) return 0;
    return wins.map((t) => t.pnlPercent)
        .fold(0.0, (sum, p) => sum + p) / wins.length;
  }

  double get avgLossPercent {
    final losses = closedTrades
        .where((t) => t.result == ClosedTradeResult.loss)
        .toList();
    if (losses.isEmpty) return 0;
    return losses.map((t) => t.pnlPercent)
        .fold(0.0, (sum, p) => sum + p) / losses.length;
  }

  // Risk/reward ratio — avg win / avg loss (absolute)
  double get riskRewardRatio {
    final wins = closedTrades
        .where((t) => t.result == ClosedTradeResult.profit)
        .toList();
    final losses = closedTrades
        .where((t) => t.result == ClosedTradeResult.loss)
        .toList();
    if (wins.isEmpty || losses.isEmpty) return 0;
    final avgWin = wins
        .map((t) => t.pnlAbsolute)
        .fold(0.0, (sum, p) => sum + p) / wins.length;
    final avgLoss = losses
        .map((t) => t.pnlAbsolute.abs())
        .fold(0.0, (sum, p) => sum + p) / losses.length;
    return avgLoss > 0 ? avgWin / avgLoss : 0;
  }

  // Prosjecno trajanje trada u satima
  double get avgHoldHours {
    if (closedTrades.isEmpty) return 0;
    return closedTrades
        .map((t) => t.holdHours.toDouble())
        .fold(0.0, (sum, h) => sum + h) / closedTrades.length;
  }

  // Best i worst trade
  ClosedTrade? get bestTrade {
    if (closedTrades.isEmpty) return null;
    return closedTrades.reduce(
        (a, b) => a.pnlPercent > b.pnlPercent ? a : b);
  }

  ClosedTrade? get worstTrade {
    if (closedTrades.isEmpty) return null;
    return closedTrades.reduce(
        (a, b) => a.pnlPercent < b.pnlPercent ? a : b);
  }

  // --- UNREALIZED P&L (otvorene pozicije) ---

  double get unrealizedBinancePnl => openBinancePositions
      .fold(0, (sum, p) => sum + p.pnlAbsolute);

  double get unrealizedDexPnl => openDexPositions
      .fold(0, (sum, p) => sum + p.pnlAbsolute);

  double get totalUnrealizedPnl =>
      unrealizedBinancePnl + unrealizedDexPnl;

  double get totalMidInvested => activeMidProjects
      .fold(0, (sum, p) => sum + (p.actualEntryAmount ?? 0));

  double get totalLongInvested => activeLongHoldings
      .fold(0, (sum, h) => sum + h.totalInvested);

  // --- TIER BREAKDOWN ---

  List<ClosedTrade> tradesByTier(InvestmentTier tier) =>
      closedTrades.where((t) => t.tier == tier).toList();

  double pnlByTier(InvestmentTier tier) =>
      tradesByTier(tier).fold(0, (sum, t) => sum + t.pnlAbsolute);

  double winRateByTier(InvestmentTier tier) {
    final trades = tradesByTier(tier);
    if (trades.isEmpty) return 0;
    final wins = trades
        .where((t) => t.result == ClosedTradeResult.profit).length;
    return (wins / trades.length) * 100;
  }

  // --- EQUITY CURVE ---
  // Kronoloski rast kapitala za chart

  List<EquityPoint> get equityCurve {
    if (closedTrades.isEmpty) return [];
    final sorted = [...closedTrades]
      ..sort((a, b) => a.closedAt.compareTo(b.closedAt));

    double cumulative = 0;
    return sorted.map((t) {
      cumulative += t.pnlAbsolute;
      return EquityPoint(
        timestamp: t.closedAt,
        cumulativePnl: cumulative,
        tradeSymbol: t.symbol,
      );
    }).toList();
  }
}

class EquityPoint {
  final DateTime timestamp;
  final double cumulativePnl;
  final String tradeSymbol;
  const EquityPoint({
    required this.timestamp,
    required this.cumulativePnl,
    required this.tradeSymbol,
  });
}

/// Builder koji cita iz StorageService i gradi PnlAnalytics
class PnlAnalyticsBuilder {
  static PnlAnalytics build() {
    return PnlAnalytics(
      closedTrades: StorageService.getClosedTrades(),
      openBinancePositions: StorageService.getPositions(),
      openDexPositions: StorageService.getDexPositions(),
      activeMidProjects: StorageService.getMidProjects()
          .where((p) =>
              p.status == MidTermStatus.entered ||
              p.status == MidTermStatus.watching)
          .toList(),
      activeLongHoldings: StorageService.getLongHoldings()
          .where((h) =>
              h.status != LongTermStatus.closed)
          .toList(),
    );
  }
}
