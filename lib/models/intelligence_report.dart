import 'package:flutter/material.dart';
import 'package:coinsight/models/dexscreener_signal.dart';
import 'package:coinsight/models/github_signal.dart';
import 'package:coinsight/models/reddit_signal.dart';
import 'package:coinsight/models/telegram_signal.dart';
import 'package:coinsight/models/coin.dart';

/// Agregirani intelligence report za jedan coin/token
/// Kombinira sve dostupne izvore i kalkulira confluence score
class IntelligenceReport {
  final String symbol;
  final DateTime generatedAt;
  final DexscreenerSignal? dexSignal;
  final GitHubSignal? githubSignal;
  final List<RedditSignal> redditSignals;
  final List<TelegramSignal> telegramSignals;
  final Coin? marketData;

  IntelligenceReport({
    required this.symbol,
    required this.generatedAt,
    this.dexSignal,
    this.githubSignal,
    this.redditSignals = const [],
    this.telegramSignals = const [],
    this.marketData,
  });

  // ───────── SCORING ENGINE ─────────

  /// DEX score (0-2, highest weight — earliest signal)
  double get dexScore {
    if (dexSignal == null) return 0;
    double score = 0;
    if (dexSignal!.isFresh) score += 1.0;
    if (dexSignal!.hasMinimumLiquidity) score += 0.5;
    if (dexSignal!.volumeLiquidityRatio > 1.0) score += 0.5;
    return score.clamp(0, 2);
  }

  /// GitHub score (0-1, legitimacy signal)
  double get githubScore {
    if (githubSignal == null) return 0;
    double score = 0;
    if (githubSignal!.hasCryptoTopics) score += 0.5;
    if (githubSignal!.isRecentlyActive) score += 0.3;
    if (githubSignal!.starVelocity > 0.1) score += 0.2;
    return score.clamp(0, 1);
  }

  /// Reddit score (0-1, community sentiment)
  double get redditScore {
    if (redditSignals.isEmpty) return 0;
    final best = redditSignals
        .map((r) => r.momentumScore)
        .reduce((a, b) => a > b ? a : b);
    return (best / 50).clamp(0, 1);
  }

  /// Telegram score (0-1, smart money + exchange signals)
  double get telegramScore {
    if (telegramSignals.isEmpty) return 0;
    double score = 0;
    for (final signal in telegramSignals) {
      final text = signal.text.toLowerCase();
      if (signal.channelUsername.contains('whale_alert') ||
          text.contains('whale') ||
          text.contains('large transfer')) {
        score += 0.5;
      } else if (signal.channelUsername.contains('binance') ||
          signal.channelUsername.contains('kucoin') ||
          signal.channelUsername.contains('coingecko')) {
        score += 0.3;
      } else {
        score += 0.1;
      }
    }
    return score.clamp(0, 1);
  }

  /// Market data score (0-1, confirmation)
  double get marketScore {
    if (marketData == null) return 0;
    double score = 0;
    if ((marketData!.priceChangePercentage1h ?? 0) > 0) score += 0.5;
    if (marketData!.priceChangePercentage24h > 0) score += 0.3;
    final volMcapRatio = marketData!.marketCap > 0
        ? marketData!.totalVolume / marketData!.marketCap
        : 0;
    if (volMcapRatio > 0.1) score += 0.2;
    return score.clamp(0, 1);
  }

  /// Total confluence score (0-6)
  double get confluenceScore =>
      dexScore + githubScore + redditScore + telegramScore + marketScore;

  int get activeSources {
    int count = 0;
    if (dexSignal != null) count++;
    if (githubSignal != null) count++;
    if (redditSignals.isNotEmpty) count++;
    if (telegramSignals.isNotEmpty) count++;
    if (marketData != null) count++;
    return count;
  }

  String get scoringHint {
    if (activeSources < 2) return 'INSUFFICIENT_DATA';
    if (confluenceScore >= 4.0) return 'STRONG_INTERESTING';
    if (confluenceScore >= 2.5) return 'POSSIBLE_WATCH';
    if (confluenceScore >= 1.5) return 'WEAK_SIGNAL';
    return 'LIKELY_SKIP';
  }

