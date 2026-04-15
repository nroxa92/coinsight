import 'package:coinsight/models/coin.dart';

class TradeProposal {
  final Coin coin;
  final double amountUsdt;
  final double estimatedQty;
  final double currentPrice;
  final double stopLossPrice;
  final double takeProfitPrice;
  final String claudeRecommendation;
  final DateTime createdAt;

  TradeProposal({
    required this.coin,
    required this.amountUsdt,
    required this.estimatedQty,
    required this.currentPrice,
    required this.stopLossPrice,
    required this.takeProfitPrice,
    required this.claudeRecommendation,
    required this.createdAt,
  });

  bool get isExpired =>
      DateTime.now().difference(createdAt).inSeconds > 60;
}
