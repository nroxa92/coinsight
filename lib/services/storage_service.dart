import 'package:hive_flutter/hive_flutter.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/monitored_channel.dart';
import 'package:coinsight/models/risk_parameters.dart';
import 'package:coinsight/models/investment_tier.dart';
import 'package:coinsight/models/mid_term_project.dart';
import 'package:coinsight/models/long_term_holding.dart';
import 'package:coinsight/models/dex_position.dart';
import 'package:coinsight/models/closed_trade.dart';

class StorageService {
  static const _settingsBox = 'settings';
  static const _watchlistBox = 'watchlist';
  static const _analysisLogBox = 'analysis_logs';
  static const _positionsBox = 'positions';
  static const _apiKeyField = 'anthropic_api_key';
  static const _watchlistIdsField = 'watchlist_ids';
  static const _binanceApiKeyField = 'binance_api_key';
  static const _binanceSecretField = 'binance_secret';
  static const _binanceTestnetField = 'binance_testnet';
  static const _telegramMonitorTokenField = 'telegram_monitor_token';
  static const _monitoredChannelsField = 'monitored_channels';
  static const _monitoredChannelsDetailBox = 'monitored_channels_detail';
  static const _riskParamsField = 'risk_parameters';
  static const _activeTierField = 'active_investment_tier';
  static const _midProjectsBox = 'mid_term_projects';
  static const _longHoldingsBox = 'long_term_holdings';
  static const _githubTokenField = 'github_personal_token';
  static const _dexPositionsBox = 'dex_positions';
  static const _walletAddressField = 'wallet_address';
  static const _closedTradesBox = 'closed_trades';
  static const _walletConnectProjectIdField = 'wc_project_id';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_watchlistBox);
    await Hive.openBox(_analysisLogBox);
    await Hive.openBox(_positionsBox);
    await Hive.openBox(_monitoredChannelsDetailBox);
    await Hive.openBox(_midProjectsBox);
    await Hive.openBox(_longHoldingsBox);
    await Hive.openBox(_dexPositionsBox);
    await Hive.openBox(_closedTradesBox);
  }

  // API Key
  static String? getApiKey() {
    final box = Hive.box(_settingsBox);
    return box.get(_apiKeyField) as String?;
  }

  static Future<void> saveApiKey(String key) async {
    final box = Hive.box(_settingsBox);
    await box.put(_apiKeyField, key);
  }

  static Future<void> deleteApiKey() async {
    final box = Hive.box(_settingsBox);
    await box.delete(_apiKeyField);
  }

  // Watchlist
  static List<String> getWatchlistIds() {
    final box = Hive.box(_watchlistBox);
    final ids = box.get(_watchlistIdsField);
    if (ids == null) return ['bitcoin', 'ethereum', 'solana'];
    return List<String>.from(ids as List);
  }

  static Future<void> saveWatchlistIds(List<String> ids) async {
    final box = Hive.box(_watchlistBox);
    await box.put(_watchlistIdsField, ids);
  }

  // Analysis Logs
  static Future<void> saveAnalysisLog(AnalysisLog log) async {
    final box = Hive.box(_analysisLogBox);
    await box.add(log.toMap());
  }

  static List<AnalysisLog> getAnalysisLogs() {
    final box = Hive.box(_analysisLogBox);
    return box.values
        .map((item) => AnalysisLog.fromMap(item as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Binance credentials
  static String? getBinanceApiKey() {
    final box = Hive.box(_settingsBox);
    return box.get(_binanceApiKeyField) as String?;
  }

  static String? getBinanceSecret() {
    final box = Hive.box(_settingsBox);
    return box.get(_binanceSecretField) as String?;
  }

  static bool getBinanceTestnet() {
    final box = Hive.box(_settingsBox);
    return box.get(_binanceTestnetField) as bool? ?? true;
  }

  static Future<void> saveBinanceCredentials(
      String apiKey, String secret) async {
    final box = Hive.box(_settingsBox);
    await box.put(_binanceApiKeyField, apiKey);
    await box.put(_binanceSecretField, secret);
  }

  static Future<void> deleteBinanceCredentials() async {
    final box = Hive.box(_settingsBox);
    await box.delete(_binanceApiKeyField);
    await box.delete(_binanceSecretField);
  }

  static Future<void> setBinanceTestnet(bool value) async {
    final box = Hive.box(_settingsBox);
    await box.put(_binanceTestnetField, value);
  }

  // Telegram Monitor
  static String? getTelegramMonitorToken() {
    final box = Hive.box(_settingsBox);
    return box.get(_telegramMonitorTokenField) as String?;
  }

  static Future<void> saveTelegramMonitorToken(String token) async {
    final box = Hive.box(_settingsBox);
    await box.put(_telegramMonitorTokenField, token);
  }

  static Future<void> deleteTelegramMonitorToken() async {
    final box = Hive.box(_settingsBox);
    await box.delete(_telegramMonitorTokenField);
  }

  static List<String> getMonitoredChannels() {
    final box = Hive.box(_settingsBox);
    final channels = box.get(_monitoredChannelsField);
    if (channels == null) return [];
    return List<String>.from(channels as List);
  }

  static Future<void> saveMonitoredChannels(List<String> channels) async {
    final box = Hive.box(_settingsBox);
    await box.put(_monitoredChannelsField, channels);
  }

  // Risk Parameters
  static RiskParameters getRiskParameters() {
    final box = Hive.box(_settingsBox);
    final data = box.get(_riskParamsField);
    if (data == null) return const RiskParameters();
    return RiskParameters.fromMap(data as Map<dynamic, dynamic>);
  }

  static Future<void> saveRiskParameters(RiskParameters params) async {
    final box = Hive.box(_settingsBox);
    await box.put(_riskParamsField, params.toMap());
  }

  // Positions (keyed by coinId)
  static Future<void> savePosition(CoinPosition position) async {
    final box = Hive.box(_positionsBox);
    await box.put(position.coinId, position.toMap());
  }

  static Future<void> removePosition(String coinId) async {
    final box = Hive.box(_positionsBox);
    await box.delete(coinId);
  }

  static List<CoinPosition> getPositions() {
    final box = Hive.box(_positionsBox);
    return box.values
        .map((item) => CoinPosition.fromMap(item as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.entryTime.compareTo(a.entryTime));
  }

  // Monitored Channels Detail
  static List<MonitoredChannel> getMonitoredChannelsDetail() {
    final box = Hive.box(_monitoredChannelsDetailBox);
    return box.values
        .map((item) =>
            MonitoredChannel.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  static Future<void> saveMonitoredChannel(MonitoredChannel channel) async {
    final box = Hive.box(_monitoredChannelsDetailBox);
    await box.put(channel.username, channel.toMap());
  }

  static Future<void> updateChannelStats({
    required String username,
    required bool wasRelevant,
  }) async {
    final box = Hive.box(_monitoredChannelsDetailBox);
    final existing = box.get(username);
    if (existing == null) {
      // Create new entry
      final channel = MonitoredChannel(
        username: username,
        displayName: username,
        signalsReceived: 1,
        signalsRelevant: wasRelevant ? 1 : 0,
        lastSignal: wasRelevant ? DateTime.now() : null,
      );
      await box.put(username, channel.toMap());
    } else {
      final channel =
          MonitoredChannel.fromMap(existing as Map<dynamic, dynamic>);
      final updated = channel.copyWith(
        signalsReceived: channel.signalsReceived + 1,
        signalsRelevant:
            wasRelevant ? channel.signalsRelevant + 1 : null,
        lastSignal: wasRelevant ? DateTime.now() : null,
      );
      await box.put(username, updated.toMap());
    }
  }

  static Future<void> removeMonitoredChannel(String username) async {
    final box = Hive.box(_monitoredChannelsDetailBox);
    await box.delete(username);
    // Also remove from custom channels list
    final channels = getMonitoredChannels();
    channels.remove(username);
    await saveMonitoredChannels(channels);
  }

  static Future<void> toggleChannelActive(
      String username, bool active) async {
    final box = Hive.box(_monitoredChannelsDetailBox);
    final existing = box.get(username);
    if (existing == null) return;
    final channel =
        MonitoredChannel.fromMap(existing as Map<dynamic, dynamic>);
    await box.put(username, channel.copyWith(isActive: active).toMap());
  }

  // Clear analysis logs
  static Future<void> clearAnalysisLogs() async {
    final box = Hive.box(_analysisLogBox);
    await box.clear();
  }

  // Full reset
  static Future<void> resetAll() async {
    await Hive.box(_settingsBox).clear();
    await Hive.box(_watchlistBox).clear();
    await Hive.box(_analysisLogBox).clear();
    await Hive.box(_positionsBox).clear();
    await Hive.box(_monitoredChannelsDetailBox).clear();
    await Hive.box(_midProjectsBox).clear();
    await Hive.box(_longHoldingsBox).clear();
    await Hive.box(_dexPositionsBox).clear();
    await Hive.box(_closedTradesBox).clear();
  }

  // ─── Active Tier ─────────────────────────────────
  static InvestmentTier getActiveTier() {
    final box = Hive.box(_settingsBox);
    final stored = box.get(_activeTierField) as String?;
    switch (stored) {
      case 'mid':  return InvestmentTier.mid;
      case 'long': return InvestmentTier.long;
      default:     return InvestmentTier.short;
    }
  }

  static Future<void> saveActiveTier(InvestmentTier tier) async {
    final box = Hive.box(_settingsBox);
    await box.put(_activeTierField, tier.name);
  }

  // ─── GitHub Token ─────────────────────────────────
  static String? getGitHubToken() {
    final box = Hive.box(_settingsBox);
    return box.get(_githubTokenField) as String?;
  }

  static Future<void> saveGitHubToken(String token) async {
    await Hive.box(_settingsBox).put(_githubTokenField, token);
  }

  static Future<void> deleteGitHubToken() async {
    await Hive.box(_settingsBox).delete(_githubTokenField);
  }

  // ─── MID Term Projects ────────────────────────────
  static List<MidTermProject> getMidProjects() {
    final box = Hive.box(_midProjectsBox);
    return box.values
        .map((v) => MidTermProject.fromMap(v as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.discoveredAt.compareTo(a.discoveredAt));
  }

  static Future<void> saveMidProject(MidTermProject project) async {
    final box = Hive.box(_midProjectsBox);
    await box.put(project.id, project.toMap());
  }

  static Future<void> deleteMidProject(String id) async {
    await Hive.box(_midProjectsBox).delete(id);
  }

  static Future<void> addMidNote(String projectId, MidTermNote note) async {
    final box = Hive.box(_midProjectsBox);
    final existing = box.get(projectId);
    if (existing == null) return;
    final project = MidTermProject.fromMap(existing as Map<dynamic, dynamic>);
    final updated = project.copyWith(
      notes: [...project.notes, note],
    );
    await box.put(projectId, updated.toMap());
  }

  // ─── LONG Term Holdings ───────────────────────────
  static List<LongTermHolding> getLongHoldings() {
    final box = Hive.box(_longHoldingsBox);
    return box.values
        .map((v) => LongTermHolding.fromMap(v as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.firstResearchDate.compareTo(a.firstResearchDate));
  }

  static Future<void> saveLongHolding(LongTermHolding holding) async {
    await Hive.box(_longHoldingsBox).put(holding.id, holding.toMap());
  }

  static Future<void> deleteLongHolding(String id) async {
    await Hive.box(_longHoldingsBox).delete(id);
  }

  static Future<void> addLongPurchase(
      String holdingId, LongTermPurchase purchase) async {
    final box = Hive.box(_longHoldingsBox);
    final existing = box.get(holdingId);
    if (existing == null) return;
    final holding = LongTermHolding.fromMap(existing as Map<dynamic, dynamic>);
    final updated = holding.copyWith(
      purchases: [...holding.purchases, purchase],
    );
    await box.put(holdingId, updated.toMap());
  }

  // ─── Tier Risk Parameters ──────────────────────────
  static const _tierRiskParamsField = 'tier_risk_parameters';

  static Map<String, dynamic> getTierRiskParameters() {
    final box = Hive.box(_settingsBox);
    final data = box.get(_tierRiskParamsField);
    if (data == null) return {};
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<void> saveTierRiskParameters(
      Map<String, dynamic> params) async {
    final box = Hive.box(_settingsBox);
    await box.put(_tierRiskParamsField, params);
  }

  static Future<void> addLongNote(
      String holdingId, LongTermNote note) async {
    final box = Hive.box(_longHoldingsBox);
    final existing = box.get(holdingId);
    if (existing == null) return;
    final holding = LongTermHolding.fromMap(existing as Map<dynamic, dynamic>);
    final updated = holding.copyWith(
      notes: [...holding.notes, note],
    );
    await box.put(holdingId, updated.toMap());
  }

  // ─── DEX Positions ────────────────────────────────
  static List<DexPosition> getDexPositions() {
    final box = Hive.box(_dexPositionsBox);
    return box.values
        .map((item) => DexPosition.fromMap(item as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.entryTime.compareTo(a.entryTime));
  }

  static Future<void> saveDexPosition(DexPosition position) async {
    final box = Hive.box(_dexPositionsBox);
    await box.put(position.id, position.toMap());
  }

  static Future<void> deleteDexPosition(String id) async {
    await Hive.box(_dexPositionsBox).delete(id);
  }

  // ─── Wallet Address ───────────────────────────────
  static String? getWalletAddress() {
    final box = Hive.box(_settingsBox);
    return box.get(_walletAddressField) as String?;
  }

  static Future<void> saveWalletAddress(String address) async {
    final box = Hive.box(_settingsBox);
    await box.put(_walletAddressField, address);
  }

  static Future<void> deleteWalletAddress() async {
    final box = Hive.box(_settingsBox);
    await box.delete(_walletAddressField);
  }

  // ─── WalletConnect Project ID ─────────────────────
  static String? getWalletConnectProjectId() {
    final box = Hive.box(_settingsBox);
    return box.get(_walletConnectProjectIdField) as String?;
  }

  static Future<void> saveWalletConnectProjectId(String id) async {
    await Hive.box(_settingsBox).put(_walletConnectProjectIdField, id);
  }

  static Future<void> deleteWalletConnectProjectId() async {
    await Hive.box(_settingsBox).delete(_walletConnectProjectIdField);
  }

  // ─── Closed Trades ───────────────────────────────
  static List<ClosedTrade> getClosedTrades() {
    final box = Hive.box(_closedTradesBox);
    return box.values
        .map((v) => ClosedTrade.fromMap(v as Map<dynamic, dynamic>))
        .toList()
      ..sort((a, b) => b.closedAt.compareTo(a.closedAt));
  }

  static Future<void> saveClosedTrade(ClosedTrade trade) async {
    await Hive.box(_closedTradesBox).put(trade.id, trade.toMap());
  }

  static List<ClosedTrade> getClosedTradesByTier(InvestmentTier tier) {
    return getClosedTrades()
        .where((t) => t.tier == tier)
        .toList();
  }

  static Future<void> clearClosedTrades() async {
    await Hive.box(_closedTradesBox).clear();
  }
}
