import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/reddit_signal.dart';

/// RedditMonitor — prati crypto subreddite za early community signale
///
/// Reddit je retail sentiment indikator — kasni za smartim novcem
/// ali visoka upvote velocity na nepoznatom coinu = pump počinje
///
/// Koristi Reddit public JSON API (bez autentikacije)
/// Format: https://www.reddit.com/r/{subreddit}/new.json
class RedditMonitor {
  static const _baseUrl = 'https://www.reddit.com';
  static const _timeout = Duration(seconds: 15);

  static const List<String> monitoredSubreddits = [
    'CryptoMoonShots',
    'altcoin',
    'CryptoCurrency',
    'defi',
    'SatoshiStreetBets',
  ];

  static const int _minUpvotes = 10;
  static const int _maxAgeHours = 6;

  static final _symbolRegex = RegExp(r'\b[A-Z]{2,10}\b');
  static const _ignoreSymbols = {
    'USD', 'EUR', 'BTC', 'ETH', 'SOL', 'BNB', 'ADA',
    'USDT', 'USDC', 'NFT', 'DAO', 'APY', 'ROI',
    'ATH', 'ATL', 'CEX', 'DEX', 'ICO', 'IDO', 'IPO',
    'THE', 'FOR', 'AND', 'THIS', 'THAT', 'WITH',
    'HAS', 'NOT', 'ARE', 'BUT', 'ALL', 'NEW',
  };

  final http.Client _client;

  RedditMonitor({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'User-Agent': 'CoinSight/3.0 (intelligence monitoring)',
      };

  /// Dohvaća nove objave sa svih praćenih subreddita
  Future<List<RedditSignal>> getNewPosts() async {
    final List<RedditSignal> results = [];

    for (final sub in monitoredSubreddits) {
      try {
        final posts = await _getSubredditNew(sub);
        results.addAll(posts);
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (_) {
        continue;
      }
    }

    results.sort((a, b) => b.momentumScore.compareTo(a.momentumScore));
    return results;
  }

  /// Traži objave koje spominju specifičan simbol
  Future<List<RedditSignal>> searchBySymbol(String symbol) async {
    final List<RedditSignal> results = [];

    for (final sub in monitoredSubreddits.take(3)) {
      try {
        final uri = Uri.parse(
          '$_baseUrl/r/$sub/search.json'
          '?q=${Uri.encodeQueryComponent(symbol)}'
          '&sort=new&t=day&limit=10',
        );

        final res =
            await _client.get(uri, headers: _headers).timeout(_timeout);
        if (res.statusCode != 200) continue;

        final signals = _parseResponse(res.body, sub);
        results.addAll(signals);
      } catch (_) {
        continue;
      }
    }

    return results;
  }

  Future<List<RedditSignal>> _getSubredditNew(String subreddit) async {
    final uri = Uri.parse('$_baseUrl/r/$subreddit/new.json?limit=25');

    final res =
        await _client.get(uri, headers: _headers).timeout(_timeout);
    if (res.statusCode != 200) return [];

    return _parseResponse(res.body, subreddit);
  }

  List<RedditSignal> _parseResponse(String body, String subreddit) {
    try {
      final data = json.decode(body) as Map<String, dynamic>;
      final listing = data['data'] as Map<String, dynamic>? ?? {};
      final children = listing['children'] as List<dynamic>? ?? [];

      final List<RedditSignal> signals = [];

      for (final child in children) {
        final post = (child as Map<String, dynamic>)['data']
            as Map<String, dynamic>? ?? {};

        final upvotes = (post['ups'] as num?)?.toInt() ?? 0;
        if (upvotes < _minUpvotes) continue;

        final createdUtc = (post['created_utc'] as num?)?.toInt() ?? 0;
        final createdAt = DateTime.fromMillisecondsSinceEpoch(
          createdUtc * 1000,
          isUtc: true,
        ).toLocal();

        final ageHours = DateTime.now().difference(createdAt).inHours;
        if (ageHours > _maxAgeHours) continue;

        final title = post['title'] as String? ?? '';
        final mentionedSymbols = _extractSymbols(title);

        signals.add(RedditSignal(
          postId: post['id'] as String? ?? '',
          title: title,
          subreddit: subreddit,
          upvotes: upvotes,
          comments: (post['num_comments'] as num?)?.toInt() ?? 0,
          upvoteRatio:
              (post['upvote_ratio'] as num?)?.toDouble() ?? 0.5,
          createdAt: createdAt,
          detectedAt: DateTime.now(),
          mentionedSymbols: mentionedSymbols,
        ));
      }

      return signals;
    } on FormatException {
      return [];
    }
  }

  List<String> _extractSymbols(String text) {
    return _symbolRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .where((s) => !_ignoreSymbols.contains(s))
        .toSet()
        .toList();
  }
}
