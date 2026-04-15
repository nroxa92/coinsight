import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/models/trade_result.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/services/storage_service.dart';

typedef TelegramCommandHandler = Future<void> Function(
    String command, String argument);

class TelegramService {
  static const _baseUrl = 'https://api.telegram.org';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;
  String? _token;
  String? _chatId;
  int _lastUpdateId = 0;
  Timer? _pollTimer;
  TelegramCommandHandler? _onCommand;

  TelegramService({http.Client? client}) : _client = client ?? http.Client() {
    reloadCredentials();
  }

  void reloadCredentials() {
    _token = StorageService.getTelegramToken();
    _chatId = StorageService.getTelegramChatId();
  }

  bool get isConfigured =>
      (_token?.isNotEmpty ?? false) && (_chatId?.isNotEmpty ?? false);

  void setCommandHandler(TelegramCommandHandler handler) {
    _onCommand = handler;
  }

  Future<bool> sendMessage(String text) async {
    if (!isConfigured) return false;
    final uri = Uri.parse('$_baseUrl/bot$_token/sendMessage');
    try {
      final res = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'chat_id': _chatId,
              'text': text,
              'parse_mode': 'Markdown',
            }),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> sendInterestingSignal({
    required Coin coin,
    required String claudeRecommendation,
    required RiskParameters riskParams,
  }) async {
    final short = claudeRecommendation.length > 200
        ? '${claudeRecommendation.substring(0, 200)}...'
        : claudeRecommendation;
    final sym = coin.symbol.toUpperCase();
    final oneH = coin.priceChangePercentage1h?.toStringAsFixed(2) ?? 'n/a';
    final msg = '🚨 *CoinSight Signal*\n\n'
        '*INTERESTING* — $sym/USDT\n\n'
        '💰 Cijena: \$${coin.currentPrice.toStringAsFixed(6)}\n'
        '📈 1h: $oneH% | 24h: ${coin.priceChangePercentage24h.toStringAsFixed(2)}%\n'
        '📊 Volume: \$${coin.totalVolume.toStringAsFixed(0)}\n'
        '🏆 Rank: #${coin.marketCapRank}\n\n'
        '🧠 *Claude analiza:*\n$short\n\n'
        '⚡ Brzi odgovor:\n'
        '/buy_$sym — kupi ${riskParams.maxTradeAmountUsdt.toStringAsFixed(0)} USDT\n'
        '/skip_$sym — preskoči\n'
        '/analyze_$sym — puna analiza';
    await sendMessage(msg);
  }

  Future<void> sendTradeExecuted(
      CoinPosition position, TradeResult result) async {
    final msg = '✅ *Trade izvršen*\n\n'
        '${position.symbol}/USDT\n'
        'Cijena: \$${result.executedPrice?.toStringAsFixed(6) ?? '—'}\n'
        'Qty: ${result.executedQty?.toStringAsFixed(6) ?? '—'}\n'
        'Uloženo: \$${result.totalUsdt?.toStringAsFixed(2) ?? '—'}\n'
        'Order ID: `${result.orderId ?? '—'}`';
    await sendMessage(msg);
  }

  Future<void> sendStopLossTriggered(
      CoinPosition position, TradeResult result) async {
    final exit = result.totalUsdt ?? 0;
    final pnl = exit - position.entryTotal;
    final sign = pnl >= 0 ? '+' : '';
    final msg = '🛑 *Pozicija zatvorena*\n\n'
        '${position.symbol}/USDT\n'
        'Entry: \$${position.entryPrice.toStringAsFixed(6)}\n'
        'Exit: \$${result.executedPrice?.toStringAsFixed(6) ?? '—'}\n'
        'P&L: $sign\$${pnl.toStringAsFixed(2)}';
    await sendMessage(msg);
  }

  Future<void> sendDailySummary(
      List<CoinPosition> positions, List<AnalysisLog> logs) async {
    final totalInvested =
        positions.fold<double>(0, (sum, p) => sum + p.entryTotal);
    final totalValue =
        positions.fold<double>(0, (sum, p) => sum + p.currentValue);
    final pnl = totalValue - totalInvested;
    final interesting =
        logs.where((l) => l.recommendationType == 'INTERESTING').length;
    final msg = '📊 *Dnevni sažetak*\n\n'
        'Otvorene pozicije: ${positions.length}\n'
        'Uloženo: \$${totalInvested.toStringAsFixed(2)}\n'
        'Trenutna vrijednost: \$${totalValue.toStringAsFixed(2)}\n'
        'P&L: ${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}\n\n'
        'INTERESTING signali danas: $interesting';
    await sendMessage(msg);
  }

  void startPolling() {
    if (!isConfigured) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (!isConfigured) return;
    final uri = Uri.parse(
        '$_baseUrl/bot$_token/getUpdates?offset=${_lastUpdateId + 1}&timeout=0');
    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return;
      final data = json.decode(res.body) as Map<String, dynamic>;
      final updates = data['result'] as List<dynamic>? ?? [];
      for (final u in updates) {
        await _processUpdate(u as Map<String, dynamic>);
      }
    } catch (_) {
      // ignore polling errors (network, parse) — retry next tick
    }
  }

  Future<void> _processUpdate(Map<String, dynamic> update) async {
    _lastUpdateId = (update['update_id'] as int?) ?? _lastUpdateId;
    final message = update['message'] as Map<String, dynamic>?;
    if (message == null) return;

    final chat = message['chat'] as Map<String, dynamic>?;
    if (chat == null) return;
    if (chat['id'].toString() != _chatId) return;

    final text = (message['text'] as String?)?.trim();
    if (text == null || !text.startsWith('/')) return;

    final cmdText = text.substring(1);
    final underscore = cmdText.indexOf('_');
    String command;
    String argument = '';
    if (underscore > 0) {
      command = cmdText.substring(0, underscore);
      argument = cmdText.substring(underscore + 1);
    } else {
      command = cmdText;
    }

    if (_onCommand != null) {
      await _onCommand!(command, argument);
    }
  }
}
