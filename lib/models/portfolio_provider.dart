import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/services/binance_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/services/trade_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final BinanceService _binance;
  final TradeService _trade;

  double _usdtBalance = 0;
  List<CoinPosition> _positions = [];
  bool _isLoading = false;
  String? _error;
  Timer? _priceTimer;

  PortfolioProvider({BinanceService? binance, TradeService? trade})
      : _binance = binance ?? BinanceService(),
        _trade = trade ?? TradeService() {
    _positions = StorageService.getPositions();
  }

  double get usdtBalance => _usdtBalance;
  List<CoinPosition> get positions => _positions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCredentials => _binance.hasCredentials;

  double get totalInvested =>
      _positions.fold(0, (sum, p) => sum + p.entryTotal);
  double get totalValue =>
      _positions.fold(0, (sum, p) => sum + p.currentValue);
  double get totalPnl => totalValue - totalInvested;
  double get totalPnlPercent =>
      totalInvested == 0 ? 0 : (totalPnl / totalInvested) * 100;

  void reloadCredentials() {
    _binance.reloadCredentials();
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _positions = StorageService.getPositions();

    if (_binance.hasCredentials) {
      try {
        _usdtBalance = await _binance.getUsdtBalance();
      } on BinanceException catch (e) {
        _error = e.message;
      }
    }

    await _refreshPrices();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refreshPrices() async {
    for (final pos in _positions) {
      try {
        final price = await _binance.getCurrentPrice(pos.binanceSymbol);
        if (price > 0) pos.currentPrice = price;
      } on BinanceException {
        continue;
      }
    }
  }

  void startAutoRefresh() {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _refreshPrices();
      notifyListeners();
    });
  }

  void stopAutoRefresh() {
    _priceTimer?.cancel();
    _priceTimer = null;
  }

  Future<bool> closePosition(CoinPosition position) async {
    final result = await _trade.closePosition(position);
    if (result.success) {
      _positions = StorageService.getPositions();
      await refresh();
      return true;
    }
    _error = result.errorMessage;
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }
}
