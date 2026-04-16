import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/coin.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('Coin', () {
    test('fromJson parses complete JSON correctly', () {
      final json = TestFixtures.coinJson();
      final coin = Coin.fromJson(json);

      expect(coin.id, 'bitcoin');
      expect(coin.symbol, 'btc');
      expect(coin.name, 'Bitcoin');
      expect(coin.currentPrice, 71867.10);
      expect(coin.marketCap, 1400000000000);
      expect(coin.marketCapRank, 1);
      expect(coin.priceChangePercentage24h, 2.3);
      expect(coin.high24h, 72000);
      expect(coin.low24h, 70000);
      expect(coin.totalVolume, 28000000000);
    });

    test('fromJson handles null numeric fields with fallback to 0', () {
      final json = TestFixtures.coinJson(
        currentPrice: null,
        marketCap: null,
        marketCapRank: null,
        priceChange24h: null,
        high24h: null,
        low24h: null,
        totalVolume: null,
      );
      final coin = Coin.fromJson(json);

      expect(coin.currentPrice, 0);
      expect(coin.marketCap, 0);
      expect(coin.marketCapRank, 0);
      expect(coin.priceChangePercentage24h, 0);
      expect(coin.high24h, 0);
      expect(coin.low24h, 0);
      expect(coin.totalVolume, 0);
    });

    test('fromJson parses 1h price change when present', () {
      final json = TestFixtures.coinJson(priceChange1h: 3.5);
      final coin = Coin.fromJson(json);
      expect(coin.priceChangePercentage1h, 3.5);
    });

    test('fromJson returns null for 1h price change when absent', () {
      final json = TestFixtures.coinJson(priceChange1h: null);
      final coin = Coin.fromJson(json);
      expect(coin.priceChangePercentage1h, isNull);
    });

    test('fromJson parses sparkline data', () {
      final json = TestFixtures.coinJson();
      json['sparkline_in_7d'] = {
        'price': [100.0, 101.0, 102.0]
      };
      final coin = Coin.fromJson(json);
      expect(coin.sparklineIn7d, [100.0, 101.0, 102.0]);
    });

    test('fromJson handles missing sparkline', () {
      final json = TestFixtures.coinJson();
      json['sparkline_in_7d'] = null;
      final coin = Coin.fromJson(json);
      expect(coin.sparklineIn7d, isNull);
    });
  });
}
