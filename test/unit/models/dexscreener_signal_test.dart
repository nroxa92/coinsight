import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/dexscreener_signal.dart';

void main() {
  group('DexscreenerSignal', () {
    Map<String, dynamic> validJson() => {
          'pairAddress': '0xabc123',
          'baseToken': {
            'symbol': 'NEWTOKEN',
            'name': 'New Token',
            'address': '0xtoken123',
          },
          'quoteToken': {'symbol': 'WETH'},
          'dexId': 'uniswap',
          'chainId': 'ethereum',
          'priceUsd': '0.00123',
          'volume': {'h24': 50000.0},
          'liquidity': {'usd': 25000.0},
          'priceChange': {'h1': 5.2, 'h24': 12.5},
          'pairCreatedAt':
              DateTime.now().subtract(const Duration(hours: 6)).millisecondsSinceEpoch ~/
                  1000,
        };

    group('fromJson', () {
      test('parses all fields correctly', () {
        final signal = DexscreenerSignal.fromJson(validJson());
        expect(signal.pairAddress, '0xabc123');
        expect(signal.baseTokenSymbol, 'NEWTOKEN');
        expect(signal.baseTokenName, 'New Token');
        expect(signal.baseTokenAddress, '0xtoken123');
        expect(signal.quoteTokenSymbol, 'WETH');
        expect(signal.dexId, 'uniswap');
        expect(signal.chainId, 'ethereum');
        expect(signal.priceUsd, 0.00123);
        expect(signal.volumeUsd24h, 50000.0);
        expect(signal.liquidityUsd, 25000.0);
        expect(signal.priceChange1h, 5.2);
        expect(signal.priceChange24h, 12.5);
      });

      test('handles missing optional fields with defaults', () {
        final signal = DexscreenerSignal.fromJson({});
        expect(signal.pairAddress, '');
        expect(signal.baseTokenSymbol, '');
        expect(signal.priceUsd, 0);
        expect(signal.volumeUsd24h, 0);
        expect(signal.liquidityUsd, 0);
      });
    });

    group('ageHours', () {
      test('calculates hours since pair creation', () {
        final sixHoursAgo =
            DateTime.now().subtract(const Duration(hours: 6));
        final signal = DexscreenerSignal.fromJson({
          ...validJson(),
          'pairCreatedAt': sixHoursAgo.millisecondsSinceEpoch ~/ 1000,
        });
        // Allow 1 hour tolerance for test execution time
        expect(signal.ageHours, closeTo(6, 1));
      });
    });

    group('volumeLiquidityRatio', () {
      test('calculates volume / liquidity correctly', () {
        final signal = DexscreenerSignal.fromJson(validJson());
        // 50000 / 25000 = 2.0
        expect(signal.volumeLiquidityRatio, 2.0);
      });

      test('returns 0 when liquidity is 0', () {
        final json = validJson();
        json['liquidity'] = {'usd': 0};
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.volumeLiquidityRatio, 0);
      });
    });

    group('hasMinimumLiquidity', () {
      test('returns true when liquidity >= 10000', () {
        final signal = DexscreenerSignal.fromJson(validJson());
        expect(signal.hasMinimumLiquidity, true);
      });

      test('returns false when liquidity < 10000', () {
        final json = validJson();
        json['liquidity'] = {'usd': 5000.0};
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.hasMinimumLiquidity, false);
      });
    });

    group('isFresh', () {
      test('returns true when age <= 24 hours', () {
        final json = validJson();
        json['pairCreatedAt'] =
            DateTime.now().subtract(const Duration(hours: 6)).millisecondsSinceEpoch ~/
                1000;
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.isFresh, true);
      });

      test('returns false when age > 24 hours', () {
        final json = validJson();
        json['pairCreatedAt'] =
            DateTime.now().subtract(const Duration(hours: 48)).millisecondsSinceEpoch ~/
                1000;
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.isFresh, false);
      });
    });

    group('toClaudeContext', () {
      test('contains required fields in output', () {
        final signal = DexscreenerSignal.fromJson(validJson());
        final context = signal.toClaudeContext();
        expect(context, contains('DEX LISTING'));
        expect(context, contains('UNISWAP'));
        expect(context, contains('ethereum'));
        expect(context, contains('New Token'));
        expect(context, contains('NEWTOKEN'));
        expect(context, contains('Vol/Liq ratio'));
        expect(context, contains('Starost para'));
      });

      test('shows SVJEZ for fresh pairs', () {
        final json = validJson();
        json['pairCreatedAt'] =
            DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/
                1000;
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.toClaudeContext(), contains('SVJE'));
      });

      test('shows OK for liquidity above minimum', () {
        final signal = DexscreenerSignal.fromJson(validJson());
        expect(signal.toClaudeContext(), contains('OK'));
      });

      test('shows PREMALA for low liquidity', () {
        final json = validJson();
        json['liquidity'] = {'usd': 1000.0};
        final signal = DexscreenerSignal.fromJson(json);
        expect(signal.toClaudeContext(), contains('PREMALA'));
      });
    });
  });
}
