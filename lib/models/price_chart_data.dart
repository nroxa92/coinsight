import 'package:flutter/material.dart';
import 'package:coinsight/models/investment_tier.dart';

/// Centralni model za price chart podatke kroz sve tierove
///
/// SHORT:  10 dana historije + 1 dan predikcije
/// MID:    6 mjeseci historije + 1 mjesec predikcije
/// LONG:   2 godine historije + 6 mjeseci predikcije
class PriceChartData {
  final String symbol;
  final InvestmentTier tier;
  final List<PricePoint> historical;    // stvarni podaci
  final List<PricePoint> prediction;    // Claude predikcija
  final List<TradeEvent> tradeEvents;   // naši buy/sell eventi
  final double? supportLevel;           // ključni support
  final double? resistanceLevel;        // ključni resistance
  final DateTime generatedAt;

  const PriceChartData({
    required this.symbol,
    required this.tier,
    required this.historical,
    required this.prediction,
    required this.tradeEvents,
    this.supportLevel,
    this.resistanceLevel,
    required this.generatedAt,
  });

  // Najniža cijena za y-axis minimum
  double get minPrice {
    final allPrices = [
      ...historical.map((p) => p.price),
      ...prediction.map((p) => p.priceMin ?? p.price),
    ];
    if (allPrices.isEmpty) return 0;
    return allPrices.reduce((a, b) => a < b ? a : b) * 0.95;
  }

  // Najviša cijena za y-axis maximum
  double get maxPrice {
    final allPrices = [
      ...historical.map((p) => p.price),
      ...prediction.map((p) => p.priceMax ?? p.price),
    ];
    if (allPrices.isEmpty) return 0;
    return allPrices.reduce((a, b) => a > b ? a : b) * 1.05;
  }

  // Zadnja stvarna cijena
  double get currentPrice =>
      historical.isNotEmpty ? historical.last.price : 0;

  // Predikcija — krajnja cijena
  double get predictedEndPrice =>
      prediction.isNotEmpty ? prediction.last.price : currentPrice;

  // Očekivani return prema predikciji
  double get expectedReturnPercent {
    if (currentPrice <= 0) return 0;
    return ((predictedEndPrice - currentPrice) / currentPrice) * 100;
  }

  bool get isPredictionBullish => predictedEndPrice > currentPrice;
}

/// Jedna točka na grafu
class PricePoint {
  final DateTime timestamp;
  final double price;
  final double? priceMin;   // za predikciju — donji range
  final double? priceMax;   // za predikciju — gornji range
  final double? volume;

  const PricePoint({
    required this.timestamp,
    required this.price,
    this.priceMin,
    this.priceMax,
    this.volume,
  });

  bool get isPrediction => priceMin != null || priceMax != null;
}

/// Buy/Sell event koji se prikazuje na grafu kao marker
class TradeEvent {
  final DateTime timestamp;
  final double price;
  final TradeEventType type;
  final double amountUsdt;

  const TradeEvent({
    required this.timestamp,
    required this.price,
    required this.type,
    required this.amountUsdt,
  });
}

enum TradeEventType { buy, sell, stopLoss, takeProfit, dca }

extension TradeEventTypeX on TradeEventType {
  String get label {
    switch (this) {
      case TradeEventType.buy:        return 'BUY';
      case TradeEventType.sell:       return 'SELL';
      case TradeEventType.stopLoss:   return 'SL';
      case TradeEventType.takeProfit: return 'TP';
      case TradeEventType.dca:        return 'DCA';
    }
  }
  Color get color {
    switch (this) {
      case TradeEventType.buy:        return Colors.green;
      case TradeEventType.sell:       return Colors.blue;
      case TradeEventType.stopLoss:   return Colors.red;
      case TradeEventType.takeProfit: return Colors.orange;
      case TradeEventType.dca:        return const Color(0xFFFFD700);
    }
  }
}
