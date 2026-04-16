import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:coinsight/services/trade_service.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/models/trade_proposal.dart';
import '../../helpers/mock_http_client.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() async {
    registerFallbacks();
    final dir = Directory.systemTemp.createTempSync('trade_service_test');
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
    await StorageService.saveRiskParameters(const RiskParameters());
    // Clear positions
    final positions = StorageService.getPositions();
    for (final p in positions) {
      await StorageService.removePosition(p.coinId);
    }
  });

  group('TradeService', () {
    group('prepareTradeProposal', () {
      test('returns proposal with correct price and calculations', () async {
        final priceResponse = json.encode(
            TestFixtures.binancePriceResponse('XYZUSDT', 0.00234));
        final client = HttpClientFactory.returning(priceResponse);
        final binance = BinanceService(client: client);
        final service = TradeService(binance: binance);

        final proposal = await service.prepareTradeProposal(
          coin: TestFixtures.newListingCoin(),
          claudeRecommendation: 'test recommendation',
          riskParams: TestFixtures.defaultRisk(),
        );

        expect(proposal.currentPrice, closeTo(0.00234, 0.0001));
        expect(proposal.amountUsdt, 10.0);
        expect(proposal.estimatedQty, closeTo(4273.504, 1));
      });

      test('stopLossPrice is correct', () async {
        final priceResponse = json
            .encode(TestFixtures.binancePriceResponse('BTCUSDT', 100.0));
        final client = HttpClientFactory.returning(priceResponse);
        final binance = BinanceService(client: client);
        final service = TradeService(binance: binance);

        final proposal = await service.prepareTradeProposal(
          coin: TestFixtures.btcCoin(),
          claudeRecommendation: 'test',
          riskParams: const RiskParameters(stopLossPercent: 15.0),
        );

        // SL = 100 * (1 - 15/100) = 85
        expect(proposal.stopLossPrice, closeTo(85.0, 0.01));
      });

      test('takeProfitPrice is correct', () async {
        final priceResponse = json
            .encode(TestFixtures.binancePriceResponse('BTCUSDT', 100.0));
        final client = HttpClientFactory.returning(priceResponse);
        final binance = BinanceService(client: client);
        final service = TradeService(binance: binance);

        final proposal = await service.prepareTradeProposal(
          coin: TestFixtures.btcCoin(),
          claudeRecommendation: 'test',
          riskParams: const RiskParameters(takeProfitPercent: 30.0),
        );

        // TP = 100 * (1 + 30/100) = 130
        expect(proposal.takeProfitPrice, closeTo(130.0, 0.01));
      });
    });

    group('executeTrade', () {
      test('returns failure if proposal is expired', () async {
        final binance = BinanceService(
            client: HttpClientFactory.returning('{}'));
        final service = TradeService(binance: binance);

        final proposal = TradeProposal(
          coin: TestFixtures.newListingCoin(),
          amountUsdt: 10.0,
          estimatedQty: 4273,
          currentPrice: 0.00234,
          stopLossPrice: 0.002,
          takeProfitPrice: 0.003,
          claudeRecommendation: 'test',
          createdAt:
              DateTime.now().subtract(const Duration(seconds: 61)),
        );

        final result = await service.executeTrade(proposal);
        expect(result.success, false);
        expect(result.errorMessage, contains('expired'));
      });

      test('returns failure if max positions reached', () async {
        // Add max positions
        await StorageService.saveRiskParameters(
            const RiskParameters(maxOpenPositions: 1));
        await StorageService.savePosition(TestFixtures.openPosition());

        final binance = BinanceService(
            client: HttpClientFactory.returning('{}'));
        final service = TradeService(binance: binance);

        final proposal = TradeProposal(
          coin: TestFixtures.btcCoin(),
          amountUsdt: 10.0,
          estimatedQty: 0.000139,
          currentPrice: 71867.10,
          stopLossPrice: 61000,
          takeProfitPrice: 93000,
          claudeRecommendation: 'test',
          createdAt: DateTime.now(),
        );

        final result = await service.executeTrade(proposal);
        expect(result.success, false);
        expect(result.errorMessage, contains('Max open positions'));
      });

      test('returns failure if coin already in positions', () async {
        await StorageService.savePosition(TestFixtures.openPosition());

        final binance = BinanceService(
            client: HttpClientFactory.returning('{}'));
        final service = TradeService(binance: binance);

        final proposal = TradeProposal(
          coin: TestFixtures.newListingCoin(), // same coinId as openPosition
          amountUsdt: 10.0,
          estimatedQty: 4273,
          currentPrice: 0.00234,
          stopLossPrice: 0.002,
          takeProfitPrice: 0.003,
          claudeRecommendation: 'test',
          createdAt: DateTime.now(),
        );

        final result = await service.executeTrade(proposal);
        expect(result.success, false);
        expect(result.errorMessage, contains('already open'));
      });
    });

    group('autoExecuteIfEligible', () {
      test('returns null if autoTradeEnabled is false', () async {
        final binance = BinanceService(
            client: HttpClientFactory.returning('{}'));
        final service = TradeService(binance: binance);

        final result = await service.autoExecuteIfEligible(
          coin: TestFixtures.newListingCoin(),
          claudeRecommendation: 'test',
          riskParams: const RiskParameters(autoTradeEnabled: false),
        );
        expect(result, isNull);
      });

      test('returns null if no Binance credentials', () async {
        await StorageService.deleteBinanceCredentials();
        final binance = BinanceService(
            client: HttpClientFactory.returning('{}'));
        final service = TradeService(binance: binance);

        final result = await service.autoExecuteIfEligible(
          coin: TestFixtures.newListingCoin(),
          claudeRecommendation: 'test',
          riskParams: const RiskParameters(autoTradeEnabled: true),
        );
        expect(result, isNull);

        // Restore
        await StorageService.saveBinanceCredentials(
            'test-key', 'test-secret');
      });
    });
  });
}
