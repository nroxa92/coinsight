import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:coinsight/models/coin.dart';
import 'package:coinsight/services/coingecko_service.dart';
import 'package:coinsight/services/storage_service.dart';

class WatchlistProvider extends ChangeNotifier {
  final CoinGeckoService _service;

  List<Coin> _topCoins = [];
  List<Coin> _watchlistCoins = [];
  List<Coin> _newListings = [];
  late final Set<String> _watchlistIds;
  bool _isLoading = false;
  String? _error;
  Timer? _newListingsTimer;

  WatchlistProvider({CoinGeckoService? service})
      : _service = service ?? CoinGeckoService() {
    _watchlistIds = Set<String>.from(StorageService.getWatchlistIds());
  }

  List<Coin> get topCoins => _topCoins;
  List<Coin> get watchlistCoins => _watchlistCoins;
  List<Coin> get newListings => _newListings;
  Set<String> get watchlistIds => _watchlistIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isInWatchlist(String coinId) => _watchlistIds.contains(coinId);

  void toggleWatchlist(String coinId) {
    if (_watchlistIds.contains(coinId)) {
      _watchlistIds.remove(coinId);
    } else {
      _watchlistIds.add(coinId);
    }
    StorageService.saveWatchlistIds(_watchlistIds.toList());
    _updateWatchlistCoins();
    notifyListeners();
  }

  Future<void> fetchTopCoins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topCoins = await _service.getMarketData(perPage: 25);
      _updateWatchlistCoins();
    } on CoinGeckoException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Pull to refresh.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWatchlist() async {
    if (_watchlistIds.isEmpty) {
      _watchlistCoins = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coins = await _service.getMarketData(
        ids: _watchlistIds.toList(),
        perPage: _watchlistIds.length,
      );
      _topCoins = [
        ...coins,
        ..._topCoins.where((c) => !_watchlistIds.contains(c.id)),
      ];
      _updateWatchlistCoins();
    } on CoinGeckoException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Pull to refresh.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNewListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _newListings = await _service.getNewListings();
    } on CoinGeckoException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Pull to refresh.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void startNewListingsAutoRefresh() {
    _newListingsTimer?.cancel();
    _newListingsTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => fetchNewListings(),
    );
  }

  void stopNewListingsAutoRefresh() {
    _newListingsTimer?.cancel();
    _newListingsTimer = null;
  }

  void _updateWatchlistCoins() {
    _watchlistCoins =
        _topCoins.where((c) => _watchlistIds.contains(c.id)).toList();
  }

  @override
  void dispose() {
    _newListingsTimer?.cancel();
    super.dispose();
  }
}
