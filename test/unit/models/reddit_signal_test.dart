import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/reddit_signal.dart';

void main() {
  group('RedditSignal', () {
    RedditSignal makeSignal({
      int upvotes = 100,
      double upvoteRatio = 0.85,
      int hoursAgo = 3,
      int comments = 25,
      String subreddit = 'CryptoMoonShots',
      List<String> mentionedSymbols = const ['XYZ'],
    }) {
      return RedditSignal(
        postId: 'abc123',
        title: 'Check out XYZ token',
        subreddit: subreddit,
        upvotes: upvotes,
        comments: comments,
        upvoteRatio: upvoteRatio,
        createdAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
        detectedAt: DateTime.now(),
        mentionedSymbols: mentionedSymbols,
      );
    }

    group('ageHours', () {
      test('calculates hours since creation', () {
        final signal = makeSignal(hoursAgo: 5);
        expect(signal.ageHours, closeTo(5, 1));
      });
    });

    group('isFresh', () {
      test('returns true when age <= 12 hours', () {
        final signal = makeSignal(hoursAgo: 6);
        expect(signal.isFresh, true);
      });

      test('returns false when age > 12 hours', () {
        final signal = makeSignal(hoursAgo: 20);
        expect(signal.isFresh, false);
      });
    });

    group('momentumScore', () {
      test('calculates (upvotes * upvoteRatio) / ageHours', () {
        final signal = makeSignal(upvotes: 100, upvoteRatio: 0.8, hoursAgo: 4);
        // (100 * 0.8) / 4 = 20.0
        expect(signal.momentumScore, closeTo(20.0, 1.0));
      });

      test('clamps ageHours minimum to 1', () {
        // Very fresh post (0 hours ago) should use 1 as denominator
        final signal = RedditSignal(
          postId: 'fresh',
          title: 'Fresh post',
          subreddit: 'CryptoMoonShots',
          upvotes: 50,
          comments: 10,
          upvoteRatio: 0.9,
          createdAt: DateTime.now(), // 0 hours ago
          detectedAt: DateTime.now(),
          mentionedSymbols: ['XYZ'],
        );
        // (50 * 0.9) / 1 = 45.0
        expect(signal.momentumScore, closeTo(45.0, 1.0));
      });

      test('clamps ageHours maximum to 24', () {
        final signal = makeSignal(upvotes: 100, upvoteRatio: 1.0, hoursAgo: 48);
        // (100 * 1.0) / 24 = ~4.17
        expect(signal.momentumScore, closeTo(4.17, 0.5));
      });
    });

    group('toClaudeContext', () {
      test('contains all key fields', () {
        final signal = makeSignal();
        final context = signal.toClaudeContext();
        expect(context, contains('REDDIT SIGNAL'));
        expect(context, contains('r/CryptoMoonShots'));
        expect(context, contains('Upvotes: 100'));
        expect(context, contains('Komentari: 25'));
        expect(context, contains('Momentum score'));
        expect(context, contains('XYZ'));
      });
    });
  });
}
