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
