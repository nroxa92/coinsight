import 'package:coinsight/models/analysis_provider.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/services/claude_service.dart';
import 'package:coinsight/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/hive_test_setup.dart';
import '../../helpers/mock_http_client.dart';

void main() {
  setUpAll(() => registerFallbacks());
  setUp(() async => setUpHive());
  tearDown(() async => tearDownHive());

  AnalysisProvider buildProvider() {
    final claude = ClaudeService(
      client: HttpClientFactory.returning('{}'),
    );
    return AnalysisProvider(claudeService: claude);
  }

  test('starts empty with no messages and no error', () {
    final p = buildProvider();
    expect(p.messages, isEmpty);
    expect(p.error, isNull);
    expect(p.isLoading, false);
  });

  test('setApiKey persists to storage and toggles hasApiKey', () {
    final p = buildProvider();
    expect(p.hasApiKey, false);
    p.setApiKey('sk-ant-test');
    expect(p.hasApiKey, true);
    expect(StorageService.getApiKey(), 'sk-ant-test');
  });

  test('removeApiKey clears storage and hasApiKey', () {
    final p = buildProvider();
    p.setApiKey('sk-ant-test');
    p.removeApiKey();
    expect(p.hasApiKey, false);
    expect(StorageService.getApiKey(), isNull);
  });

  test('suggestionChips change per active tier', () async {
    final p = buildProvider();
    await StorageService.saveActiveTier(InvestmentTier.short);
    final shortChips = p.suggestionChips;
    await StorageService.saveActiveTier(InvestmentTier.mid);
    final midChips = p.suggestionChips;
    await StorageService.saveActiveTier(InvestmentTier.long);
    final longChips = p.suggestionChips;
    expect(shortChips, hasLength(3));
    expect(midChips, hasLength(4));
    expect(longChips, hasLength(4));
    expect(shortChips, isNot(equals(midChips)));
    expect(midChips, isNot(equals(longChips)));
  });

  test('clearChat empties messages and error, notifies', () {
    final p = buildProvider();
    var notified = 0;
    p.addListener(() => notified++);
    p.clearChat();
    expect(p.messages, isEmpty);
    expect(p.error, isNull);
    expect(notified, 1);
  });

  test('clearError notifies listeners', () {
    final p = buildProvider();
    var notified = 0;
    p.addListener(() => notified++);
    p.clearError();
    expect(p.error, isNull);
    expect(notified, 1);
  });

  test('pendingSignalsCount starts at 0', () {
    final p = buildProvider();
    expect(p.pendingSignalsCount, 0);
  });

  test('lastReport starts null and isGatheringIntelligence false', () {
    final p = buildProvider();
    expect(p.lastReport, isNull);
    expect(p.isGatheringIntelligence, false);
  });
}
