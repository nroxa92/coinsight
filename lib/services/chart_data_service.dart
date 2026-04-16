import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/price_chart_data.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/models/long_term_holding.dart';

/// ChartDataService — dohvaća historijske podatke i gradi chart data
///
/// Koristi CoinGecko /coins/{id}/market_chart endpoint
/// koji je besplatan i vraća OHLC podatke po danima
class ChartDataService {
  static const _baseUrl = 'https://api.coingecko.com/api/v3';
  static const _timeout = Duration(seconds: 20);
  final http.Client _client;

  ChartDataService({http.Client? client})
      : _client = client ?? http.Client();

  /// Dohvaća historijske podatke ovisno o tieru
  /// SHORT: 10 dana, MID: 180 dana, LONG: 730 dana
  Future<List<PricePoint>> fetchHistorical({
    required String coinGeckoId,
    required InvestmentTier tier,
  }) async {
    final days = _daysForTier(tier);
    final uri = Uri.parse(
      '$_baseUrl/coins/$coinGeckoId/market_chart'
      '?vs_currency=usd&days=$days'
      '&interval=${_intervalForTier(tier)}'
    );

    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return [];

      final data = json.decode(res.body) as Map<String, dynamic>;
      final prices = data['prices'] as List<dynamic>? ?? [];
      final volumes = data['total_volumes'] as List<dynamic>? ?? [];

      // Volumen mapa za brzi lookup
      final volMap = <int, double>{};
      for (final v in volumes) {
        final entry = v as List<dynamic>;
        volMap[(entry[0] as num).toInt()] =
            (entry[1] as num).toDouble();
      }

      return prices.map((p) {
        final entry = p as List<dynamic>;
        final ts = (entry[0] as num).toInt();
        return PricePoint(
          timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
          price: (entry[1] as num).toDouble(),
          volume: volMap[ts],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  int _daysForTier(InvestmentTier tier) {
    switch (tier) {
      case InvestmentTier.short: return 10;
      case InvestmentTier.mid:   return 180;
      case InvestmentTier.long:  return 730;
    }
  }

  String _intervalForTier(InvestmentTier tier) {
    switch (tier) {
      case InvestmentTier.short: return 'hourly';
      case InvestmentTier.mid:   return 'daily';
      case InvestmentTier.long:  return 'daily';
    }
  }

  /// Gradi TradeEvent listu iz Binance pozicija (SHORT)
  List<TradeEvent> buildTradeEventsFromPosition(CoinPosition pos) {
    final events = <TradeEvent>[];
    events.add(TradeEvent(
      timestamp: pos.entryTime,
      price: pos.entryPrice,
      type: TradeEventType.buy,
      amountUsdt: pos.entryTotal,
    ));
    return events;
  }

  /// Gradi TradeEvent listu iz DEX pozicija (SHORT)
  List<TradeEvent> buildTradeEventsFromDex(DexPosition pos) {
    return [
      TradeEvent(
        timestamp: pos.entryTime,
        price: pos.entryPrice,
        type: TradeEventType.buy,
        amountUsdt: pos.entryAmountUsdt,
      ),
    ];
  }

  /// Gradi TradeEvent listu iz LONG DCA historije
  List<TradeEvent> buildTradeEventsFromHolding(LongTermHolding holding) {
    return holding.purchases.map((p) => TradeEvent(
      timestamp: p.date,
      price: p.price,
      type: TradeEventType.dca,
      amountUsdt: p.amountUsdt,
    )).toList();
  }

  /// Generira predikciju na temelju Claude output teksta
  ///
  /// Claude u analizi sada vraća strukturirane predikcijske podatke
  /// Parsiramo ih iz Claude odgovora
  List<PricePoint> parsePredictionFromClaude({
    required String claudeResponse,
    required double currentPrice,
    required InvestmentTier tier,
  }) {
    // Pokušaj parsirati PREDICTION_DATA blok iz Claude odgovora
    final predictionRegex = RegExp(
      r'PREDICTION_DATA:\s*\{([^}]+)\}',
      dotAll: true,
    );
    final match = predictionRegex.firstMatch(claudeResponse);

    if (match != null) {
      try {
        final jsonStr = '{${match.group(1)}}';
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        return _buildPredictionPoints(data, currentPrice, tier);
      } catch (_) {
        // Fallback na sentiment-based predikciju
      }
    }

    // Fallback: sentiment analiza iz teksta
    return _buildSentimentPrediction(claudeResponse, currentPrice, tier);
  }

  List<PricePoint> _buildPredictionPoints(
    Map<String, dynamic> data,
    double currentPrice,
    InvestmentTier tier,
  ) {
    final targetPrice = (data['target'] as num?)?.toDouble() ?? currentPrice;
    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.5;
    final isBullish = data['direction'] as bool? ?? true;

    return _generatePredictionCurve(
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      confidence: confidence,
      isBullish: isBullish,
      tier: tier,
    );
  }

  List<PricePoint> _buildSentimentPrediction(
    String response,
    double currentPrice,
    InvestmentTier tier,
  ) {
    // Sentiment score iz ključnih riječi
    final bullishWords = [
      'INTERESTING', 'ENTER', 'STRONG_HOLD', 'CONDITIONAL_HOLD',
      'rast', 'pozitivno', 'potencijal', 'momentum',
    ];
    final bearishWords = [
      'SKIP', 'AVOID', 'AVOID_LONG', 'pump', 'dump',
      'rizik', 'negativno', 'pad',
    ];

    int bullScore = bullishWords
        .where((w) => response.contains(w)).length;
    int bearScore = bearishWords
        .where((w) => response.contains(w)).length;

    final isBullish = bullScore > bearScore;
    final confidence = (bullScore + bearScore) > 0
        ? bullScore / (bullScore + bearScore)
        : 0.5;

    // Target price — bullish: +15-40%, bearish: -10-25%
    final targetMultiplier = isBullish
        ? 1.0 + (0.15 + (confidence * 0.25))
        : 1.0 - (0.10 + (confidence * 0.15));
    final targetPrice = currentPrice * targetMultiplier;

    return _generatePredictionCurve(
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      confidence: confidence,
      isBullish: isBullish,
      tier: tier,
    );
  }

  List<PricePoint> _generatePredictionCurve({
    required double currentPrice,
    required double targetPrice,
    required double confidence,
    required bool isBullish,
    required InvestmentTier tier,
  }) {
    final points = <PricePoint>[];
    final now = DateTime.now();

    int predictionPoints;
    Duration step;

    switch (tier) {
      case InvestmentTier.short:
        predictionPoints = 24; // 24 sata
        step = const Duration(hours: 1);
        break;
      case InvestmentTier.mid:
        predictionPoints = 30; // 30 dana
        step = const Duration(days: 1);
        break;
      case InvestmentTier.long:
        predictionPoints = 26; // 26 tjedana (~6 mjeseci)
        step = const Duration(days: 7);
        break;
    }

    // Uncertainty band — širi se s vremenom
    final priceRange = (targetPrice - currentPrice).abs();
    final baseUncertainty = priceRange * (1 - confidence) * 0.5;

    for (int i = 0; i <= predictionPoints; i++) {
      final progress = i / predictionPoints;
      // S-curve interpolacija (sporiji početak, brži sredina, sporiji kraj)
      final sCurve = progress < 0.5
          ? 2 * progress * progress
          : -1 + (4 - 2 * progress) * progress;

      final predictedPrice = currentPrice +
          (targetPrice - currentPrice) * sCurve;

      // Uncertainty band raste s vremenom
      final uncertainty = baseUncertainty * progress;

      points.add(PricePoint(
        timestamp: now.add(step * i),
        price: predictedPrice,
        priceMin: predictedPrice - uncertainty,
        priceMax: predictedPrice + uncertainty,
      ));
    }

    return points;
  }
}
