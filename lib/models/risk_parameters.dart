class RiskParameters {
  final double maxTradeAmountUsdt;
  final int maxOpenPositions;
  final double stopLossPercent;
  final double takeProfitPercent;
  final bool autoTradeEnabled;
  final bool telegramNotifications;
  final int quietHoursStart;
  final int quietHoursEnd;

  const RiskParameters({
    this.maxTradeAmountUsdt = 10.0,
    this.maxOpenPositions = 3,
    this.stopLossPercent = 15.0,
    this.takeProfitPercent = 30.0,
    this.autoTradeEnabled = false,
    this.telegramNotifications = false,
    this.quietHoursStart = 23,
    this.quietHoursEnd = 7,
  });

  bool get isQuietHours {
    final hour = DateTime.now().hour;
    if (quietHoursStart > quietHoursEnd) {
      return hour >= quietHoursStart || hour < quietHoursEnd;
    }
    return hour >= quietHoursStart && hour < quietHoursEnd;
  }

  RiskParameters copyWith({
    double? maxTradeAmountUsdt,
    int? maxOpenPositions,
    double? stopLossPercent,
    double? takeProfitPercent,
    bool? autoTradeEnabled,
    bool? telegramNotifications,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) =>
      RiskParameters(
        maxTradeAmountUsdt: maxTradeAmountUsdt ?? this.maxTradeAmountUsdt,
        maxOpenPositions: maxOpenPositions ?? this.maxOpenPositions,
        stopLossPercent: stopLossPercent ?? this.stopLossPercent,
        takeProfitPercent: takeProfitPercent ?? this.takeProfitPercent,
        autoTradeEnabled: autoTradeEnabled ?? this.autoTradeEnabled,
        telegramNotifications:
            telegramNotifications ?? this.telegramNotifications,
        quietHoursStart: quietHoursStart ?? this.quietHoursStart,
        quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      );

  Map<String, dynamic> toMap() => {
        'max_trade_amount_usdt': maxTradeAmountUsdt,
        'max_open_positions': maxOpenPositions,
        'stop_loss_percent': stopLossPercent,
        'take_profit_percent': takeProfitPercent,
        'auto_trade_enabled': autoTradeEnabled,
        'telegram_notifications': telegramNotifications,
        'quiet_hours_start': quietHoursStart,
        'quiet_hours_end': quietHoursEnd,
      };

  factory RiskParameters.fromMap(Map<dynamic, dynamic> map) => RiskParameters(
        maxTradeAmountUsdt:
            (map['max_trade_amount_usdt'] as num?)?.toDouble() ?? 10.0,
        maxOpenPositions: (map['max_open_positions'] as int?) ?? 3,
        stopLossPercent:
            (map['stop_loss_percent'] as num?)?.toDouble() ?? 15.0,
        takeProfitPercent:
            (map['take_profit_percent'] as num?)?.toDouble() ?? 30.0,
        autoTradeEnabled: (map['auto_trade_enabled'] as bool?) ?? false,
        telegramNotifications:
            (map['telegram_notifications'] as bool?) ?? false,
        quietHoursStart: (map['quiet_hours_start'] as int?) ?? 23,
        quietHoursEnd: (map['quiet_hours_end'] as int?) ?? 7,
      );
}
