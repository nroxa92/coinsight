class CoinPosition {
  final String coinId;
  final String symbol;
  final String binanceSymbol;
  final double quantity;
  final double entryPrice;
  final double entryTotal;
  final DateTime entryTime;
  double? currentPrice;
  String? stopLossOrderId;

  CoinPosition({
    required this.coinId,
    required this.symbol,
    required this.binanceSymbol,
    required this.quantity,
    required this.entryPrice,
    required this.entryTotal,
    required this.entryTime,
    this.currentPrice,
    this.stopLossOrderId,
  });

  double get currentValue => quantity * (currentPrice ?? entryPrice);
  double get pnlAbsolute => currentValue - entryTotal;
  double get pnlPercent => entryTotal == 0 ? 0 : (pnlAbsolute / entryTotal) * 100;
  bool get isProfit => pnlAbsolute > 0;

  Map<String, dynamic> toMap() => {
        'coin_id': coinId,
        'symbol': symbol,
        'binance_symbol': binanceSymbol,
        'quantity': quantity,
        'entry_price': entryPrice,
        'entry_total': entryTotal,
        'entry_time': entryTime.toIso8601String(),
        'current_price': currentPrice,
        'stop_loss_order_id': stopLossOrderId,
      };

  factory CoinPosition.fromMap(Map<dynamic, dynamic> map) => CoinPosition(
        coinId: map['coin_id'] as String,
        symbol: map['symbol'] as String,
        binanceSymbol: map['binance_symbol'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        entryPrice: (map['entry_price'] as num).toDouble(),
        entryTotal: (map['entry_total'] as num).toDouble(),
        entryTime: DateTime.parse(map['entry_time'] as String),
        currentPrice: (map['current_price'] as num?)?.toDouble(),
        stopLossOrderId: map['stop_loss_order_id'] as String?,
      );
}
