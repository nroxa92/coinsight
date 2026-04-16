import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/telegram_signal.dart';
import 'package:coinsight/services/storage_service.dart';

/// TelegramMonitor - passive reader of public Telegram channels
///
/// Uses Telegram Bot API (getUpdates) to receive messages from
/// public channels the bot has joined as admin/member.
///
/// IMPORTANT: Bot must be added to each channel as an administrator
/// with "Read Messages" permission. User does this once manually.
///
/// Not a notification system - does not send messages to the user.
/// Only receives and filters incoming signals.
class TelegramMonitor {
  static const _baseUrl = 'https://api.telegram.org';
  static const _timeout = Duration(seconds: 15);
  static const _pollInterval = Duration(seconds: 10);

  // Default public channels to monitor
  static const List<String> defaultChannels = [
    '@binance',
    '@kucoincom',
    '@whale_alert',
    '@coingecko',
    '@coinmarketcap',
  ];

  // Trigger keywords for filtering - only relevant messages pass through
  static const List<String> _triggerKeywords = [
    'listing', 'listed', 'new coin', 'new token',
    'now available', 'trade now', 'spot trading',
    'whale', 'large transfer', 'moved',
    'breaking', 'urgent', 'alert',
  ];

  final http.Client _client;
  String? _botToken;
  int _lastUpdateId = 0;
  Timer? _pollTimer;

  // Callback invoked by AnalysisProvider when a relevant signal arrives
  Function(TelegramSignal signal)? onSignalReceived;

  TelegramMonitor({http.Client? client})
      : _client = client ?? http.Client() {
    _botToken = StorageService.getTelegramMonitorToken();
  }

  void reloadCredentials() {
    _botToken = StorageService.getTelegramMonitorToken();
  }

  bool get isConfigured => _botToken?.isNotEmpty ?? false;

  void startMonitoring() {
    if (!isConfigured) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  void stopMonitoring() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (!isConfigured) return;
    final uri = Uri.parse(
      '$_baseUrl/bot$_botToken/getUpdates'
      '?offset=${_lastUpdateId + 1}'
      '&timeout=0'
      '&allowed_updates=["channel_post","message"]',
    );
    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final updates = data['result'] as List<dynamic>? ?? [];
      for (final u in updates) {
        _processUpdate(u as Map<String, dynamic>);
      }
    } catch (_) {
      // Ignore polling errors - retry next tick
    }
  }

  void _processUpdate(Map<String, dynamic> update) {
    _lastUpdateId = (update['update_id'] as int?) ?? _lastUpdateId;

    // channel_post = message from channel, message = message from group
    final post = (update['channel_post'] ?? update['message'])
        as Map<String, dynamic>?;
    if (post == null) return;

    final text =
        post['text'] as String? ?? post['caption'] as String? ?? '';
    if (text.isEmpty) return;

    // Get channel info
    final chat = post['chat'] as Map<String, dynamic>? ?? {};
    final channelTitle =
        chat['title'] as String? ?? chat['username'] as String? ?? 'Unknown';
    final channelUsername = '@${chat['username'] ?? ''}';

    // Check if channel is in the monitored list
    final monitoredChannels = StorageService.getMonitoredChannels();
    final allChannels = [...defaultChannels, ...monitoredChannels];
    final isMonitored = allChannels.any(
      (c) => c == channelUsername || c == chat['id'].toString(),
    );
    if (!isMonitored) return;

    // Filter by trigger keywords (case insensitive)
    final lowerText = text.toLowerCase();
    final hasKeyword =
        _triggerKeywords.any((kw) => lowerText.contains(kw));

    // Track stats for all messages from monitored channels
    StorageService.updateChannelStats(
      username: channelUsername,
      wasRelevant: hasKeyword,
    );

    if (!hasKeyword) return;

    final signal = TelegramSignal(
      text: text,
      channelTitle: channelTitle,
      channelUsername: channelUsername,
      timestamp: DateTime.now(),
      messageId: (post['message_id'] as int?)?.toString() ?? '',
    );

    onSignalReceived?.call(signal);
  }

  /// Tests connection - returns bot username if token is valid
  Future<String?> testConnection() async {
    if (!isConfigured) return null;
    try {
      final uri = Uri.parse('$_baseUrl/bot$_botToken/getMe');
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      return result?['username'] as String?;
    } catch (_) {
      return null;
    }
  }
}