  Color get scoreColor {
    if (confluenceScore >= 4.0) return const Color(0xFF4CAF50);
    if (confluenceScore >= 2.5) return const Color(0xFFFF9800);
    return const Color(0xFF9E9E9E);
  }

  // ───────── CLAUDE CONTEXT BUILDER ─────────

  String toClaudeContext() {
    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('INTELLIGENCE REPORT — $symbol');
    buffer.writeln('Generirano: ${generatedAt.toIso8601String()}');
    buffer.writeln('Aktivni izvori: $activeSources/5');
    buffer.writeln(
        'Confluence score: ${confluenceScore.toStringAsFixed(1)}/6.0');
    buffer.writeln('Scoring hint: $scoringHint');
    buffer.writeln('═══════════════════════════════════════\n');

    if (dexSignal != null) {
      buffer.writeln(
          '🔴 DEX LISTING (score: ${dexScore.toStringAsFixed(1)}/2.0)');
      buffer.writeln(dexSignal!.toClaudeContext());
      buffer.writeln();
    } else {
      buffer.writeln('⚫ DEX LISTING: nema podataka\n');
    }

    if (githubSignal != null) {
      buffer.writeln(
          '🟡 GITHUB (score: ${githubScore.toStringAsFixed(1)}/1.0)');
      buffer.writeln(githubSignal!.toClaudeContext());
      buffer.writeln();
    } else {
      buffer.writeln('⚫ GITHUB: nema podataka\n');
    }

    if (redditSignals.isNotEmpty) {
      buffer.writeln(
          '🟠 REDDIT (score: ${redditScore.toStringAsFixed(1)}/1.0)');
      for (final r in redditSignals.take(3)) {
        buffer.writeln(r.toClaudeContext());
        buffer.writeln();
      }
    } else {
      buffer.writeln('⚫ REDDIT: nema podataka\n');
    }

    if (telegramSignals.isNotEmpty) {
      buffer.writeln(
          '🔵 TELEGRAM (score: ${telegramScore.toStringAsFixed(1)}/1.0)');
      for (final t in telegramSignals.take(3)) {
        buffer.writeln(t.toClaudeContext());
        buffer.writeln();
      }
    } else {
      buffer.writeln('⚫ TELEGRAM: nema podataka\n');
    }

    if (marketData != null) {
      final coin = marketData!;
      buffer.writeln(
          '🟢 MARKET DATA (score: ${marketScore.toStringAsFixed(1)}/1.0)');
      buffer.writeln('Cijena: \$${coin.currentPrice.toStringAsFixed(6)}');
      buffer.writeln('Market cap rank: #${coin.marketCapRank}');
      buffer.writeln(
          'Volume 24h: \$${coin.totalVolume.toStringAsFixed(0)}');
      buffer.writeln(
          '1h: ${(coin.priceChangePercentage1h ?? 0) >= 0 ? "+" : ""}${(coin.priceChangePercentage1h ?? 0).toStringAsFixed(2)}%');
      buffer.writeln(
          '24h: ${coin.priceChangePercentage24h >= 0 ? "+" : ""}${coin.priceChangePercentage24h.toStringAsFixed(2)}%');
      buffer.writeln();
    } else {
      buffer.writeln(
          '⚫ MARKET DATA: coin nije na CoinGecku (prerano ili scam)\n');
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('INSTRUKCIJA ZA ANALIZU:');
    buffer.writeln(
        'Gore su podaci iz $activeSources intelligence izvora.');
    buffer.writeln(
        'Confluence score je ${confluenceScore.toStringAsFixed(1)}/6.0 — scoring hint: $scoringHint');
    buffer.writeln(
        'Analiziraj kroz sva tri objektiva i donesi finalnu odluku.');
    buffer.writeln(
        'Scoring hint je samo matematička procjena — ti imaš finalnu riječ.');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }
}
