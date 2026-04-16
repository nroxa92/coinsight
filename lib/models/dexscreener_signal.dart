/// Signal koji dolazi s Dexscreener API-ja
/// Dexscreener prati DEX listinge (Uniswap, PancakeSwap, itd.)
/// DEX listing prethodi CEX listingu za tipično 1-14 dana — najraniji signal
class DexscreenerSignal {
  final String pairAddress;
  final String baseTokenSymbol;
  final String baseTokenName;
  final String baseTokenAddress;
  final String quoteTokenSymbol;
  final String dexId;
  final String chainId;
  final double priceUsd;
  final double volumeUsd24h;
  final double liquidityUsd;
  final double priceChange1h;
  final double priceChange24h;
  final int pairCreatedAt;
  final DateTime detectedAt;

  DexscreenerSignal({
    required this.pairAddress,
    required this.baseTokenSymbol,
    required this.baseTokenName,
    required this.baseTokenAddress,
    required this.quoteTokenSymbol,
    required this.dexId,
    required this.chainId,
    required this.priceUsd,
    required this.volumeUsd24h,
    required this.liquidityUsd,
    required this.priceChange1h,
    required this.priceChange24h,
    required this.pairCreatedAt,
    required this.detectedAt,
  });

  int get ageHours {
    // pairCreatedAt = 0 znači nepoznato — tretiramo kao svjež (48h)
    if (pairCreatedAt == 0) return 48;
    final created =
        DateTime.fromMillisecondsSinceEpoch(pairCreatedAt * 1000);
    // Sanity check: par ne može biti kreiran u budućnosti
    if (created.isAfter(DateTime.now())) return 0;
    // Sanity check: par stariji od 30 dana vjerojatno nije novi listing
    final hours = DateTime.now().difference(created).inHours;
    return hours > 720 ? 720 : hours;
  }

  double get volumeLiquidityRatio =>
      liquidityUsd > 0 ? volumeUsd24h / liquidityUsd : 0;

  bool get hasMinimumLiquidity => liquidityUsd >= 10000;

  // isFresh sada koristi validiran ageHours
  bool get isFresh => ageHours <= 24;

  String toClaudeContext() {
    return '[DEX LISTING — ${dexId.toUpperCase()} na $chainId]\n'
        'Token: $baseTokenName ($baseTokenSymbol)\n'
        'Cijena: \$$priceUsd\n'
        'Volume 24h: \$${volumeUsd24h.toStringAsFixed(0)}\n'
        'Likvidnost: \$${liquidityUsd.toStringAsFixed(0)}\n'
        '1h: ${priceChange1h >= 0 ? "+" : ""}${priceChange1h.toStringAsFixed(2)}%\n'
        '24h: ${priceChange24h >= 0 ? "+" : ""}${priceChange24h.toStringAsFixed(2)}%\n'
        'Vol/Liq ratio: ${volumeLiquidityRatio.toStringAsFixed(2)}x\n'
        'Starost para: ${ageHours}h\n'
        'Status: ${isFresh ? "SVJEŽ" : "STARIJI"} | '
        'Likvidnost: ${hasMinimumLiquidity ? "OK" : "PREMALA"}';
  }

  factory DexscreenerSignal.fromJson(Map<String, dynamic> json) {
    final baseToken = json['baseToken'] as Map<String, dynamic>? ?? {};
    final quoteToken = json['quoteToken'] as Map<String, dynamic>? ?? {};
    final volume = json['volume'] as Map<String, dynamic>? ?? {};
    final priceChange = json['priceChange'] as Map<String, dynamic>? ?? {};
    final liquidity = json['liquidity'] as Map<String, dynamic>? ?? {};

    return DexscreenerSignal(
      pairAddress: json['pairAddress'] as String? ?? '',
      baseTokenSymbol: baseToken['symbol'] as String? ?? '',
      baseTokenName: baseToken['name'] as String? ?? '',
      baseTokenAddress: baseToken['address'] as String? ?? '',
      quoteTokenSymbol: quoteToken['symbol'] as String? ?? '',
      dexId: json['dexId'] as String? ?? '',
      chainId: json['chainId'] as String? ?? '',
      priceUsd:
          double.tryParse(json['priceUsd']?.toString() ?? '0') ?? 0,
      volumeUsd24h: (volume['h24'] as num?)?.toDouble() ?? 0,
      liquidityUsd: (liquidity['usd'] as num?)?.toDouble() ?? 0,
      priceChange1h: (priceChange['h1'] as num?)?.toDouble() ?? 0,
      priceChange24h: (priceChange['h24'] as num?)?.toDouble() ?? 0,
      pairCreatedAt: (json['pairCreatedAt'] as num?)?.toInt() ?? 0,
      detectedAt: DateTime.now(),
    );
  }
}
