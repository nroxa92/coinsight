import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/services/coingecko_service.dart';
import '../../helpers/mock_http_client.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() => registerFallbacks());

  group('CoinGeckoService', () {
    test('getMarketData returns list of coins on 200 response', () async {
      final client = HttpClientFactory.returning(
        json.encode([TestFixtures.coinJson()]),
      );
      final service = CoinGeckoService(client: client);
      final coins = await service.getMarketData();

      expect(coins.length, 1);
      expect(coins.first.id, 'bitcoin');
      expect(coins.first.currentPrice, 71867.10);
    });

    test('getMarketData throws CoinGeckoException on 429 rate limit',
        () async {
      final client = HttpClientFactory.returning('', statusCode: 429);
      final service = CoinGeckoService(client: client);

      expect(
        () => service.getMarketData(),
        throwsA(isA<CoinGeckoException>()),
      );
    });

    test('getMarketData throws CoinGeckoException on network timeout',
        () async {
      final client = HttpClientFactory.throwingTimeout();
      final service = CoinGeckoService(client: client);

      expect(
        () => service.getMarketData(),
        throwsA(isA<CoinGeckoException>()),
      );
    });

    test('getMarketData handles malformed JSON gracefully', () async {
      final client = HttpClientFactory.returning('not json');
      final service = CoinGeckoService(client: client);

      expect(
        () => service.getMarketData(),
        throwsA(isA<CoinGeckoException>()),
      );
    });

    test('getNewListings filters coins correctly', () async {
      final coins = [
        // Should pass: rank 0, volume in range, has change
        TestFixtures.coinJson(
          id: 'new1',
          marketCapRank: 0,
          totalVolume: 100000,
          priceChange24h: 10.0,
          priceChange1h: 5.0,
        ),
        // Should fail: rank 1 (established)
        TestFixtures.coinJson(
          id: 'btc',
          marketCapRank: 1,
          totalVolume: 100000,
          priceChange24h: 2.0,
        ),
        // Should pass: rank > 500
        TestFixtures.coinJson(
          id: 'new2',
          marketCapRank: 600,
          totalVolume: 200000,
          priceChange24h: 5.0,
          priceChange1h: 2.0,
        ),
        // Should fail: volume too low
        TestFixtures.coinJson(
          id: 'low-vol',
          marketCapRank: 0,
          totalVolume: 100,
          priceChange24h: 10.0,
        ),
        // Should fail: volume too high
        TestFixtures.coinJson(
          id: 'high-vol',
          marketCapRank: 0,
          totalVolume: 100000000,
          priceChange24h: 10.0,
        ),
        // Should fail: no price change (stale)
        TestFixtures.coinJson(
          id: 'stale',
          marketCapRank: 0,
          totalVolume: 100000,
          priceChange24h: 0.0,
        ),
      ];

      final client =
          HttpClientFactory.returning(json.encode(coins));
      final service = CoinGeckoService(client: client);
      final result = await service.getNewListings();

      expect(result.length, 2);
      expect(result.map((c) => c.id).toList(), ['new1', 'new2']);
    });

    test('getNewListings sorts by 1h price change descending', () async {
      final coins = [
        TestFixtures.coinJson(
          id: 'low',
          marketCapRank: 0,
          totalVolume: 100000,
          priceChange24h: 5.0,
          priceChange1h: 1.0,
        ),
        TestFixtures.coinJson(
          id: 'high',
          marketCapRank: 0,
          totalVolume: 100000,
          priceChange24h: 5.0,
          priceChange1h: 10.0,
        ),
      ];

      final client =
          HttpClientFactory.returning(json.encode(coins));
      final service = CoinGeckoService(client: client);
      final result = await service.getNewListings();

      expect(result.first.id, 'high');
      expect(result.last.id, 'low');
    });

    test('getMarketData throws CoinGeckoException on non-200/429 status',
        () async {
      final client = HttpClientFactory.returning('', statusCode: 500);
      final service = CoinGeckoService(client: client);

      expect(
        () => service.getMarketData(),
        throwsA(isA<CoinGeckoException>()),
      );
    });
  });
}
