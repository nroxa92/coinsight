class AnalysisLog {
  final DateTime timestamp;
  final String coinId;
  final String coinSymbol;
  final double priceAtAnalysis;
  final String claudeRecommendation;
  final String recommendationType;

  AnalysisLog({
    required this.timestamp,
    required this.coinId,
    required this.coinSymbol,
    required this.priceAtAnalysis,
    required this.claudeRecommendation,
    required this.recommendationType,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'coin_id': coinId,
        'coin_symbol': coinSymbol,
        'price_at_analysis': priceAtAnalysis,
        'claude_recommendation': claudeRecommendation,
        'recommendation_type': recommendationType,
      };

  factory AnalysisLog.fromMap(Map<dynamic, dynamic> map) => AnalysisLog(
        timestamp: DateTime.parse(map['timestamp'] as String),
        coinId: map['coin_id'] as String,
        coinSymbol: map['coin_symbol'] as String,
        priceAtAnalysis: (map['price_at_analysis'] as num).toDouble(),
        claudeRecommendation: map['claude_recommendation'] as String,
        recommendationType: map['recommendation_type'] as String,
      );

  static String parseRecommendationType(String claudeResponse) {
    if (claudeResponse.contains('**INTERESTING**')) return 'INTERESTING';
    if (claudeResponse.contains('**WATCH**')) return 'WATCH';
    if (claudeResponse.contains('**SKIP**')) return 'SKIP';
    return 'NONE';
  }
}
