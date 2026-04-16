import 'dart:async';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/dexscreener_signal.dart';
import 'package:coinsight/models/github_signal.dart';
import 'package:coinsight/models/reddit_signal.dart';
import 'package:coinsight/models/intelligence_report.dart';
import 'package:coinsight/services/dexscreener_service.dart';
import 'package:coinsight/services/github_intelligence.dart';
import 'package:coinsight/services/reddit_monitor.dart';
import 'package:coinsight/services/telegram_monitor.dart';
import 'package:coinsight/services/coingecko_service.dart';

/// IntelligenceAggregator — koordinira sve intelligence servise
///
/// Odgovornosti:
/// 1. Paralelno fetchuje podatke iz svih izvora
/// 2. Gradi IntelligenceReport za specifičan coin
/// 3. Pokreće periodičko background skeniranje
/// 4. Notificira AnalysisProvider kad pronađe visoko-score signale
class IntelligenceAggregator {
  final DexscreenerService _dex;
  final GitHubIntelligence _github;
  final RedditMonitor _reddit;
  final TelegramMonitor _telegram;
  final CoinGeckoService _coinGecko;

  Timer? _scanTimer;

  Function(IntelligenceReport report)? onHighScoreSignal;

  List<DexscreenerSignal> _lastDexScan = [];
  List<GitHubSignal> _lastGithubScan = [];
  List<RedditSignal> _lastRedditScan = [];
  DateTime? _lastScanTime;

  static const _minScoreForNotification = 3.0;
  static const _scanInterval = Duration(minutes: 15);

  IntelligenceAggregator({
    DexscreenerService? dex,
    GitHubIntelligence? github,
    RedditMonitor? reddit,
    TelegramMonitor? telegram,
    CoinGeckoService? coinGecko,
  })  : _dex = dex ?? DexscreenerService(),
        _github = github ?? GitHubIntelligence(),
        _reddit = reddit ?? RedditMonitor(),
        _telegram = telegram ?? TelegramMonitor(),
        _coinGecko = coinGecko ?? CoinGeckoService();

  // ───────── BACKGROUND SCANNING ─────────

  void startAutoScan() {
    _scanTimer?.cancel();
    _runScan();
    _scanTimer = Timer.periodic(_scanInterval, (_) => _runScan());
  }

  void stopAutoScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  Future<void> _runScan() async {
    try {
      final results = await Future.wait([
        _dex.getNewPairs(),
        _github.getTrendingCryptoToday(),
        _reddit.getNewPosts(),
      ]);

      _lastDexScan = results[0] as List<DexscreenerSignal>;
      _lastGithubScan = results[1] as List<GitHubSignal>;
      _lastRedditScan = results[2] as List<RedditSignal>;
      _lastScanTime = DateTime.now();

      await _findCrossSourceMatches();
    } catch (_) {
      // Silent fail — background scan ne smije rušiti app
    }
  }

  Future<void> _findCrossSourceMatches() async {
    if (_lastDexScan.isEmpty) return;

    for (final dexSignal in _lastDexScan.take(10)) {
      final symbol = dexSignal.baseTokenSymbol.toUpperCase();

      final redditMatches = _lastRedditScan
          .where((r) => r.mentionedSymbols.contains(symbol))
          .toList();

      if (redditMatches.isNotEmpty ||
          dexSignal.volumeLiquidityRatio > 2.0) {
        final report = await buildReportForSymbol(
          symbol: symbol,
          dexSignal: dexSignal,
        );

        if (report.confluenceScore >= _minScoreForNotification) {
          onHighScoreSignal?.call(report);
        }
      }
    }
  }

  // ───────── ON-DEMAND REPORT BUILDING ─────────

  /// Gradi kompletan IntelligenceReport za specifičan simbol
  Future<IntelligenceReport> buildReportForSymbol({
    required String symbol,
    DexscreenerSignal? dexSignal,
    Coin? marketData,
  }) async {
    final futures = await Future.wait([
      dexSignal != null
          ? Future.value(dexSignal)
          : _dex.searchBySymbol(symbol),
      _github.searchByCoinName(symbol),
      _reddit.searchBySymbol(symbol),
    ]);

    final resolvedDex = futures[0] as DexscreenerSignal?;
    final resolvedGithub = futures[1] as GitHubSignal?;
    final resolvedReddit = futures[2] as List<RedditSignal>;

    final telegramSignals =
        _telegram.getRecentSignalsForSymbol(symbol);

    Coin? resolvedMarket = marketData;
    if (resolvedMarket == null) {
      try {
        final coins = await _coinGecko.searchBySymbol(symbol);
        resolvedMarket = coins.isNotEmpty ? coins.first : null;
      } catch (_) {
        resolvedMarket = null;
      }
    }

    return IntelligenceReport(
      symbol: symbol,
      generatedAt: DateTime.now(),
      dexSignal: resolvedDex,
      githubSignal: resolvedGithub,
      redditSignals: resolvedReddit,
      telegramSignals: telegramSignals,
      marketData: resolvedMarket,
    );
  }

  List<DexscreenerSignal> get cachedDexSignals => _lastDexScan;
  List<GitHubSignal> get cachedGithubSignals => _lastGithubScan;
  DateTime? get lastScanTime => _lastScanTime;
}
