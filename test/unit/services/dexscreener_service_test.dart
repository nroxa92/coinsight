import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/services/dexscreener_service.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() => registerFallbacks());

  // Helper to create pair JSON
  Map<String, dynamic> makePairJson({
    String symbol = 'NEWTOKEN',
    String name = 'New Token',
    double liquidityUsd = 50000,
    double volumeH24 = 20000,
    int hoursAgo = 6,
    String chainId = 'ethereum',
  }) {
    return {
      'pairAddress': '0xpair_${symbol.toLowerCase()}',
      'baseToken': {
        'symbol': symbol,
        'name': name,
        'address': '0xtoken_${symbol.toLowerCase()}',
      },
      'quoteToken': {'symbol': 'WETH'},
      'dexId': 'uniswap',
      'chainId': chainId,
      'priceUsd': '0.001',
      'volume': {'h24': volumeH24},
      'liquidity': {'usd': liquidityUsd},
      'priceChange': {'h1': 2.0, 'h24': 5.0},
      'pairCreatedAt':
          DateTime.now().subtract(Duration(hours: hoursAgo)).millisecondsSinceEpoch ~/
              1000,
    };
  }

  group('DexscreenerService', () {
    group('getNewPairs', () {
      test('filters by minimum liquidity', () async {
        final pairs = [
          makePairJson(symbol: 'GOOD', liquidityUsd: 50000, volumeH24: 10000),
          makePairJson(symbol: 'LOW', liquidityUsd: 500, volumeH24: 10000),
        ];
        final client = HttpClientFactory.returning(
          json.encode({'pairs': pairs}),
        );
        final service = DexscreenerService(client: client);
        final results = await service.getNewPairs();
        expect(results.every((s) => s.hasMinimumLiquidity), true);
        expect(results.any((s) => s.baseTokenSymbol == 'LOW'), false);
      });

      test('filters stablecoins', () async {
        final pairs = [
          makePairJson(symbol: 'NEWTOKEN', liquidityUsd: 50000, volumeH24: 10000),
          makePairJson(symbol: 'USDT', liquidityUsd: 50000, volumeH24: 10000),
          makePairJson(symbol: 'USDC', liquidityUsd: 50000, volumeH24: 10000),
        ];
        final client = HttpClientFactory.returning(
          json.encode({'pairs': pairs}),
        );
        final service = DexscreenerService(client: client);
        final results = await service.getNewPairs();
        expect(results.any((s) => s.baseTokenSymbol == 'USDT'), false);
        expect(results.any((s) => s.baseTokenSymbol == 'USDC'), false);
      });

      test('filters large caps', () async {
        final pairs = [
          makePairJson(symbol: 'NEWTOKEN', liquidityUsd: 50000, volumeH24: 10000),
          makePairJson(symbol: 'BTC', liquidityUsd: 50000, volumeH24: 10000),
          makePairJson(symbol: 'ETH', liquidityUsd: 50000, volumeH24: 10000),
        ];
        final client = HttpClientFactory.returning(
          json.encode({'pairs': pairs}),
        );
        final service = DexscreenerService(client: client);
        final results = await service.getNewPairs();
        expect(results.any((s) => s.baseTokenSymbol == 'BTC'), false);
        expect(results.any((s) => s.baseTokenSymbol == 'ETH'), false);
      });
    });

    group('searchBySymbol', () {
      test('returns highest liquidity pair', () async {
        final pairs = [
          makePairJson(symbol: 'XYZ', liquidityUsd: 30000),
          makePairJson(symbol: 'XYZ', liquidityUsd: 80000),
          makePairJson(symbol: 'XYZ', liquidityUsd: 50000),
        ];
        final client = HttpClientFactory.returning(
          json.encode({'pairs': pairs}),
        );
        final service = DexscreenerService(client: client);
        final result = await service.searchBySymbol('XYZ');
        expect(result, isNotNull);
        expect(result!.liquidityUsd, 80000);
      });

      test('returns null for unknown symbol', () async {
        final client = HttpClientFactory.returning(
          json.encode({'pairs': []}),
        );
        final service = DexscreenerService(client: client);
        final result = await service.searchBySymbol('UNKNOWNXYZ');
        expect(result, isNull);
      });

      test('returns null when all pairs below minimum liquidity', () async {
        final pairs = [
          makePairJson(symbol: 'LOW', liquidityUsd: 500),
          makePairJson(symbol: 'LOW', liquidityUsd: 1000),
        ];
        final client = HttpClientFactory.returning(
          json.encode({'pairs': pairs}),
        );
        final service = DexscreenerService(client: client);
        final result = await service.searchBySymbol('LOW');
        expect(result, isNull);
      });

      test('handles timeout gracefully', () async {
        final client = HttpClientFactory.throwingTimeout();
        final service = DexscreenerService(client: client);
        final result = await service.searchBySymbol('XYZ');
        expect(result, isNull);
      });
    });
  });
}
