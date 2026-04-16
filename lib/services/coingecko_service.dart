import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/coin.dart';

class CoinGeckoService {
  static const _baseUrl = 'https://api.coingecko.com/api/v3';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  CoinGeckoService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Coin>> getMarketData({
    String vsCurrency = 'usd',
    List<String>? ids,
    int perPage = 20,
    int page = 1,
    bool sparkline = true,
  }) async {
    final queryParams = {
      'vs_currency': vsCurrency,
      'order': 'market_cap_desc',
      'per_page': perPage.toString(),
      'page': page.toString(),
      'sparkline': sparkline.toString(),
      if (ids != null && ids.isNotEmpty) 'ids': ids.join(','),
    };

    final uri = Uri.parse('$_baseUrl/coins/markets')
        .replace(queryParameters: queryParams);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw CoinGeckoException('Request timed out. Check your connection.');
    }

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Coin.fromJson(item)).toList();
      } on FormatException {
        throw CoinGeckoException('Invalid response from server.');
      }
    } else if (response.statusCode == 429) {
      throw CoinGeckoException('Rate limited. Please wait a moment.');
    } else {
      throw CoinGeckoException(
        'Failed to fetch market data (${response.statusCode})',
      );
    }
  }

  Future<List<Coin>> getNewListings({
    String vsCurrency = 'usd',
    int perPage = 100,
  }) async {
    final queryParams = {
      'vs_currency': vsCurrency,
      'order': 'volume_desc',
      'per_page': perPage.toString(),
      'page': '1',
      'sparkline': 'true',
      'price_change_percentage': '1h,24h',
    };

    final uri = Uri.parse('$_baseUrl/coins/markets')
        .replace(queryParameters: queryParams);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw CoinGeckoException('Request timed out. Check your connection.');
    }

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final allCoins = data.map((item) => Coin.fromJson(item)).toList();

        return allCoins.where((coin) {
          final rankIsNew = coin.marketCapRank == 0 || coin.marketCapRank > 500;
          final volumeInRange =
              coin.totalVolume >= 50000 && coin.totalVolume <= 50000000;
          final hasChange = coin.priceChangePercentage24h != 0;
          return rankIsNew && volumeInRange && hasChange;
        }).toList()
          ..sort((a, b) {
            final a1h = a.priceChangePercentage1h ?? 0;
            final b1h = b.priceChangePercentage1h ?? 0;
            return b1h.compareTo(a1h);
          });
      } on FormatException {
        throw CoinGeckoException('Invalid response from server.');
      }
    } else if (response.statusCode == 429) {
      throw CoinGeckoException('Rate limited. Please wait a moment.');
    } else {
      throw CoinGeckoException(
        'Failed to fetch new listings (${response.statusCode})',
      );
    }
  }

  Future<List<Coin>> searchAndFetch(String query) async {
    final searchUri = Uri.parse('$_baseUrl/search')
        .replace(queryParameters: {'query': query});

    final http.Response searchResponse;
    try {
      searchResponse = await _client.get(searchUri).timeout(_timeout);
    } on TimeoutException {
      throw CoinGeckoException('Search timed out. Check your connection.');
    }

    if (searchResponse.statusCode != 200) {
      throw CoinGeckoException('Search failed (${searchResponse.statusCode})');
    }

    try {
      final searchData = json.decode(searchResponse.body);
      final coins = searchData['coins'] as List<dynamic>?;
      if (coins == null || coins.isEmpty) return [];

      final ids = coins.take(10).map((c) => c['id'] as String).toList();
      return getMarketData(ids: ids);
    } on FormatException {
      throw CoinGeckoException('Invalid search response from server.');
    }
  }

  /// Traži coin po simbolu — vraća do 5 rezultata
  Future<List<Coin>> searchBySymbol(String symbol) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/markets'
      '?vs_currency=usd'
      '&order=volume_desc'
      '&per_page=250'
      '&sparkline=false'
      '&price_change_percentage=1h,24h',
    );

    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return [];

      final List<dynamic> data = json.decode(res.body);
      return data
          .map((item) => Coin.fromJson(item))
          .where((c) =>
              c.symbol.toUpperCase() == symbol.toUpperCase() ||
              c.name.toLowerCase().contains(symbol.toLowerCase()))
          .take(5)
          .toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}

class CoinGeckoException implements Exception {
  final String message;
  CoinGeckoException(this.message);

  @override
  String toString() => message;
}
