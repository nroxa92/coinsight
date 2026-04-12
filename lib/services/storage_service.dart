import 'package:hive_flutter/hive_flutter.dart';
import 'package:coinsight/models/analysis_log.dart';

class StorageService {
  static const _settingsBox = 'settings';
  static const _watchlistBox = 'watchlist';
  static const _analysisLogBox = 'analysis_logs';
  static const _apiKeyField = 'anthropic_api_key';
  static const _watchlistIdsField = 'watchlist_ids';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_watchlistBox);
    await Hive.openBox(_analysisLogBox);
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
}
