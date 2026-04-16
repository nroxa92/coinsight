import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/services/claude_service.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() => registerFallbacks());

  group('ClaudeService', () {
    test('sendMessage returns text from successful response', () async {
      final responseBody = json.encode({
        'content': [
          {'type': 'text', 'text': 'Hello from Claude'}
        ],
      });
      final client = HttpClientFactory.returning(responseBody);
      final service = ClaudeService(client: client, apiKey: 'test-key');

      final result = await service.sendMessage(userMessage: 'Hi');
      expect(result, 'Hello from Claude');
    });

    test('sendMessage throws ClaudeException when no API key', () async {
      final service = ClaudeService();
      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(isA<ClaudeException>()),
      );
    });

    test('sendMessage throws ClaudeException on 401', () async {
      final client = HttpClientFactory.returning('', statusCode: 401);
      final service = ClaudeService(client: client, apiKey: 'bad-key');

      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(
          isA<ClaudeException>().having(
            (e) => e.message,
            'message',
            contains('Invalid API key'),
          ),
        ),
      );
    });

    test('sendMessage throws ClaudeException on 429 rate limit', () async {
      final client = HttpClientFactory.returning('', statusCode: 429);
      final service = ClaudeService(client: client, apiKey: 'test-key');

      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(
          isA<ClaudeException>().having(
            (e) => e.message,
            'message',
            contains('Rate limited'),
          ),
        ),
      );
    });

    test('sendMessage throws ClaudeException on timeout', () async {
      final client = HttpClientFactory.throwingTimeout();
      final service = ClaudeService(client: client, apiKey: 'test-key');

      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(
          isA<ClaudeException>().having(
            (e) => e.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
    });

    test('sendMessage throws ClaudeException on empty content', () async {
      final responseBody = json.encode({
        'content': [],
      });
      final client = HttpClientFactory.returning(responseBody);
      final service = ClaudeService(client: client, apiKey: 'test-key');

      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(isA<ClaudeException>()),
      );
    });

    test('sendMessage throws ClaudeException on malformed JSON', () async {
      final client = HttpClientFactory.returning('not json');
      final service = ClaudeService(client: client, apiKey: 'test-key');

      expect(
        () => service.sendMessage(userMessage: 'Hi'),
        throwsA(isA<ClaudeException>()),
      );
    });

    test('hasApiKey returns true when key is set', () {
      final service = ClaudeService(apiKey: 'sk-ant-test');
      expect(service.hasApiKey, true);
    });

    test('hasApiKey returns false when key is empty', () {
      final service = ClaudeService(apiKey: '');
      expect(service.hasApiKey, false);
    });

    test('hasApiKey returns false when key is null', () {
      final service = ClaudeService();
      expect(service.hasApiKey, false);
    });

    test('setApiKey updates the key', () {
      final service = ClaudeService();
      expect(service.hasApiKey, false);
      service.setApiKey('new-key');
      expect(service.hasApiKey, true);
    });
  });

  group('ChatMessage', () {
    test('toJson returns correct map', () {
      final msg = ChatMessage(role: 'user', content: 'Hello');
      expect(msg.toJson(), {'role': 'user', 'content': 'Hello'});
    });

    test('timestamp defaults to now', () {
      final before = DateTime.now();
      final msg = ChatMessage(role: 'user', content: 'Hi');
      final after = DateTime.now();
      expect(msg.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
          true);
      expect(msg.timestamp.isBefore(after.add(const Duration(seconds: 1))),
          true);
    });
  });
}
