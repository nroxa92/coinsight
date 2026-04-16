import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:coinsight/services/github_intelligence.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() async {
    registerFallbacks();
    final dir = Directory.systemTemp.createTempSync('github_intel_test');
    Hive.init(dir.path);
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
    if (!Hive.isBoxOpen('watchlist')) await Hive.openBox('watchlist');
    if (!Hive.isBoxOpen('analysis_logs')) await Hive.openBox('analysis_logs');
    if (!Hive.isBoxOpen('positions')) await Hive.openBox('positions');
    if (!Hive.isBoxOpen('monitored_channels_detail')) await Hive.openBox('monitored_channels_detail');
    if (!Hive.isBoxOpen('mid_term_projects')) await Hive.openBox('mid_term_projects');
    if (!Hive.isBoxOpen('long_term_holdings')) await Hive.openBox('long_term_holdings');
    if (!Hive.isBoxOpen('dex_positions')) await Hive.openBox('dex_positions');
  });

  Map<String, dynamic> makeRepoJson({
    String fullName = 'org/crypto-project',
    String description = 'A blockchain DeFi protocol',
    int stars = 500,
    int starsToday = 25,
    List<String> topics = const ['blockchain', 'defi'],
    int daysAgo = 1,
    int createdDaysAgo = 90,
  }) {
    return {
      'full_name': fullName,
      'description': description,
      'language': 'Solidity',
      'stargazers_count': stars,
      'stars_today': starsToday,
      'forks_count': 100,
      'open_issues_count': 10,
      'pushed_at': DateTime.now()
          .subtract(Duration(days: daysAgo))
          .toIso8601String(),
      'created_at': DateTime.now()
          .subtract(Duration(days: createdDaysAgo))
          .toIso8601String(),
      'topics': topics,
    };
  }

  group('GitHubIntelligence', () {
    group('searchByCoinName', () {
      test('returns signal on success', () async {
        final client = HttpClientFactory.returning(
          json.encode({
            'items': [makeRepoJson()],
          }),
        );
        final service = GitHubIntelligence(client: client);
        final result = await service.searchByCoinName('TestCoin');
        expect(result, isNotNull);
        expect(result!.repoName, 'org/crypto-project');
        expect(result.stars, 500);
      });

      test('returns null on 403 rate limit', () async {
        final client = HttpClientFactory.returning('', statusCode: 403);
        final service = GitHubIntelligence(client: client);
        final result = await service.searchByCoinName('TestCoin');
        expect(result, isNull);
      });

      test('returns null on timeout', () async {
        final client = HttpClientFactory.throwingTimeout();
        final service = GitHubIntelligence(client: client);
        final result = await service.searchByCoinName('TestCoin');
        expect(result, isNull);
      });

      test('returns null when no items', () async {
        final client = HttpClientFactory.returning(
          json.encode({'items': []}),
        );
        final service = GitHubIntelligence(client: client);
        final result = await service.searchByCoinName('NonexistentCoin');
        expect(result, isNull);
      });
    });

    group('getTrendingCryptoToday', () {
      test('returns filtered list of active crypto repos', () async {
        final client = HttpClientFactory.returning(
          json.encode({
            'items': [
              makeRepoJson(
                fullName: 'active/crypto',
                topics: ['blockchain', 'crypto'],
                daysAgo: 1,
              ),
              makeRepoJson(
                fullName: 'inactive/project',
                topics: ['web', 'frontend'],
                description: 'A todo app',
                daysAgo: 30, // not recently active
              ),
            ],
          }),
        );
        final service = GitHubIntelligence(client: client);
        final results = await service.getTrendingCryptoToday();
        // Only the active crypto repo should pass filters
        expect(results.any((s) => s.repoName == 'active/crypto'), true);
        expect(results.any((s) => s.repoName == 'inactive/project'), false);
      });

      test('returns empty list on 403', () async {
        final client = HttpClientFactory.returning('', statusCode: 403);
        final service = GitHubIntelligence(client: client);
        final results = await service.getTrendingCryptoToday();
        expect(results, isEmpty);
      });

      test('returns empty list on timeout', () async {
        final client = HttpClientFactory.throwingTimeout();
        final service = GitHubIntelligence(client: client);
        final results = await service.getTrendingCryptoToday();
        expect(results, isEmpty);
      });
    });

    group('getRateLimitStatus', () {
      test('returns remaining and limit', () async {
        final client = HttpClientFactory.returning(
          json.encode({
            'resources': {
              'core': {'remaining': 42, 'limit': 60},
            },
          }),
        );
        final service = GitHubIntelligence(client: client);
        final status = await service.getRateLimitStatus();
        expect(status['remaining'], 42);
        expect(status['limit'], 60);
      });

      test('returns 0 remaining on error', () async {
        final client = HttpClientFactory.returning('', statusCode: 500);
        final service = GitHubIntelligence(client: client);
        final status = await service.getRateLimitStatus();
        expect(status['remaining'], 0);
        expect(status['limit'], 60);
      });

      test('returns 0 remaining on timeout', () async {
        final client = HttpClientFactory.throwingTimeout();
        final service = GitHubIntelligence(client: client);
        final status = await service.getRateLimitStatus();
        expect(status['remaining'], 0);
        expect(status['limit'], 60);
      });
    });
  });
}
