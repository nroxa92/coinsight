import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/services/reddit_monitor.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() => registerFallbacks());

  Map<String, dynamic> makePostJson({
    String id = 'post1',
    String title = 'Check out NEWCOIN - amazing project!',
    int upvotes = 50,
    double upvoteRatio = 0.85,
    int hoursAgo = 2,
    int comments = 15,
  }) {
    return {
      'kind': 't3',
      'data': {
        'id': id,
        'title': title,
        'ups': upvotes,
        'upvote_ratio': upvoteRatio,
        'num_comments': comments,
        'created_utc': DateTime.now()
                .subtract(Duration(hours: hoursAgo))
                .millisecondsSinceEpoch ~/
            1000,
      },
    };
  }

  String makeRedditResponse(List<Map<String, dynamic>> posts) {
    return json.encode({
      'data': {
        'children': posts,
      },
    });
  }

  group('RedditMonitor', () {
    group('getNewPosts', () {
      test('filters by minimum upvotes', () async {
        final response = makeRedditResponse([
          makePostJson(id: 'high', upvotes: 50, title: 'GOOD token rising'),
          makePostJson(id: 'low', upvotes: 3, title: 'LOW token sucks'),
        ]);
        final client = HttpClientFactory.returning(response);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.getNewPosts();
        // Only posts with >= 10 upvotes should pass
        expect(results.any((s) => s.postId == 'high'), true);
        expect(results.any((s) => s.postId == 'low'), false);
      });

      test('filters by max age', () async {
        final response = makeRedditResponse([
          makePostJson(id: 'fresh', hoursAgo: 2, upvotes: 50),
          makePostJson(id: 'old', hoursAgo: 24, upvotes: 50),
        ]);
        final client = HttpClientFactory.returning(response);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.getNewPosts();
        // Only posts within _maxAgeHours (6) should pass
        expect(results.any((s) => s.postId == 'fresh'), true);
        expect(results.any((s) => s.postId == 'old'), false);
      });
    });

    group('_extractSymbols (via mentionedSymbols)', () {
      test('extracts uppercase symbols from title', () async {
        final response = makeRedditResponse([
          makePostJson(
            title: 'Just found PEPE and DOGE on DEX',
            upvotes: 50,
            hoursAgo: 1,
          ),
        ]);
        final client = HttpClientFactory.returning(response);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.getNewPosts();
        expect(results.isNotEmpty, true);
        // PEPE and DOGE should be extracted, DEX should be ignored
        expect(results.first.mentionedSymbols, contains('PEPE'));
        expect(results.first.mentionedSymbols, contains('DOGE'));
      });

      test('ignores common abbreviations', () async {
        final response = makeRedditResponse([
          makePostJson(
            title: 'THE NEW COIN FOR ALL NFT AND DAO investors',
            upvotes: 50,
            hoursAgo: 1,
          ),
        ]);
        final client = HttpClientFactory.returning(response);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.getNewPosts();
        expect(results.isNotEmpty, true);
        final symbols = results.first.mentionedSymbols;
        // THE, NEW, FOR, ALL, NFT, DAO, AND should all be ignored
        expect(symbols.contains('THE'), false);
        expect(symbols.contains('FOR'), false);
        expect(symbols.contains('ALL'), false);
        expect(symbols.contains('NEW'), false);
        expect(symbols.contains('NFT'), false);
        expect(symbols.contains('DAO'), false);
        expect(symbols.contains('AND'), false);
        // COIN should be extracted (not in ignore list)
        expect(symbols, contains('COIN'));
      });
    });

    group('searchBySymbol', () {
      test('returns matching posts', () async {
        final response = makeRedditResponse([
          makePostJson(
            id: 'match',
            title: 'XYZ is pumping hard',
            upvotes: 100,
            hoursAgo: 1,
          ),
        ]);
        final client = HttpClientFactory.returning(response);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.searchBySymbol('XYZ');
        expect(results.isNotEmpty, true);
      });

      test('returns empty on timeout', () async {
        final client = HttpClientFactory.throwingTimeout();
        final monitor = RedditMonitor(client: client);
        final results = await monitor.searchBySymbol('XYZ');
        expect(results, isEmpty);
      });

      test('returns empty on error status', () async {
        final client = HttpClientFactory.returning('', statusCode: 429);
        final monitor = RedditMonitor(client: client);
        final results = await monitor.searchBySymbol('XYZ');
        expect(results, isEmpty);
      });
    });
  });
}
