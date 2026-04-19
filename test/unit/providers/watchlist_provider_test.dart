import 'dart:convert';

import 'package:coinsight/models/watchlist_provider.dart';
import 'package:coinsight/services/coingecko_service.dart';
import 'package:coinsight/services/dexscreener_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';
import '../../helpers/mock_http_client.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  setUpAll(() => registerFallbacks());
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  WatchlistProvider buildProvider({
    required String marketBody,
    required String dexBody,
    int marketStatus = 200,
    int dexStatus = 200,
  }) {
    final gecko = CoinGeckoService(
      client: HttpClientFactory.returning(marketBody, statusCode: marketStatus),
    );
    final dex = DexscreenerService(
      client: HttpClientFactory.returning(dexBody, statusCode: dexStatus),
    );
    return WatchlistProvider(service: gecko, dexService: dex);
  }

  test('default watchlist contains btc/eth/sol', () {
    final p = buildProvider(marketBody: '[]', dexBody: '{"pairs":[]}');
    expect(p.watchlistIds.contains('bitcoin'), true);
    expect(p.watchlistIds.contains('ethereum'), true);
    expect(p.watchlistIds.contains('solana'), true);
  });

  test('toggleWatchlist adds and removes ids + persists', () {
    final p = buildProvider(marketBody: '[]', dexBody: '{"pairs":[]}');
    expect(p.isInWatchlist('dogecoin'), false);
    p.toggleWatchlist('dogecoin');
    expect(p.isInWatchlist('dogecoin'), true);
    expect(StorageService.getWatchlistIds().contains('dogecoin'), true);
    p.toggleWatchlist('dogecoin');
    expect(p.isInWatchlist('dogecoin'), false);
  });

  test('fetchTopCoins populates topCoins and clears error', () async {
    final body = json.encode([TestFixtures.coinJson()]);
    final p = buildProvider(marketBody: body, dexBody: '{"pairs":[]}');
    await p.fetchTopCoins();
    expect(p.topCoins, isNotEmpty);
    expect(p.topCoins.first.id, 'bitcoin');
    expect(p.error, isNull);
    expect(p.isLoading, false);
  });

  test('fetchTopCoins surfaces CoinGeckoException message', () async {
    final p = buildProvider(
      marketBody: 'rate limited',
      dexBody: '{"pairs":[]}',
      marketStatus: 429,
    );
    await p.fetchTopCoins();
    expect(p.error, contains('Rate limited'));
    expect(p.isLoading, false);
  });

  test('refreshWatchlist skips API when watchlist empty', () async {
    final p = buildProvider(marketBody: '[]', dexBody: '{"pairs":[]}');
    for (final id in p.watchlistIds.toList()) {
      p.toggleWatchlist(id);
    }
    await p.refreshWatchlist();
    expect(p.watchlistCoins, isEmpty);
    expect(p.error, isNull);
  });

  test('_updateWatchlistCoins filters topCoins by ids', () async {
    final body = json.encode([
      TestFixtures.coinJson(id: 'bitcoin'),
      TestFixtures.coinJson(id: 'ethereum', name: 'Ethereum', symbol: 'eth'),
      TestFixtures.coinJson(id: 'xrp', name: 'Ripple', symbol: 'xrp'),
    ]);
    final p = buildProvider(marketBody: body, dexBody: '{"pairs":[]}');
    // xrp not in default watchlist
    await p.fetchTopCoins();
    final symbols = p.watchlistCoins.map((c) => c.id).toList();
    expect(symbols, containsAll(['bitcoin', 'ethereum']));
    expect(symbols.contains('xrp'), false);
  });

  test('fetchDexListings failure does not set error', () async {
    final p = buildProvider(
      marketBody: '[]',
      dexBody: 'broken',
      dexStatus: 500,
    );
    await p.fetchDexListings();
    expect(p.isDexLoading, false);
    expect(p.error, isNull);
  });
}
