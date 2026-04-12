class Coin {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double priceChangePercentage24h;
  final double? priceChangePercentage1h;
  final double high24h;
  final double low24h;
  final double totalVolume;
  final List<double>? sparklineIn7d;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
    this.priceChangePercentage1h,
    required this.high24h,
    required this.low24h,
    required this.totalVolume,
    this.sparklineIn7d,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    final sparkline = json['sparkline_in_7d']?['price'] as List<dynamic>?;
    return Coin(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      priceChangePercentage1h:
          (json['price_change_percentage_1h_in_currency'] as num?)?.toDouble(),
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      sparklineIn7d: sparkline?.map((e) => (e as num).toDouble()).toList(),
    );
  }
}
