import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/tier_provider.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';

void main() {
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  test('initial tier is short when no saved state', () {
    final p = TierProvider();
    expect(p.activeTier, InvestmentTier.short);
    expect(p.isShort, true);
    expect(p.isMid, false);
    expect(p.isLong, false);
  });

  test('constructor reads persisted tier from storage', () async {
    await StorageService.saveActiveTier(InvestmentTier.mid);
    final p = TierProvider();
    expect(p.activeTier, InvestmentTier.mid);
    expect(p.isMid, true);
  });

  test('setTier updates state, persists, notifies', () async {
    final p = TierProvider();
    var notified = 0;
    p.addListener(() => notified++);

    await p.setTier(InvestmentTier.long);
    expect(p.activeTier, InvestmentTier.long);
    expect(p.isLong, true);
    expect(notified, 1);
    expect(StorageService.getActiveTier(), InvestmentTier.long);
  });

  test('setTier to current tier is no-op (no notify)', () async {
    final p = TierProvider();
    var notified = 0;
    p.addListener(() => notified++);
    await p.setTier(InvestmentTier.short);
    expect(notified, 0);
  });

  test('shortAsRiskParameters returns default when none saved', () {
    final p = TierProvider();
    final params = p.shortAsRiskParameters;
    expect(params.maxTradeAmountUsdt, greaterThan(0));
  });
}
