import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/services/storage_service.dart';

class BinanceException implements Exception {
  final String message;
  final int? code;
  BinanceException(this.message, {this.code});

  @override
  String toString() =>
      code != null ? 'BinanceException($code): $message' : 'BinanceException: $message';
}

class BinanceOrder {
  final String orderId;
  final String symbol;
  final String side;
  final String status;
  final double executedQty;
  final double cummulativeQuoteQty;
  final DateTime transactTime;

  BinanceOrder({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.status,
    required this.executedQty,
    required this.cummulativeQuoteQty,
    required this.transactTime,
  });

  double get avgPrice =>
      executedQty == 0 ? 0 : cummulativeQuoteQty / executedQty;

  factory BinanceOrder.fromJson(Map<String, dynamic> json) {
    final tsRaw = json['transactTime'] ?? json['time'] ?? 0;
    return BinanceOrder(
      orderId: json['orderId'].toString(),
      symbol: json['symbol'] as String,
      side: json['side'] as String? ?? '',
      status: json['status'] as String? ?? '',
      executedQty:
          double.tryParse(json['executedQty']?.toString() ?? '0') ?? 0,
      cummulativeQuoteQty: double.tryParse(
              json['cummulativeQuoteQty']?.toString() ?? '0') ??
          0,
      transactTime: DateTime.fromMillisecondsSinceEpoch(tsRaw as int),
    );
  }
}

class BinanceService {
  static const _prodUrl = 'https://api.binance.com';
  static const _testnetUrl = 'https://testnet.binance.vision';
  static const _timeout = Duration(seconds: 15);
  static const _recvWindow = 5000;

  final http.Client _client;
  String? _apiKey;
  String? _apiSecret;
  bool _useTestnet;
  final Map<String, int> _lotSizeCache = {};
  int _serverTimeOffsetMs = 0;

  BinanceService({http.Client? client})
      : _client = client ?? http.Client(),
        _useTestnet = StorageService.getBinanceTestnet() {
    _apiKey = StorageService.getBinanceApiKey();
    _apiSecret = StorageService.getBinanceSecret();
  }

  String get _baseUrl => _useTestnet ? _testnetUrl : _prodUrl;
  bool get hasCredentials =>
      (_apiKey?.isNotEmpty ?? false) && (_apiSecret?.isNotEmpty ?? false);
  bool get isTestnet => _useTestnet;
  int get serverTimeOffsetMs => _serverTimeOffsetMs;

  void reloadCredentials() {
    _apiKey = StorageService.getBinanceApiKey();
    _apiSecret = StorageService.getBinanceSecret();
    _useTestnet = StorageService.getBinanceTestnet();
  }

  String _sign(String queryString) {
    final key = utf8.encode(_apiSecret!);
    final msg = utf8.encode(queryString);
    final hmac = Hmac(sha256, key);
    return hmac.convert(msg).toString();
  }

  Map<String, String> get _headers => {
        'X-MBX-APIKEY': _apiKey ?? '',
      };

