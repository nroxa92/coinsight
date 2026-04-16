import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/intelligence_report.dart';
import 'package:coinsight/models/dexscreener_signal.dart';
import 'package:coinsight/models/github_signal.dart';
import 'package:coinsight/models/reddit_signal.dart';
import 'package:coinsight/models/telegram_signal.dart';
import 'package:coinsight/models/coin.dart';

void main() {
  group('IntelligenceReport', () {
    // ───────── HELPER FACTORIES ─────────

    DexscreenerSignal makeDexSignal({
      bool fresh = true,
      double liquidity = 50000,
      double volume = 100000,
    }) {
      final createdAt = fresh
          ? DateTime.now().subtract(const Duration(hours: 6))
          : DateTime.now().subtract(const Duration(hours: 48));
      return DexscreenerSignal(
        pairAddress: '0xabc',
        baseTokenSymbol: 'TEST',
        baseTokenName: 'Test Token',
        baseTokenAddress: '0xtoken',
        quoteTokenSymbol: 'WETH',
        dexId: 'uniswap',
        chainId: 'ethereum',
        priceUsd: 0.001,
        volumeUsd24h: volume,
        liquidityUsd: liquidity,
        priceChange1h: 5.0,
        priceChange24h: 15.0,
        pairCreatedAt: createdAt.millisecondsSinceEpoch ~/ 1000,
        detectedAt: DateTime.now(),
      );
    }

    GitHubSignal makeGithubSignal({
      bool hasCryptoTopics = true,
      bool recentlyActive = true,
      double starVelocity = 0.2,
    }) {
      final stars = 1000;
      final starsToday = (starVelocity * stars).toInt();
      return GitHubSignal(
        repoName: 'org/test-project',
        description: hasCryptoTopics ? 'A blockchain project' : 'A todo app',
        language: 'Solidity',
        stars: stars,
        starsToday: starsToday,
        forks: 100,
        openIssues: 10,
        pushedAt: recentlyActive
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        topics: hasCryptoTopics ? ['blockchain', 'defi'] : ['web', 'app'],
        detectedAt: DateTime.now(),
      );
    }

    RedditSignal makeRedditSignal({
      int upvotes = 200,
      double upvoteRatio = 0.9,
      int hoursAgo = 2,
    }) {
      return RedditSignal(
        postId: 'reddit1',
        title: 'TEST is the next big thing',
        subreddit: 'CryptoMoonShots',
        upvotes: upvotes,
        comments: 50,
        upvoteRatio: upvoteRatio,
        createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
        detectedAt: DateTime.now(),
        mentionedSymbols: ['TEST'],
      );
    }

    TelegramSignal makeTelegramSignal({
      String channelUsername = '@whale_alert',
      String text = 'Large whale transfer detected',
    }) {
      return TelegramSignal(
        text: text,
        channelTitle: 'Whale Alert',
        channelUsername: channelUsername,
        timestamp: DateTime.now(),
        messageId: '1',
      );
    }

    Coin makeMarketData({
      double priceChange1h = 5.0,
      double priceChange24h = 10.0,
      double totalVolume = 5000000,
      double marketCap = 1000000,
    }) {
      return Coin(
        id: 'test-token',
        symbol: 'test',
        name: 'Test Token',
        image: 'https://example.com/test.png',
        currentPrice: 0.001,
        marketCap: marketCap,
        marketCapRank: 500,
        priceChangePercentage24h: priceChange24h,
        priceChangePercentage1h: priceChange1h,
        high24h: 0.002,
        low24h: 0.0005,
        totalVolume: totalVolume,
      );
    }

    IntelligenceReport makeReport({
      DexscreenerSignal? dexSignal,
      GitHubSignal? githubSignal,
      List<RedditSignal> redditSignals = const [],
      List<TelegramSignal> telegramSignals = const [],
      Coin? marketData,
    }) {
      return IntelligenceReport(
        symbol: 'TEST',
        generatedAt: DateTime.now(),
        dexSignal: dexSignal,
        githubSignal: githubSignal,
        redditSignals: redditSignals,
        telegramSignals: telegramSignals,
        marketData: marketData,
      );
    }

    // ───────── DEX SCORE ─────────

    group('dexScore', () {
      test('is 0 when no dex signal', () {
        final report = makeReport();
        expect(report.dexScore, 0);
      });

      test('max 2.0 for fresh + liquid + high vol/liq ratio', () {
        final report = makeReport(
          dexSignal: makeDexSignal(
            fresh: true,
            liquidity: 50000,
            volume: 100000, // vol/liq ratio = 2.0 > 1.0
          ),
        );
        expect(report.dexScore, 2.0);
      });

      test('partial score for non-fresh pair', () {
        final report = makeReport(
          dexSignal: makeDexSignal(
            fresh: false,
            liquidity: 50000,
            volume: 100000,
          ),
        );
        // no fresh bonus, but has liquidity (0.5) + high vol/liq (0.5) = 1.0
        expect(report.dexScore, 1.0);
      });
    });

    // ───────── GITHUB SCORE ─────────

    group('githubScore', () {
      test('is 0 when no github signal', () {
        final report = makeReport();
        expect(report.githubScore, 0);
      });

      test('max 1.0 for crypto topics + active + high velocity', () {
        final report = makeReport(
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: true,
            starVelocity: 0.2, // > 0.1
          ),
        );
        // crypto (0.5) + active (0.3) + velocity (0.2) = 1.0
        expect(report.githubScore, 1.0);
      });

      test('partial score for non-active repo', () {
        final report = makeReport(
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: false,
            starVelocity: 0.05, // < 0.1
          ),
        );
        // crypto (0.5) only
        expect(report.githubScore, 0.5);
      });
    });

    // ───────── REDDIT SCORE ─────────

    group('redditScore', () {
      test('is 0 when empty', () {
        final report = makeReport();
        expect(report.redditScore, 0);
      });

      test('scales based on best momentum score / 50', () {
        final report = makeReport(
          redditSignals: [
            makeRedditSignal(upvotes: 100, upvoteRatio: 0.9, hoursAgo: 2),
          ],
        );
        // momentum = (100 * 0.9) / 2 = 45, score = 45/50 = 0.9
        expect(report.redditScore, closeTo(0.9, 0.1));
      });

      test('clamps to max 1.0', () {
        final report = makeReport(
          redditSignals: [
            makeRedditSignal(upvotes: 500, upvoteRatio: 1.0, hoursAgo: 1),
          ],
        );
        // momentum = 500/1 = 500, score = 500/50 = 10 -> clamped to 1.0
        expect(report.redditScore, 1.0);
      });
    });

    // ───────── TELEGRAM SCORE ─────────

    group('telegramScore', () {
      test('is 0 when empty', () {
        final report = makeReport();
        expect(report.telegramScore, 0);
      });

      test('gives 0.5 for whale alert signal', () {
        final report = makeReport(
          telegramSignals: [
            makeTelegramSignal(
              channelUsername: '@whale_alert',
              text: 'Large transfer',
            ),
          ],
        );
        expect(report.telegramScore, 0.5);
      });

      test('gives 0.3 for exchange signal', () {
        final report = makeReport(
          telegramSignals: [
            makeTelegramSignal(
              channelUsername: '@binance_announce',
              text: 'New listing',
            ),
          ],
        );
        expect(report.telegramScore, 0.3);
      });
    });

    // ───────── MARKET SCORE ─────────

    group('marketScore', () {
      test('is 0 when no market data', () {
        final report = makeReport();
        expect(report.marketScore, 0);
      });

      test('max 1.0 for positive 1h + positive 24h + high vol/mcap', () {
        final report = makeReport(
          marketData: makeMarketData(
            priceChange1h: 5.0,
            priceChange24h: 10.0,
            totalVolume: 500000, // vol/mcap = 0.5 > 0.1
            marketCap: 1000000,
          ),
        );
        // 1h positive (0.5) + 24h positive (0.3) + high vol/mcap (0.2) = 1.0
        expect(report.marketScore, 1.0);
      });

      test('partial score for negative price change', () {
        final report = makeReport(
          marketData: makeMarketData(
            priceChange1h: -2.0,
            priceChange24h: -5.0,
            totalVolume: 50000,
            marketCap: 1000000, // vol/mcap = 0.05 < 0.1
          ),
        );
        expect(report.marketScore, 0);
      });
    });

    // ───────── CONFLUENCE SCORE ─────────

    group('confluenceScore', () {
      test('is sum of all scores', () {
        final report = makeReport(
          dexSignal: makeDexSignal(),
          githubSignal: makeGithubSignal(),
        );
        expect(report.confluenceScore, report.dexScore + report.githubScore);
      });

      test('max is 6.0', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: true, liquidity: 50000, volume: 100000),
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: true,
            starVelocity: 0.2,
          ),
          redditSignals: [
            makeRedditSignal(upvotes: 500, upvoteRatio: 1.0, hoursAgo: 1),
          ],
          telegramSignals: [
            makeTelegramSignal(channelUsername: '@whale_alert'),
            makeTelegramSignal(
              channelUsername: '@whale_alert_2',
              text: 'Another whale transfer detected',
            ),
          ],
          marketData: makeMarketData(
            priceChange1h: 5.0,
            priceChange24h: 10.0,
            totalVolume: 500000,
            marketCap: 1000000,
          ),
        );
        // dex=2.0 + github=1.0 + reddit=1.0 + telegram=0.8 clamped to 1.0 + market=1.0 = 6.0
        expect(report.confluenceScore, 6.0);
      });
    });

    // ───────── SCORING HINT ─────────

    group('scoringHint', () {
      test('STRONG_INTERESTING when score >= 4.0', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: true, liquidity: 50000, volume: 100000),
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: true,
            starVelocity: 0.2,
          ),
          redditSignals: [
            makeRedditSignal(upvotes: 500, upvoteRatio: 1.0, hoursAgo: 1),
          ],
          marketData: makeMarketData(),
        );
        // 2.0 + 1.0 + 1.0 + 1.0 = 5.0, 5 active sources
        expect(report.scoringHint, 'STRONG_INTERESTING');
      });

      test('POSSIBLE_WATCH when score 2.5-3.9', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: true, liquidity: 50000, volume: 100000),
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: false,
            starVelocity: 0.05,
          ),
        );
        // dex=2.0, github=0.5 = 2.5, 2 active sources
        expect(report.scoringHint, 'POSSIBLE_WATCH');
      });

      test('WEAK_SIGNAL when score 1.5-2.4', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: false, liquidity: 50000, volume: 100000),
          githubSignal: makeGithubSignal(
            hasCryptoTopics: true,
            recentlyActive: false,
            starVelocity: 0.05,
          ),
        );
        // dex=1.0, github=0.5 = 1.5, 2 active sources
        expect(report.scoringHint, 'WEAK_SIGNAL');
      });

      test('LIKELY_SKIP when score < 1.5', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: false, liquidity: 5000, volume: 1000),
          githubSignal: makeGithubSignal(
            hasCryptoTopics: false,
            recentlyActive: false,
            starVelocity: 0.01,
          ),
        );
        // dex: no fresh, no min liq, vol/liq < 1 = 0, github: no crypto = 0, total = 0
        expect(report.scoringHint, 'LIKELY_SKIP');
      });

      test('INSUFFICIENT_DATA when activeSources < 2', () {
        final report = makeReport(
          dexSignal: makeDexSignal(fresh: true, liquidity: 50000, volume: 100000),
        );
        // Only 1 active source, even though dexScore = 2.0
        expect(report.scoringHint, 'INSUFFICIENT_DATA');
      });
    });

    // ───────── ACTIVE SOURCES ─────────

    group('activeSources', () {
      test('counts correctly with all sources', () {
        final report = makeReport(
          dexSignal: makeDexSignal(),
          githubSignal: makeGithubSignal(),
          redditSignals: [makeRedditSignal()],
          telegramSignals: [makeTelegramSignal()],
          marketData: makeMarketData(),
        );
        expect(report.activeSources, 5);
      });

      test('counts correctly with no sources', () {
        final report = makeReport();
        expect(report.activeSources, 0);
      });

      test('counts correctly with partial sources', () {
        final report = makeReport(
          dexSignal: makeDexSignal(),
          redditSignals: [makeRedditSignal()],
        );
        expect(report.activeSources, 2);
      });
    });

    // ───────── TO CLAUDE CONTEXT ─────────

    group('toClaudeContext', () {
      test('includes all active sources', () {
        final report = makeReport(
          dexSignal: makeDexSignal(),
          githubSignal: makeGithubSignal(),
          redditSignals: [makeRedditSignal()],
          telegramSignals: [makeTelegramSignal()],
          marketData: makeMarketData(),
        );
        final context = report.toClaudeContext();
        expect(context, contains('INTELLIGENCE REPORT'));
        expect(context, contains('TEST'));
        expect(context, contains('DEX LISTING'));
        expect(context, contains('GITHUB'));
        expect(context, contains('REDDIT'));
        expect(context, contains('TELEGRAM'));
        expect(context, contains('MARKET DATA'));
        expect(context, contains('Aktivni izvori: 5/5'));
        expect(context, contains('Confluence score'));
      });

      test('shows nema podataka for missing sources', () {
        final report = makeReport();
        final context = report.toClaudeContext();
        expect(context, contains('nema podataka'));
      });
    });
  });
}
