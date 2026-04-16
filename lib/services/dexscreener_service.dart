import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/dexscreener_signal.dart';

/// DexscreenerService — prati DEX listinge na svim major chainsima
///
/// Dexscreener je aggregator podataka za decentralizirane burze.
/// Novi par na DEX-u (Uniswap, PancakeSwap, Raydium) obično prethodi
/// CEX listingu za 1-14 dana — ovo je najraniji dostupni signal.
///
/// Besplatan API, bez ključa, rate limit ~300 req/min.
class DexscreenerService {
  static const _baseUrl = 'https://api.dexscreener.com/latest/dex';
  static const _timeout = Duration(seconds: 15);

  static const List<String> monitoredChains = [
    'ethereum',
    'bsc',
    'solana',
    'polygon',
    'arbitrum',
    'base',
  ];

  static const double _minVolumeUsd = 5000;
  static const int _maxAgeHours = 48;

  final http.Client _client;

  DexscreenerService({http.Client? client})
      : _client = client ?? http.Client();

  /// Dohvaća najnovije parove na svim praćenim chainsima
  Future<List<DexscreenerSignal>> getNewPairs() async {
    final List<DexscreenerSignal> results = [];

    for (final chain in monitoredChains) {
      try {
        final chainPairs = await _getNewPairsForChain(chain);
        results.addAll(chainPairs);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {
        continue;
      }
    }

    results.sort((a, b) => a.ageHours.compareTo(b.ageHours));
    return results;
  }

  /// Pretraži par po simbolu
  Future<DexscreenerSignal?> searchBySymbol(String symbol) async {
    final uri = Uri.parse(
      '$_baseUrl/search?q=${Uri.encodeQueryComponent(symbol)}',
    );

    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final pairs = data['pairs'] as List<dynamic>? ?? [];
      if (pairs.isEmpty) return null;

      final signals = pairs
          .map((p) =>
              DexscreenerSignal.fromJson(p as Map<String, dynamic>))
          .where((s) => s.hasMinimumLiquidity)
          .toList();

      if (signals.isEmpty) return null;
      signals.sort((a, b) => b.liquidityUsd.compareTo(a.liquidityUsd));
      return signals.first;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<DexscreenerSignal>> _getNewPairsForChain(
      String chain) async {
    final uri = Uri.parse('$_baseUrl/pairs/$chain');

    late http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw DexscreenerException('Request timed out for chain: $chain');
    }

    if (res.statusCode != 200) return [];

    try {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final pairs = data['pairs'] as List<dynamic>? ?? [];

      return pairs
          .map((p) =>
              DexscreenerSignal.fromJson(p as Map<String, dynamic>))
          .where(_isRelevant)
          .toList();
    } on FormatException {
      return [];
    }
  }

  /// Dohvaća trenutnu cijenu tokena po contract adresi i chainu
  Future<double?> getPriceByContract(
      String contractAddress, String chainId) async {
    final uri = Uri.parse(
      '$_baseUrl/tokens/$contractAddress',
    );

    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final pairs = data['pairs'] as List<dynamic>? ?? [];
      if (pairs.isEmpty) return null;

      // Filter to matching chain, sort by liquidity, return highest priceUsd
      final matching = pairs
          .map((p) => p as Map<String, dynamic>)
          .where((p) => (p['chainId'] as String?) == chainId)
          .toList();

      if (matching.isEmpty) {
        // Fallback: use any chain pair
        final firstPrice =
            double.tryParse(pairs.first['priceUsd']?.toString() ?? '');
        return firstPrice;
      }

      // Sort by liquidity descending
      matching.sort((a, b) {
        final liqA =
            (a['liquidity'] as Map<String, dynamic>?)?['usd'] as num? ?? 0;
        final liqB =
            (b['liquidity'] as Map<String, dynamic>?)?['usd'] as num? ?? 0;
        return liqB.compareTo(liqA);
      });

      return double.tryParse(
          matching.first['priceUsd']?.toString() ?? '');
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isRelevant(DexscreenerSignal signal) {
    if (!signal.hasMinimumLiquidity) return false;
    if (signal.volumeUsd24h < _minVolumeUsd) return false;
    if (signal.ageHours > _maxAgeHours) return false;

    final stablecoins = [
      'USDT', 'USDC', 'BUSD', 'DAI', 'FRAX', 'TUSD'
    ];
    if (stablecoins.contains(signal.baseTokenSymbol.toUpperCase())) {
      return false;
    }

    final largeCaps = ['BTC', 'ETH', 'BNB', 'SOL', 'MATIC', 'AVAX'];
    if (largeCaps.contains(signal.baseTokenSymbol.toUpperCase())) {
      return false;
    }

    return true;
  }
}

class DexscreenerException implements Exception {
  final String message;
  DexscreenerException(this.message);
}
