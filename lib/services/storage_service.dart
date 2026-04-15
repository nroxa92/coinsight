import 'package:hive_flutter/hive_flutter.dart';
import 'package:coinsight/models/analysis_log.dart';
import 'package:coinsight/models/coin_position.dart';
import 'package:coinsight/models/risk_parameters.dart';

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
  static const _telegramTokenField = 'telegram_bot_token';
  static const _telegramChatIdField = 'telegram_chat_id';
  static const _riskParamsField = 'risk_parameters';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_watchlistBox);
    await Hive.openBox(_analysisLogBox);
    await Hive.openBox(_positionsBox);
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

  // Telegram credentials
  static String? getTelegramToken() {
    final box = Hive.box(_settingsBox);
    return box.get(_telegramTokenField) as String?;
  }

  static String? getTelegramChatId() {
    final box = Hive.box(_settingsBox);
    return box.get(_telegramChatIdField) as String?;
  }

  static Future<void> saveTelegramCredentials(
      String token, String chatId) async {
    final box = Hive.box(_settingsBox);
    await box.put(_telegramTokenField, token);
    await box.put(_telegramChatIdField, chatId);
  }

  static Future<void> deleteTelegramCredentials() async {
    final box = Hive.box(_settingsBox);
    await box.delete(_telegramTokenField);
    await box.delete(_telegramChatIdField);
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
}
