import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/github_signal.dart';

void main() {
  group('GitHubSignal', () {
    Map<String, dynamic> validJson() => {
          'full_name': 'org/crypto-project',
          'description': 'A decentralized exchange protocol',
          'language': 'Solidity',
          'stargazers_count': 1000,
          'stars_today': 50,
          'forks_count': 200,
          'open_issues_count': 15,
          'pushed_at': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'created_at': DateTime.now()
              .subtract(const Duration(days: 90))
              .toIso8601String(),
          'topics': ['blockchain', 'defi', 'solidity'],
        };

    group('fromJson', () {
      test('parses all fields correctly', () {
        final signal = GitHubSignal.fromJson(validJson());
        expect(signal.repoName, 'org/crypto-project');
        expect(signal.description, 'A decentralized exchange protocol');
        expect(signal.language, 'Solidity');
        expect(signal.stars, 1000);
        expect(signal.starsToday, 50);
        expect(signal.forks, 200);
        expect(signal.openIssues, 15);
        expect(signal.topics, ['blockchain', 'defi', 'solidity']);
      });

      test('handles missing optional fields with defaults', () {
        final signal = GitHubSignal.fromJson({});
        expect(signal.repoName, '');
        expect(signal.description, '');
        expect(signal.stars, 0);
        expect(signal.starsToday, 0);
        expect(signal.topics, isEmpty);
      });
    });

    group('ageDays', () {
      test('calculates days since creation', () {
        final signal = GitHubSignal.fromJson(validJson());
        expect(signal.ageDays, closeTo(90, 1));
      });
    });

    group('isRecentlyActive', () {
      test('returns true when pushed within 7 days', () {
        final signal = GitHubSignal.fromJson(validJson());
        expect(signal.isRecentlyActive, true);
      });

      test('returns false when pushed more than 7 days ago', () {
        final json = validJson();
        json['pushed_at'] = DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String();
        final signal = GitHubSignal.fromJson(json);
        expect(signal.isRecentlyActive, false);
      });
    });

    group('starVelocity', () {
      test('calculates starsToday / stars ratio', () {
        final signal = GitHubSignal.fromJson(validJson());
        // 50 / 1000 = 0.05
        expect(signal.starVelocity, 0.05);
      });

      test('returns 0 when stars is 0', () {
        final json = validJson();
        json['stargazers_count'] = 0;
        final signal = GitHubSignal.fromJson(json);
        expect(signal.starVelocity, 0);
      });
    });

    group('hasCryptoTopics', () {
      test('returns true when topics contain blockchain keyword', () {
        final signal = GitHubSignal.fromJson(validJson());
        expect(signal.hasCryptoTopics, true);
      });

      test('returns true when description contains crypto keyword', () {
        final json = validJson();
        json['topics'] = ['general', 'finance'];
        json['description'] = 'A blockchain based project';
        final signal = GitHubSignal.fromJson(json);
        expect(signal.hasCryptoTopics, true);
      });

      test('returns false when no crypto keywords present', () {
        final json = validJson();
        json['topics'] = ['web', 'frontend', 'react'];
        json['description'] = 'A todo list application';
        final signal = GitHubSignal.fromJson(json);
        expect(signal.hasCryptoTopics, false);
      });
    });

    group('toClaudeContext', () {
      test('contains all key fields', () {
        final signal = GitHubSignal.fromJson(validJson());
        final context = signal.toClaudeContext();
        expect(context, contains('GITHUB SIGNAL'));
        expect(context, contains('org/crypto-project'));
        expect(context, contains('Stars: 1000'));
        expect(context, contains('+50'));
        expect(context, contains('DA')); // isRecentlyActive
        expect(context, contains('VISOKA')); // hasCryptoTopics
      });

      test('shows NE for inactive repo', () {
        final json = validJson();
        json['pushed_at'] = DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String();
        final signal = GitHubSignal.fromJson(json);
        expect(signal.toClaudeContext(), contains('NE'));
      });

      test('shows NISKA for non-crypto repo', () {
        final json = validJson();
        json['topics'] = ['web'];
        json['description'] = 'A todo app';
        final signal = GitHubSignal.fromJson(json);
        expect(signal.toClaudeContext(), contains('NISKA'));
      });
    });
  });
}
