class TelegramSignal {
  final String text;
  final String channelTitle;
  final String channelUsername;
  final DateTime timestamp;
  final String messageId;

  TelegramSignal({
    required this.text,
    required this.channelTitle,
    required this.channelUsername,
    required this.timestamp,
    required this.messageId,
  });

  /// Short preview for UI
  String get preview =>
      text.length > 150 ? '${text.substring(0, 150)}...' : text;

  /// Formatted context for Claude
  String toClaudeContext() =>
      '[Telegram: $channelTitle ($channelUsername) @ '
      '${timestamp.toIso8601String()}]\n$text';
}
