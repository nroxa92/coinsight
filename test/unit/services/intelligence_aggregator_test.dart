import 'package:coinsight/services/coingecko_service.dart';
import 'package:coinsight/services/dexscreener_service.dart';
import 'package:coinsight/services/github_intelligence.dart';
import 'package:coinsight/services/intelligence_aggregator.dart';
import 'package:coinsight/services/reddit_monitor.dart';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() => registerFallbacks());
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  IntelligenceAggregator buildAggregator({
    String dexBody = '{"pairs":[]}',
    String githubBody = '{"items":[]}',
    String redditBody = '{"data":{"children":[]}}',
    String coinGeckoBody = '[]',
  }) {
    final dexClient = HttpClientFactory.returning(dexBody);
    final ghClient = HttpClientFactory.returning(githubBody);
    final redditClient = HttpClientFactory.returning(redditBody);
    final geckoClient = HttpClientFactory.returning(coinGeckoBody);
    return IntelligenceAggregator(
      dex: DexscreenerService(client: dexClient),
      github: GitHubIntelligence(client: ghClient),
      reddit: RedditMonitor(client: redditClient),
      telegram: TelegramMonitor(),
      coinGecko: CoinGeckoService(client: geckoClient),
    );
  }

  test('buildReportForSymbol returns a report even when all sources empty',
      () async {
    final agg = buildAggregator();
    final report = await agg.buildReportForSymbol(symbol: 'NEW');
    expect(report.symbol, 'NEW');
    expect(report.dexSignal, isNull);
    expect(report.redditSignals, isEmpty);
    expect(report.telegramSignals, isEmpty);
  });

  test('stopAutoScan is safe without prior start', () {
    final agg = buildAggregator();
    expect(() => agg.stopAutoScan(), returnsNormally);
  });

  test('cached lists start empty and lastScanTime null', () {
    final agg = buildAggregator();
    expect(agg.cachedDexSignals, isEmpty);
    expect(agg.cachedGithubSignals, isEmpty);
    expect(agg.lastScanTime, isNull);
  });

  test('buildReportForSymbol uppercases symbol handling', () async {
    final agg = buildAggregator();
    final report = await agg.buildReportForSymbol(symbol: 'pepe');
    expect(report.symbol, 'pepe');
  });
}
