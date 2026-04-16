import 'package:flutter/material.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/dex_position.dart';

/// Zapis o zatvorenoj poziciji — SHORT, MID ili LONG
///
/// Kreira se automatski kada:
/// - SHORT Binance pozicija se zatvori (SL/TP/manual)
/// - SHORT DEX pozicija se zatvori (SL/TP/manual)
/// - MID projekt dobije status EXITED
/// - LONG holding dobije status CLOSED
class ClosedTrade {
  final String id;
  final InvestmentTier tier;
  final String symbol;
  final String name;
  final ClosedTradeType tradeType;  // binance, dex, mid, long
  final DateTime openedAt;
  final DateTime closedAt;
  final double entryPrice;
  final double exitPrice;
  final double quantity;
  final double investedUsdt;        // koliko smo ulozili
  final double returnedUsdt;        // koliko smo dobili natrag
  final ClosedTradeResult result;   // profit, loss, breakeven
  final String? notes;              // opcionalna biljeska

  const ClosedTrade({
    required this.id,
    required this.tier,
    required this.symbol,
    required this.name,
    required this.tradeType,
    required this.openedAt,
    required this.closedAt,
    required this.entryPrice,
    required this.exitPrice,
    required this.quantity,
    required this.investedUsdt,
    required this.returnedUsdt,
    this.result = ClosedTradeResult.unknown,
    this.notes,
  });

  double get pnlAbsolute => returnedUsdt - investedUsdt;
  double get pnlPercent => investedUsdt > 0
      ? (pnlAbsolute / investedUsdt) * 100 : 0;
  bool get isProfit => pnlAbsolute > 0;
  int get holdDays => closedAt.difference(openedAt).inDays;
  int get holdHours => closedAt.difference(openedAt).inHours;

  Map<String, dynamic> toMap() => {
    'id': id,
    'tier': tier.name,
    'symbol': symbol,
    'name': name,
    'trade_type': tradeType.name,
    'opened_at': openedAt.toIso8601String(),
    'closed_at': closedAt.toIso8601String(),
    'entry_price': entryPrice,
    'exit_price': exitPrice,
    'quantity': quantity,
    'invested_usdt': investedUsdt,
    'returned_usdt': returnedUsdt,
    'result': result.name,
    'notes': notes,
  };

  factory ClosedTrade.fromMap(Map<dynamic, dynamic> map) => ClosedTrade(
    id: map['id'] as String,
    tier: InvestmentTier.values.firstWhere(
      (t) => t.name == (map['tier'] as String? ?? 'short'),
      orElse: () => InvestmentTier.short,
    ),
    symbol: map['symbol'] as String,
    name: map['name'] as String? ?? '',
    tradeType: ClosedTradeType.values.firstWhere(
      (t) => t.name == (map['trade_type'] as String? ?? 'dex'),
      orElse: () => ClosedTradeType.dex,
    ),
    openedAt: DateTime.parse(map['opened_at'] as String),
    closedAt: DateTime.parse(map['closed_at'] as String),
    entryPrice: (map['entry_price'] as num).toDouble(),
    exitPrice: (map['exit_price'] as num).toDouble(),
    quantity: (map['quantity'] as num).toDouble(),
    investedUsdt: (map['invested_usdt'] as num).toDouble(),
    returnedUsdt: (map['returned_usdt'] as num).toDouble(),
    result: ClosedTradeResult.values.firstWhere(
      (r) => r.name == (map['result'] as String? ?? 'unknown'),
      orElse: () => ClosedTradeResult.unknown,
    ),
    notes: map['notes'] as String?,
  );

  /// Kreira ClosedTrade iz DEX pozicije pri zatvaranju
  factory ClosedTrade.fromDexPosition(
    DexPosition pos,
    double exitPrice,
    ClosedTradeResult result,
  ) => ClosedTrade(
    id: '${pos.id}_closed',
    tier: InvestmentTier.short,
    symbol: pos.tokenSymbol,
    name: pos.tokenName,
    tradeType: ClosedTradeType.dex,
    openedAt: pos.entryTime,
    closedAt: DateTime.now(),
    entryPrice: pos.entryPrice,
    exitPrice: exitPrice,
    quantity: pos.quantity,
    investedUsdt: pos.entryAmountUsdt,
    returnedUsdt: pos.quantity * exitPrice,
    result: result,
  );
}

enum ClosedTradeType { binance, dex, mid, long }

enum ClosedTradeResult { profit, loss, breakeven, unknown }

extension ClosedTradeResultX on ClosedTradeResult {
  Color get color {
    switch (this) {
      case ClosedTradeResult.profit:    return Colors.green;
      case ClosedTradeResult.loss:      return const Color(0xFFEF5350);
      case ClosedTradeResult.breakeven: return Colors.orange;
      case ClosedTradeResult.unknown:   return Colors.grey;
    }
  }
  String get label {
    switch (this) {
      case ClosedTradeResult.profit:    return 'Profit';
      case ClosedTradeResult.loss:      return 'Gubitak';
      case ClosedTradeResult.breakeven: return 'Breakeven';
      case ClosedTradeResult.unknown:   return 'N/A';
    }
  }
}
