import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/risk_parameters.dart';

class TestFixtures {
  static Coin btcCoin() => Coin(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        image: 'https://example.com/btc.png',
        currentPrice: 71867.10,
        marketCap: 1400000000000,
        marketCapRank: 1,
        priceChangePercentage24h: 2.3,
        priceChangePercentage1h: 0.5,
        high24h: 72000,
        low24h: 70000,
        totalVolume: 28000000000,
        sparklineIn7d: List.generate(168, (i) => 70000 + i * 10.0),
      );

  static Coin newListingCoin() => Coin(
        id: 'newcoin-xyz',
        symbol: 'xyz',
        name: 'NewCoin XYZ',
        image: 'https://example.com/xyz.png',
        currentPrice: 0.00234,
        marketCap: 500000,
        marketCapRank: 0,
        priceChangePercentage24h: 34.2,
        priceChangePercentage1h: 18.4,
        high24h: 0.0028,
        low24h: 0.0015,
        totalVolume: 2340000,
        sparklineIn7d: null,
      );

  static CoinPosition openPosition() => CoinPosition(
        coinId: 'newcoin-xyz',
        symbol: 'XYZ',
        binanceSymbol: 'XYZUSDT',
        quantity: 4273.504,
        entryPrice: 0.00234,
        entryTotal: 10.0,
        entryTime: DateTime(2026, 4, 15, 10, 0),
        currentPrice: 0.0028,
      );

  static RiskParameters defaultRisk() => const RiskParameters();

  static RiskParameters aggressiveRisk() => const RiskParameters(
        maxTradeAmountUsdt: 50.0,
        maxOpenPositions: 5,
        stopLossPercent: 10.0,
        takeProfitPercent: 50.0,
        autoTradeEnabled: true,
      );

  static Map<String, dynamic> coinJson({
    String id = 'bitcoin',
    String symbol = 'btc',
    String name = 'Bitcoin',
    double? currentPrice = 71867.10,
    double? marketCap = 1400000000000,
    int? marketCapRank = 1,
    double? priceChange24h = 2.3,
    double? priceChange1h,
    double? high24h = 72000,
    double? low24h = 70000,
    double? totalVolume = 28000000000,
  }) =>
      {
        'id': id,
        'symbol': symbol,
        'name': name,
        'image': 'https://example.com/$id.png',
        'current_price': currentPrice,
        'market_cap': marketCap,
        'market_cap_rank': marketCapRank,
        'price_change_percentage_24h': priceChange24h,
        'price_change_percentage_1h_in_currency': priceChange1h,
        'high_24h': high24h,
        'low_24h': low24h,
        'total_volume': totalVolume,
        'sparkline_in_7d': null,
      };

  static Map<String, dynamic> binancePriceResponse(
          String symbol, double price) =>
      {
        'symbol': symbol,
        'price': price.toStringAsFixed(8),
      };

  static Map<String, dynamic> binanceOrderResponse({
    required String symbol,
    required String side,
    required double executedQty,
    required double price,
  }) =>
      {
        'orderId': 12345678,
        'symbol': symbol,
        'side': side,
        'status': 'FILLED',
        'executedQty': executedQty.toStringAsFixed(8),
        'cummulativeQuoteQty': (executedQty * price).toStringAsFixed(8),
        'transactTime': DateTime.now().millisecondsSinceEpoch,
      };

  static Map<String, dynamic> binanceAccountResponse(
          double usdtBalance) =>
      {
        'balances': [
          {
            'asset': 'USDT',
            'free': usdtBalance.toStringAsFixed(8),
            'locked': '0.00000000'
          },
          {
            'asset': 'BTC',
            'free': '0.00100000',
            'locked': '0.00000000'
          },
        ],
      };

  static Map<String, dynamic> binanceErrorResponse(int code, String msg) =>
      {
        'code': code,
        'msg': msg,
      };

  static Map<String, dynamic> telegramUpdatesResponse(
          List<Map<String, dynamic>> updates) =>
      {
        'ok': true,
        'result': updates,
      };

  static Map<String, dynamic> telegramChannelPost({
    required int updateId,
    required String text,
    required String channelUsername,
    required String channelTitle,
  }) =>
      {
        'update_id': updateId,
        'channel_post': {
          'message_id': updateId,
          'chat': {
            'id': -1001234567890,
            'username': channelUsername.replaceAll('@', ''),
            'title': channelTitle,
            'type': 'channel',
          },
          'text': text,
          'date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      };
}
