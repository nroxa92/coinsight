import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/models/telegram_signal.dart';

void main() {
  group('TelegramSignal', () {
    test('preview truncates long text at 150 chars', () {
      final signal = TelegramSignal(
        text: 'A' * 200,
        channelTitle: 'Test',
        channelUsername: '@test',
        timestamp: DateTime.now(),
        messageId: '1',
      );
      expect(signal.preview.length, 153); // 150 + '...'
      expect(signal.preview.endsWith('...'), true);
    });

    test('preview returns full text when short', () {
      final signal = TelegramSignal(
        text: 'Short message',
        channelTitle: 'Test',
        channelUsername: '@test',
        timestamp: DateTime.now(),
        messageId: '1',
      );
      expect(signal.preview, 'Short message');
    });

    test('toClaudeContext formats correctly', () {
      final ts = DateTime(2026, 4, 15, 12, 0);
      final signal = TelegramSignal(
        text: 'New listing alert!',
        channelTitle: 'Binance',
        channelUsername: '@binance',
        timestamp: ts,
        messageId: '42',
      );
      final context = signal.toClaudeContext();
      expect(context, contains('[Telegram: Binance (@binance)'));
      expect(context, contains('New listing alert!'));
      expect(context, contains(ts.toIso8601String()));
    });
  });
}
