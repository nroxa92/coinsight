class TradeResult {
  final bool success;
  final String? orderId;
  final double? executedPrice;
  final double? executedQty;
  final double? totalUsdt;
  final String? errorMessage;

  const TradeResult({
    required this.success,
    this.orderId,
    this.executedPrice,
    this.executedQty,
    this.totalUsdt,
    this.errorMessage,
  });

  factory TradeResult.failure(String message) =>
      TradeResult(success: false, errorMessage: message);
}
