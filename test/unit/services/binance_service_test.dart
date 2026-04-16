import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import '../../helpers/mock_http_client.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() async {
    registerFallbacks();
    final dir = Directory.systemTemp.createTempSync('binance_service_test');
    Hive.init(dir.path);
    await Hive.openBox('settings');
    await Hive.openBox('watchlist');
    await Hive.openBox('analysis_logs');
    await Hive.openBox('positions');
    await Hive.openBox('monitored_channels_detail');
  });

  setUp(() async {
    await StorageService.saveBinanceCredentials('test-key', 'test-secret');
    await StorageService.setBinanceTestnet(true);
  });

  group('BinanceService', () {
    test('ping returns true on success', () async {
      final client = HttpClientFactory.returning('{}');
      final service = BinanceService(client: client);
      expect(await service.ping(), true);
    });

    test('ping returns false on network error', () async {
      final client = HttpClientFactory.throwingTimeout();
      final service = BinanceService(client: client);
      expect(await service.ping(), false);
    });

    test('hasCredentials returns true when key and secret set', () {
      final service = BinanceService();
      expect(service.hasCredentials, true);
    });

    test('hasCredentials returns false when credentials empty', () async {
      await StorageService.deleteBinanceCredentials();
      final service = BinanceService();
      expect(service.hasCredentials, false);
      // Restore for other tests
      await StorageService.saveBinanceCredentials('test-key', 'test-secret');
    });

    test('isTestnet returns true when testnet enabled', () {
      final service = BinanceService();
      expect(service.isTestnet, true);
    });

    test('getUsdtBalance returns correct USDT amount', () async {
      final response =
          json.encode(TestFixtures.binanceAccountResponse(1500.50));
      final client = HttpClientFactory.returning(response);
      final service = BinanceService(client: client);
      final balance = await service.getUsdtBalance();
      expect(balance, closeTo(1500.50, 0.01));
    });

    test('getUsdtBalance throws BinanceException when no credentials',
        () async {
      await StorageService.deleteBinanceCredentials();
      final service = BinanceService();
      expect(
        () => service.getUsdtBalance(),
        throwsA(isA<BinanceException>()),
      );
      await StorageService.saveBinanceCredentials('test-key', 'test-secret');
    });

    test('getCurrentPrice returns correct price', () async {
      final response = json
          .encode(TestFixtures.binancePriceResponse('BTCUSDT', 71867.10));
      final client = HttpClientFactory.returning(response);
      final service = BinanceService(client: client);
      final price = await service.getCurrentPrice('BTCUSDT');
      expect(price, closeTo(71867.10, 0.01));
    });

    test('placeBuyOrder returns BinanceOrder on success', () async {
      final response = json.encode(TestFixtures.binanceOrderResponse(
        symbol: 'XYZUSDT',
        side: 'BUY',
        executedQty: 4273.504,
        price: 0.00234,
      ));
      final client = HttpClientFactory.returning(response);
      final service = BinanceService(client: client);
      final order = await service.placeBuyOrder('XYZUSDT', 10.0);

      expect(order.symbol, 'XYZUSDT');
      expect(order.side, 'BUY');
      expect(order.status, 'FILLED');
      expect(order.executedQty, closeTo(4273.504, 0.001));
    });

    test('placeBuyOrder throws BinanceException on insufficient balance',
        () async {
      final client =
          HttpClientFactory.returningBinanceError(-2010, 'Insufficient balance');
      final service = BinanceService(client: client);
      expect(
        () => service.placeBuyOrder('XYZUSDT', 10.0),
        throwsA(
          isA<BinanceException>().having(
            (e) => e.code,
            'code',
            -2010,
          ),
        ),
      );
    });

    test('placeBuyOrder throws BinanceException on bad symbol', () async {
      final client =
          HttpClientFactory.returningBinanceError(-1121, 'Invalid symbol');
      final service = BinanceService(client: client);
      expect(
        () => service.placeBuyOrder('INVALIDUSDT', 10.0),
        throwsA(
          isA<BinanceException>().having(
            (e) => e.code,
            'code',
            -1121,
          ),
        ),
      );
    });

    test('placeSellOrder returns BinanceOrder on success', () async {
      final response = json.encode(TestFixtures.binanceOrderResponse(
        symbol: 'XYZUSDT',
        side: 'SELL',
        executedQty: 4273.504,
        price: 0.0028,
      ));
      final client = HttpClientFactory.returning(response);
      final service = BinanceService(client: client);
      final order = await service.placeSellOrder('XYZUSDT', 4273.504);

      expect(order.side, 'SELL');
      expect(order.status, 'FILLED');
    });

    test('BinanceOrder avgPrice calculates correctly', () {
      final order = BinanceOrder(
        orderId: '123',
        symbol: 'BTCUSDT',
        side: 'BUY',
        status: 'FILLED',
        executedQty: 0.001,
        cummulativeQuoteQty: 71.867,
        transactTime: DateTime.now(),
      );
      expect(order.avgPrice, closeTo(71867.0, 0.1));
    });

    test('BinanceOrder avgPrice returns 0 when executedQty is 0', () {
      final order = BinanceOrder(
        orderId: '123',
        symbol: 'BTCUSDT',
        side: 'BUY',
        status: 'EXPIRED',
        executedQty: 0,
        cummulativeQuoteQty: 0,
        transactTime: DateTime.now(),
      );
      expect(order.avgPrice, 0);
    });

    test('serverTimeOffsetMs getter returns current offset', () {
      final service = BinanceService();
      expect(service.serverTimeOffsetMs, isA<int>());
    });

    test('syncServerTime calculates correct offset', () async {
      final serverTime = DateTime.now().millisecondsSinceEpoch + 500;
      final response = json.encode({'serverTime': serverTime});
      final client = HttpClientFactory.returning(response);
      final service = BinanceService(client: client);
      await service.syncServerTime();
      // Offset should be approximately 500ms (with some tolerance for execution time)
      expect(service.serverTimeOffsetMs, greaterThan(400));
      expect(service.serverTimeOffsetMs, lessThan(600));
    });

    test('ping calls syncServerTime on success', () async {
      final serverTime = DateTime.now().millisecondsSinceEpoch + 100;
      // First call returns ping OK, second returns server time
      final client = HttpClientFactory.returningSequence([
        http.Response('{}', 200),
        http.Response(json.encode({'serverTime': serverTime}), 200),
      ]);
      final service = BinanceService(client: client);
      final result = await service.ping();
      expect(result, true);
      // Offset should have been set
      expect(service.serverTimeOffsetMs, isNot(0));
    });
  });
}
