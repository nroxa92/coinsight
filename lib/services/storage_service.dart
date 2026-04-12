import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const _settingsBox = 'settings';
  static const _watchlistBox = 'watchlist';
  static const _apiKeyField = 'anthropic_api_key';
  static const _watchlistIdsField = 'watchlist_ids';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_watchlistBox);
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
}
