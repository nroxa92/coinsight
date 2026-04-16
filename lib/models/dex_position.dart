enum DexPositionStatus { open, closedManual, closedSL, closedTP }

class DexPosition {
  final String id;
  final String tokenSymbol;
  final String tokenName;
  final String contractAddress;
  final String chainId; // 'ethereum', 'bsc', 'solana', etc.
  final String dexName; // 'Uniswap', 'PancakeSwap', etc.
  final String walletAddress;
  final double entryPrice;
  final double quantity;
  final double entryAmountUsdt;
  final DateTime entryTime;
  double? currentPrice;
  double? stopLossPrice;
  double? takeProfitPrice;
  final DexPositionStatus status;

  DexPosition({
    required this.id,
    required this.tokenSymbol,
    required this.tokenName,
    required this.contractAddress,
    required this.chainId,
    required this.dexName,
    required this.walletAddress,
    required this.entryPrice,
    required this.quantity,
    required this.entryAmountUsdt,
    required this.entryTime,
    this.currentPrice,
    this.stopLossPrice,
    this.takeProfitPrice,
    this.status = DexPositionStatus.open,
  });

  // Computed
  double get currentValue => quantity * (currentPrice ?? entryPrice);
  double get pnlAbsolute => currentValue - entryAmountUsdt;
  double get pnlPercent =>
      entryAmountUsdt > 0 ? (pnlAbsolute / entryAmountUsdt) * 100 : 0;
  bool get isProfit => pnlAbsolute > 0;
  bool get isStopLossHit =>
      currentPrice != null &&
      stopLossPrice != null &&
      currentPrice! <= stopLossPrice!;
  bool get isTakeProfitHit =>
      currentPrice != null &&
      takeProfitPrice != null &&
      currentPrice! >= takeProfitPrice!;

  Map<String, dynamic> toMap() => {
        'id': id,
        'token_symbol': tokenSymbol,
        'token_name': tokenName,
        'contract_address': contractAddress,
        'chain_id': chainId,
        'dex_name': dexName,
        'wallet_address': walletAddress,
        'entry_price': entryPrice,
        'quantity': quantity,
        'entry_amount_usdt': entryAmountUsdt,
        'entry_time': entryTime.toIso8601String(),
        'current_price': currentPrice,
        'stop_loss_price': stopLossPrice,
        'take_profit_price': takeProfitPrice,
        'status': status.name,
      };

  factory DexPosition.fromMap(Map<dynamic, dynamic> map) => DexPosition(
        id: map['id'] as String,
        tokenSymbol: map['token_symbol'] as String,
        tokenName: map['token_name'] as String,
        contractAddress: map['contract_address'] as String,
        chainId: map['chain_id'] as String,
        dexName: map['dex_name'] as String,
        walletAddress: map['wallet_address'] as String? ?? '',
        entryPrice: (map['entry_price'] as num).toDouble(),
        quantity: (map['quantity'] as num).toDouble(),
        entryAmountUsdt: (map['entry_amount_usdt'] as num).toDouble(),
        entryTime: DateTime.parse(map['entry_time'] as String),
        currentPrice: (map['current_price'] as num?)?.toDouble(),
        stopLossPrice: (map['stop_loss_price'] as num?)?.toDouble(),
        takeProfitPrice: (map['take_profit_price'] as num?)?.toDouble(),
        status: DexPositionStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'open'),
          orElse: () => DexPositionStatus.open,
        ),
      );

  DexPosition copyWith({
    String? id,
    String? tokenSymbol,
    String? tokenName,
    String? contractAddress,
    String? chainId,
    String? dexName,
    String? walletAddress,
    double? entryPrice,
    double? quantity,
    double? entryAmountUsdt,
    DateTime? entryTime,
    double? currentPrice,
    double? stopLossPrice,
    double? takeProfitPrice,
    DexPositionStatus? status,
  }) =>
      DexPosition(
        id: id ?? this.id,
        tokenSymbol: tokenSymbol ?? this.tokenSymbol,
        tokenName: tokenName ?? this.tokenName,
        contractAddress: contractAddress ?? this.contractAddress,
        chainId: chainId ?? this.chainId,
        dexName: dexName ?? this.dexName,
        walletAddress: walletAddress ?? this.walletAddress,
        entryPrice: entryPrice ?? this.entryPrice,
        quantity: quantity ?? this.quantity,
        entryAmountUsdt: entryAmountUsdt ?? this.entryAmountUsdt,
        entryTime: entryTime ?? this.entryTime,
        currentPrice: currentPrice ?? this.currentPrice,
        stopLossPrice: stopLossPrice ?? this.stopLossPrice,
        takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
        status: status ?? this.status,
      );
}
