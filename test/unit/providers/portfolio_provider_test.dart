import 'dart:convert';

import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/portfolio_provider.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/trade_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';
import '../../helpers/mock_http_client.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() => registerFallbacks());
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  PortfolioProvider buildProvider({double price = 0.0028}) {
    final priceBody =
        json.encode(TestFixtures.binancePriceResponse('XYZUSDT', price));
    final client = HttpClientFactory.returning(priceBody);
    final binance = BinanceService(client: client);
    final trade = TradeService(binance: binance);
    return PortfolioProvider(binance: binance, trade: trade);
  }

  test('loads positions from storage on construction', () async {
    await StorageService.savePosition(TestFixtures.openPosition());
    final p = buildProvider();
    expect(p.positions, hasLength(1));
    expect(p.positions.first.coinId, 'newcoin-xyz');
  });

  test('totalInvested / totalValue / totalPnl aggregate positions', () async {
    await StorageService.savePosition(CoinPosition(
      coinId: 'coin-a',
      symbol: 'A',
      binanceSymbol: 'AUSDT',
      quantity: 10,
      entryPrice: 1.0,
      entryTotal: 10.0,
      entryTime: DateTime(2026, 4, 10),
      currentPrice: 1.5,
    ));
    await StorageService.savePosition(CoinPosition(
      coinId: 'coin-b',
      symbol: 'B',
      binanceSymbol: 'BUSDT',
      quantity: 100,
      entryPrice: 0.5,
      entryTotal: 50.0,
      entryTime: DateTime(2026, 4, 11),
      currentPrice: 0.6,
    ));
    final p = buildProvider();
    expect(p.totalInvested, closeTo(60.0, 0.01));
    expect(p.totalValue, closeTo(10 * 1.5 + 100 * 0.6, 0.01));
    expect(p.totalPnl, closeTo(15.0, 0.01));
    expect(p.totalPnlPercent, closeTo(25.0, 0.5));
  });

  test('totalPnlPercent is 0 when nothing invested', () {
    final p = buildProvider();
    expect(p.totalInvested, 0);
    expect(p.totalPnlPercent, 0);
  });

  test('hasCredentials reflects BinanceService state', () async {
    final p = buildProvider();
    expect(p.hasCredentials, false);
    await StorageService.saveBinanceCredentials('k', 's');
    p.reloadCredentials();
    expect(p.hasCredentials, true);
  });

  test('clearError resets error and notifies', () {
    final p = buildProvider();
    var notified = 0;
    p.addListener(() => notified++);
    p.clearError();
    expect(p.error, isNull);
    expect(notified, 1);
  });

  test('stopAutoRefresh is safe without prior start', () {
    final p = buildProvider();
    expect(() => p.stopAutoRefresh(), returnsNormally);
  });
}
