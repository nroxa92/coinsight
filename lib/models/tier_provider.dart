import 'package:flutter/foundation.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:coinsight/models/risk_parameters.dart';

class TierProvider extends ChangeNotifier {
  InvestmentTier _activeTier;

  TierProvider() : _activeTier = StorageService.getActiveTier();

  InvestmentTier get activeTier => _activeTier;
  bool get isShort => _activeTier == InvestmentTier.short;
  bool get isMid   => _activeTier == InvestmentTier.mid;
  bool get isLong  => _activeTier == InvestmentTier.long;

  Future<void> setTier(InvestmentTier tier) async {
    if (_activeTier == tier) return;
    _activeTier = tier;
    await StorageService.saveActiveTier(tier);
    notifyListeners();
  }

  /// Konvertira SHORT tier risk params u RiskParameters
  /// za kompatibilnost s postojecim TradeService
  RiskParameters get shortAsRiskParameters =>
      StorageService.getRiskParameters();
}
