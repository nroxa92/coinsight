import 'package:flutter/foundation.dart';
import 'package:coinsight/services/claude_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/models/coin.dart';

class AnalysisProvider extends ChangeNotifier {
  final ClaudeService _claudeService;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  static const _systemPrompt = '''You are CoinSight AI, a cryptocurrency analysis assistant.
You help users understand crypto market trends, analyze coins, and explain blockchain concepts.
Keep responses concise and informative. Use bullet points for clarity when listing multiple items.
Always remind users that this is not financial advice and they should do their own research (DYOR).
If coin data is provided in the conversation, reference it in your analysis.''';

  AnalysisProvider({ClaudeService? claudeService})
      : _claudeService = claudeService ?? ClaudeService() {
    final savedKey = StorageService.getApiKey();
    if (savedKey != null && savedKey.isNotEmpty) {
      _claudeService.setApiKey(savedKey);
    }
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _claudeService.hasApiKey;

  void setApiKey(String key) {
    _claudeService.setApiKey(key);
    StorageService.saveApiKey(key);
    notifyListeners();
  }

  void removeApiKey() {
    _claudeService.setApiKey('');
    StorageService.deleteApiKey();
    notifyListeners();
  }

  Future<void> sendMessage(String text, {List<Coin>? watchlistCoins}) async {
    _error = null;

    final userContent = _buildUserMessage(text, watchlistCoins);
    _messages.add(ChatMessage(role: 'user', content: text));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _claudeService.sendMessage(
        userMessage: userContent,
        history: _messages.length > 1
            ? _messages.sublist(0, _messages.length - 1)
            : [],
        systemPrompt: _systemPrompt,
      );

      _messages.add(ChatMessage(role: 'assistant', content: response));
    } on ClaudeException catch (e) {
      _error = e.message;
      _messages.removeLast();
    } catch (e) {
      _error = 'Failed to get response. Check your connection.';
      _messages.removeLast();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _buildUserMessage(String text, List<Coin>? coins) {
    if (coins == null || coins.isEmpty) return text;

    final coinData = coins.map((c) {
      final change = c.priceChangePercentage24h >= 0 ? '+' : '';
      return '${c.name} (${c.symbol.toUpperCase()}): '
          '\$${c.currentPrice.toStringAsFixed(2)}, '
          '$change${c.priceChangePercentage24h.toStringAsFixed(2)}% 24h, '
          'MCap rank #${c.marketCapRank}';
    }).join('\n');

    return 'My watchlist:\n$coinData\n\nQuestion: $text';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    _error = null;
    notifyListeners();
  }
}