  String _buildQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }

  String _signedQuery(Map<String, String> params) {
    final withTs = {
      ...params,
      'timestamp': _correctedTimestamp.toString(),
      'recvWindow': _recvWindow.toString(),
    };
    final qs = _buildQuery(withTs);
    final sig = _sign(qs);
    return '$qs&signature=$sig';
  }

  Never _throwForResponse(http.Response response) {
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final code = body['code'] as int?;
      final msg = body['msg'] as String? ?? 'Unknown Binance error';
      if (code == -1021) {
        syncServerTime(); // fire-and-forget resync
        throw BinanceException(
          'Sat uređaja nije sinkroniziran s Binance serverom. '
          'Pokušaj ponovo — offset je korigiran.',
          code: code,
        );
      }
      if (code == -2010) {
        throw BinanceException('Insufficient balance or order rejected',
            code: code);
      }
      if (code == -1100 || code == -1121) {
        throw BinanceException('Symbol not available on Binance', code: code);
      }
      throw BinanceException(msg, code: code);
    } on FormatException {
      throw BinanceException(
          'Binance request failed (${response.statusCode})');
    }
  }

  Future<bool> ping() async {
    try {
      final res = await _client
          .get(Uri.parse('$_baseUrl/api/v3/ping'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        await syncServerTime();
        return true;
      }
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<double> getUsdtBalance() async {
    if (!hasCredentials) {
      throw BinanceException('Binance credentials not configured');
    }
    final qs = _signedQuery({});
    final uri = Uri.parse('$_baseUrl/api/v3/account?$qs');
    late http.Response res;
    try {
      res = await _client.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw BinanceException('Binance request timed out');
    }
    if (res.statusCode != 200) _throwForResponse(res);

    try {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final balances = data['balances'] as List<dynamic>? ?? [];
      for (final b in balances) {
        final entry = b as Map<String, dynamic>;
        if (entry['asset'] == 'USDT') {
          return double.tryParse(entry['free']?.toString() ?? '0') ?? 0;
        }
      }
      return 0;
    } on FormatException {
      throw BinanceException('Invalid response from Binance');
    }
  }

  Future<double> getCurrentPrice(String symbol) async {
    final uri =
        Uri.parse('$_baseUrl/api/v3/ticker/price?symbol=$symbol');
    late http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw BinanceException('Binance request timed out');
    }
    if (res.statusCode != 200) _throwForResponse(res);

    try {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return double.tryParse(data['price']?.toString() ?? '0') ?? 0;
    } on FormatException {
      throw BinanceException('Invalid response from Binance');
    }
  }

  Future<BinanceOrder> placeBuyOrder(
      String symbol, double quoteAmount) async {
    if (!hasCredentials) {
      throw BinanceException('Binance credentials not configured');
    }
    final qs = _signedQuery({
      'symbol': symbol,
      'side': 'BUY',
      'type': 'MARKET',
      'quoteOrderQty': quoteAmount.toStringAsFixed(2),
    });
    final uri = Uri.parse('$_baseUrl/api/v3/order?$qs');
    late http.Response res;
    try {
      res = await _client.post(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw BinanceException('Binance request timed out');
    }
    if (res.statusCode != 200) _throwForResponse(res);

    try {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return BinanceOrder.fromJson(data);
    } on FormatException {
      throw BinanceException('Invalid order response from Binance');
    }
  }

  Future<BinanceOrder> placeSellOrder(
      String symbol, double quantity) async {
    if (!hasCredentials) {
      throw BinanceException('Binance credentials not configured');
    }
    final decimals = await _getLotSizeDecimals(symbol);
    final qs = _signedQuery({
      'symbol': symbol,
      'side': 'SELL',
      'type': 'MARKET',
      'quantity': quantity.toStringAsFixed(decimals),
    });
    final uri = Uri.parse('$_baseUrl/api/v3/order?$qs');
    late http.Response res;
    try {
      res = await _client.post(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw BinanceException('Binance request timed out');
    }
    if (res.statusCode != 200) _throwForResponse(res);

    try {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return BinanceOrder.fromJson(data);
    } on FormatException {
      throw BinanceException('Invalid order response from Binance');
    }
  }

  List<CoinPosition> getOpenPositions() => StorageService.getPositions();

  Future<List<BinanceOrder>> getOrderHistory(String symbol) async {
    if (!hasCredentials) {
      throw BinanceException('Binance credentials not configured');
    }
    final qs = _signedQuery({'symbol': symbol, 'limit': '10'});
    final uri = Uri.parse('$_baseUrl/api/v3/allOrders?$qs');
    late http.Response res;
    try {
      res = await _client.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw BinanceException('Binance request timed out');
    }
    if (res.statusCode != 200) _throwForResponse(res);

    try {
      final data = json.decode(res.body) as List<dynamic>;
      return data
          .map((o) => BinanceOrder.fromJson(o as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw BinanceException('Invalid response from Binance');
    }
  }

  // ───────── Server Time Sync ─────────

  int get _correctedTimestamp =>
      DateTime.now().millisecondsSinceEpoch + _serverTimeOffsetMs;

  Future<void> syncServerTime() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v3/time');
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final serverTime = data['serverTime'] as int?;
      if (serverTime == null) return;

      final localTime = DateTime.now().millisecondsSinceEpoch;
      _serverTimeOffsetMs = serverTime - localTime;
    } catch (_) {
      _serverTimeOffsetMs = 0;
    }
  }

  // ───────── LOT_SIZE Dynamic Precision ─────────

  Future<int> _getLotSizeDecimals(String symbol) async {
    if (_lotSizeCache.containsKey(symbol)) {
      return _lotSizeCache[symbol]!;
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/v3/exchangeInfo?symbol=${Uri.encodeQueryComponent(symbol)}',
      );
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return 6;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final symbols = data['symbols'] as List<dynamic>? ?? [];
      if (symbols.isEmpty) return 6;

      final symbolInfo = symbols.first as Map<String, dynamic>;
      final filters = symbolInfo['filters'] as List<dynamic>? ?? [];

      for (final f in filters) {
        final filter = f as Map<String, dynamic>;
        if (filter['filterType'] == 'LOT_SIZE') {
          final stepSize = filter['stepSize'] as String? ?? '0.000001';
          final decimals = _stepSizeToDecimals(stepSize);
          _lotSizeCache[symbol] = decimals;
          return decimals;
        }
      }
    } catch (_) {
      // Fallback to 6 decimals if fetch fails
    }

    _lotSizeCache[symbol] = 6;
    return 6;
  }

  int _stepSizeToDecimals(String stepSize) {
    final normalized = stepSize.replaceAll(RegExp(r'0+$'), '');
    final dotIndex = normalized.indexOf('.');
    if (dotIndex == -1) return 0;
    final decimals = normalized.length - dotIndex - 1;
    return decimals < 0 ? 0 : decimals;
  }
}
