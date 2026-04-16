import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static int _notificationId = 0;
  static bool _initialized = false;

  static const _channelId = 'coinsight_alerts';
  static const _channelName = 'CoinSight Alertovi';
  static const _channelDesc = 'Stop-loss, take-profit i signal alertovi';

  static Future<void> init() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> showStopLossAlert({
    required String symbol,
    required double price,
    required double pnlPercent,
  }) async {
    final sign = pnlPercent >= 0 ? '+' : '';
    await _show(
      title: '🛑 Stop-Loss hit: $symbol',
      body: 'Cijena: \$$price | P&L: $sign${pnlPercent.toStringAsFixed(1)}%',
      payload: 'sl:$symbol',
    );
  }

  static Future<void> showTakeProfitAlert({
    required String symbol,
    required double price,
    required double pnlPercent,
  }) async {
    await _show(
      title: '🎯 Take-Profit hit: $symbol',
      body: 'Cijena: \$$price | Profit: +${pnlPercent.toStringAsFixed(1)}%',
      payload: 'tp:$symbol',
    );
  }

  static Future<void> showInterestingSignal({
    required String symbol,
    required double score,
  }) async {
    await _show(
      title: '🚨 INTERESTING signal: $symbol',
      body: 'Confluence score: ${score.toStringAsFixed(1)}/6.0',
      payload: 'signal:$symbol',
    );
  }

  static Future<void> _show({
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
    );
    await _plugin.show(
      _notificationId++,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
