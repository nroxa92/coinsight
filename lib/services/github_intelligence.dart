import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/github_signal.dart';

/// GitHubIntelligence — prati crypto repozitorije na GitHubu
///
/// Dvije strategije:
/// 1. GitHub Search API — traži nedavno kreirane crypto repoe
/// 2. Trending crypto — top pushani repoi s crypto topicom
///
/// GitHub aktivnost je legitimacy signal:
/// - Lažni projekti rijetko imaju aktivan GitHub
/// - Nagli rast starova = community interest raste
/// - Nedavni commits = tim aktivno radi
///
/// Javni API, 60 req/h bez autentikacije.
class GitHubIntelligence {
  static const _baseUrl = 'https://api.github.com';
  static const _timeout = Duration(seconds: 15);

  static const List<String> _cryptoTopics = [
    'blockchain', 'defi', 'web3', 'token', 'crypto',
    'smart-contract', 'dex', 'nft', 'dao', 'yield-farming',
  ];

  final http.Client _client;

  GitHubIntelligence({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'CoinSight-Intelligence/3.0',
      };

  /// Traži nedavno kreirane crypto repozitorije (zadnja 24h)
  Future<List<GitHubSignal>> searchNewCryptoRepos() async {
    final yesterday =
        DateTime.now().subtract(const Duration(hours: 24));
    final dateStr = yesterday.toIso8601String().substring(0, 10);

    final List<GitHubSignal> results = [];

    for (final topic in _cryptoTopics.take(5)) {
      try {
        final signals =
            await _searchByTopic(topic, createdAfter: dateStr);
        results.addAll(signals);
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (_) {
        continue;
      }
    }

    final seen = <String>{};
    return results.where((s) => seen.add(s.repoName)).toList();
  }

  /// Traži GitHub repo po imenu/simbolu coina
  Future<GitHubSignal?> searchByCoinName(String coinName) async {
    final query =
        '${Uri.encodeQueryComponent(coinName)}+topic:blockchain';
    final uri = Uri.parse(
      '$_baseUrl/search/repositories?q=$query&sort=stars&order=desc&per_page=5',
    );

    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(_timeout);

      if (res.statusCode == 403) return null; // rate limited
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      if (items.isEmpty) return null;

      return GitHubSignal.fromJson(
          items.first as Map<String, dynamic>);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Dohvaća trending crypto repoe za danas
  Future<List<GitHubSignal>> getTrendingCryptoToday() async {
    final uri = Uri.parse(
      '$_baseUrl/search/repositories'
      '?q=topic:blockchain+topic:crypto+pushed:>${_todayString()}'
      '&sort=stars&order=desc&per_page=20',
    );

    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(_timeout);

      if (res.statusCode == 403) return [];
      if (res.statusCode != 200) return [];

      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      return items
          .map((item) =>
              GitHubSignal.fromJson(item as Map<String, dynamic>))
          .where((s) => s.isRecentlyActive && s.hasCryptoTopics)
          .toList();
    } on TimeoutException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<GitHubSignal>> _searchByTopic(
    String topic, {
    required String createdAfter,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/search/repositories'
      '?q=topic:$topic+created:>$createdAfter'
      '&sort=stars&order=desc&per_page=10',
    );

    final res =
        await _client.get(uri, headers: _headers).timeout(_timeout);
    if (res.statusCode != 200) return [];

    final data = json.decode(res.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items
        .map((item) =>
            GitHubSignal.fromJson(item as Map<String, dynamic>))
        .where((s) => s.hasCryptoTopics)
        .toList();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Provjerava rate limit status
  Future<int> getRemainingRateLimit() async {
    final uri = Uri.parse('$_baseUrl/rate_limit');
    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return 0;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final resources = data['resources'] as Map<String, dynamic>?;
      final core = resources?['core'] as Map<String, dynamic>?;
      return (core?['remaining'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
