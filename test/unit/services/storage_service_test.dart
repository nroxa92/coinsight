import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/closed_trade.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/monitored_channel.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  group('StorageService', () {
    group('api key', () {
      test('getApiKey returns null initially', () {
        expect(StorageService.getApiKey(), isNull);
      });

      test('saveApiKey persists, deleteApiKey clears', () async {
        await StorageService.saveApiKey('sk-ant-xyz');
        expect(StorageService.getApiKey(), 'sk-ant-xyz');
        await StorageService.deleteApiKey();
        expect(StorageService.getApiKey(), isNull);
      });
    });

    group('watchlist', () {
      test('default watchlist contains btc/eth/sol', () {
        final ids = StorageService.getWatchlistIds();
        expect(ids, containsAll(['bitcoin', 'ethereum', 'solana']));
      });

      test('saveWatchlistIds overrides default', () async {
        await StorageService.saveWatchlistIds(['dogecoin']);
        expect(StorageService.getWatchlistIds(), ['dogecoin']);
      });
    });

    group('analysis logs', () {
      test('empty initially', () {
        expect(StorageService.getAnalysisLogs(), isEmpty);
      });

      test('saveAnalysisLog / getAnalysisLogs sorted desc', () async {
        await StorageService.saveAnalysisLog(AnalysisLog(
          timestamp: DateTime(2026, 4, 10),
          coinId: 'bitcoin',
          coinSymbol: 'BTC',
          priceAtAnalysis: 70000,
          claudeRecommendation: 'old',
          recommendationType: 'WATCH',
        ));
        await StorageService.saveAnalysisLog(AnalysisLog(
          timestamp: DateTime(2026, 4, 15),
          coinId: 'bitcoin',
          coinSymbol: 'BTC',
          priceAtAnalysis: 71000,
          claudeRecommendation: 'new',
          recommendationType: 'INTERESTING',
        ));
        final logs = StorageService.getAnalysisLogs();
        expect(logs, hasLength(2));
        expect(logs.first.claudeRecommendation, 'new');
      });

      test('clearAnalysisLogs wipes', () async {
        await StorageService.saveAnalysisLog(AnalysisLog(
          timestamp: DateTime.now(),
          coinId: 'x',
          coinSymbol: 'X',
          priceAtAnalysis: 1,
          claudeRecommendation: '',
          recommendationType: 'WATCH',
        ));
        await StorageService.clearAnalysisLogs();
        expect(StorageService.getAnalysisLogs(), isEmpty);
      });
    });

    group('binance credentials', () {
      test('getBinanceTestnet defaults true', () {
        expect(StorageService.getBinanceTestnet(), true);
      });

      test('saveBinanceCredentials persists', () async {
        await StorageService.saveBinanceCredentials('k', 's');
        expect(StorageService.getBinanceApiKey(), 'k');
        expect(StorageService.getBinanceSecret(), 's');
      });

      test('deleteBinanceCredentials clears both', () async {
        await StorageService.saveBinanceCredentials('k', 's');
        await StorageService.deleteBinanceCredentials();
        expect(StorageService.getBinanceApiKey(), isNull);
        expect(StorageService.getBinanceSecret(), isNull);
      });

      test('setBinanceTestnet toggles', () async {
        await StorageService.setBinanceTestnet(false);
        expect(StorageService.getBinanceTestnet(), false);
      });
    });

    group('risk parameters', () {
      test('getRiskParameters returns defaults initially', () {
        final r = StorageService.getRiskParameters();
        expect(r.maxTradeAmountUsdt, 10.0);
        expect(r.stopLossPercent, 15.0);
      });

      test('saveRiskParameters roundtrips', () async {
        final r = TestFixtures.aggressiveRisk();
        await StorageService.saveRiskParameters(r);
        final loaded = StorageService.getRiskParameters();
        expect(loaded.maxTradeAmountUsdt, 50.0);
        expect(loaded.stopLossPercent, 10.0);
        expect(loaded.autoTradeEnabled, true);
      });
    });

    group('positions', () {
      test('savePosition keyed by coinId, removePosition deletes', () async {
        await StorageService.savePosition(TestFixtures.openPosition());
        expect(StorageService.getPositions(), hasLength(1));
        await StorageService.removePosition('newcoin-xyz');
        expect(StorageService.getPositions(), isEmpty);
      });

      test('getPositions sorted by entryTime desc', () async {
        await StorageService.savePosition(CoinPosition(
          coinId: 'a',
          symbol: 'A',
          binanceSymbol: 'AUSDT',
          quantity: 1,
          entryPrice: 1,
          entryTotal: 1,
          entryTime: DateTime(2026, 4, 10),
        ));
        await StorageService.savePosition(CoinPosition(
          coinId: 'b',
          symbol: 'B',
          binanceSymbol: 'BUSDT',
          quantity: 1,
          entryPrice: 1,
          entryTotal: 1,
          entryTime: DateTime(2026, 4, 15),
        ));
        final positions = StorageService.getPositions();
        expect(positions.first.coinId, 'b');
      });
    });

    group('monitored channels', () {
      test('updateChannelStats creates entry on first call', () async {
        await StorageService.updateChannelStats(
            username: '@whales', wasRelevant: true);
        final channels = StorageService.getMonitoredChannelsDetail();
        expect(channels, hasLength(1));
        expect(channels.first.signalsReceived, 1);
        expect(channels.first.signalsRelevant, 1);
      });

      test('updateChannelStats increments on subsequent calls', () async {
        await StorageService.updateChannelStats(
            username: '@whales', wasRelevant: true);
        await StorageService.updateChannelStats(
            username: '@whales', wasRelevant: false);
        final c = StorageService.getMonitoredChannelsDetail().first;
        expect(c.signalsReceived, 2);
        expect(c.signalsRelevant, 1);
      });

      test('saveMonitoredChannel + toggleChannelActive', () async {
        final ch = MonitoredChannel(
          username: '@test',
          displayName: 'Test',
          signalsReceived: 5,
          signalsRelevant: 2,
        );
        await StorageService.saveMonitoredChannel(ch);
        await StorageService.toggleChannelActive('@test', false);
        final loaded =
            StorageService.getMonitoredChannelsDetail().first;
        expect(loaded.isActive, false);
      });

      test('removeMonitoredChannel removes from both lists', () async {
        await StorageService.saveMonitoredChannels(['@a', '@b']);
        await StorageService.saveMonitoredChannel(MonitoredChannel(
          username: '@a',
          displayName: 'A',
          signalsReceived: 0,
          signalsRelevant: 0,
        ));
        await StorageService.removeMonitoredChannel('@a');
        expect(StorageService.getMonitoredChannels(), ['@b']);
        expect(StorageService.getMonitoredChannelsDetail(), isEmpty);
      });
    });

    group('active tier', () {
      test('defaults to short', () {
        expect(StorageService.getActiveTier(), InvestmentTier.short);
      });

      test('roundtrips for every tier', () async {
        for (final t in InvestmentTier.values) {
          await StorageService.saveActiveTier(t);
          expect(StorageService.getActiveTier(), t);
        }
      });
    });

    group('github / wallet tokens', () {
      test('getGitHubToken / saveGitHubToken / delete', () async {
        expect(StorageService.getGitHubToken(), isNull);
        await StorageService.saveGitHubToken('ghp_xxx');
        expect(StorageService.getGitHubToken(), 'ghp_xxx');
        await StorageService.deleteGitHubToken();
        expect(StorageService.getGitHubToken(), isNull);
      });

      test('wallet address + project id roundtrip', () async {
        await StorageService.saveWalletAddress('0xABC');
        expect(StorageService.getWalletAddress(), '0xABC');
        await StorageService.saveWalletConnectProjectId('proj-123');
        expect(StorageService.getWalletConnectProjectId(), 'proj-123');
        await StorageService.deleteWalletAddress();
        expect(StorageService.getWalletAddress(), isNull);
      });
    });

    group('closed trades', () {
      test('roundtrip and tier filtering', () async {
        final t1 = ClosedTrade(
          id: '1',
          tier: InvestmentTier.short,
          symbol: 'BTC',
          name: 'Bitcoin',
          tradeType: ClosedTradeType.binance,
          openedAt: DateTime(2026, 4, 1),
          closedAt: DateTime(2026, 4, 10),
          entryPrice: 70000,
          exitPrice: 71000,
          quantity: 0.1,
          investedUsdt: 7000,
          returnedUsdt: 7100,
          result: ClosedTradeResult.profit,
        );
        final t2 = ClosedTrade(
          id: '2',
          tier: InvestmentTier.mid,
          symbol: 'ETH',
          name: 'Ethereum',
          tradeType: ClosedTradeType.mid,
          openedAt: DateTime(2026, 3, 1),
          closedAt: DateTime(2026, 4, 15),
          entryPrice: 2000,
          exitPrice: 2500,
          quantity: 1,
          investedUsdt: 2000,
          returnedUsdt: 2500,
          result: ClosedTradeResult.profit,
        );
        await StorageService.saveClosedTrade(t1);
        await StorageService.saveClosedTrade(t2);
        expect(StorageService.getClosedTrades(), hasLength(2));
        expect(
          StorageService.getClosedTradesByTier(InvestmentTier.short),
          hasLength(1),
        );
        await StorageService.clearClosedTrades();
        expect(StorageService.getClosedTrades(), isEmpty);
      });
    });

    group('resetAll', () {
      test('clears every tracked box', () async {
        await StorageService.saveApiKey('x');
        await StorageService.saveRiskParameters(const RiskParameters());
        await StorageService.savePosition(TestFixtures.openPosition());
        await StorageService.resetAll();
        expect(StorageService.getApiKey(), isNull);
        expect(StorageService.getPositions(), isEmpty);
      });
    });
  });
}
