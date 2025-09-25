import 'package:shared_preferences/shared_preferences.dart';
import '../keys/settings_keys.dart';

class SettingsManager {
  static Future<String> getSearchMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SettingsKeys.searchMode) ?? "press";
  }

  static Future<void> setSearchMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.searchMode, mode);
  }

  static Future<String> getCoverSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SettingsKeys.coverSize) ?? "M";
  }

  static Future<void> setCoverSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.coverSize, size);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SettingsKeys.recentSearches);
    await prefs.remove(SettingsKeys.cachedSummaries);
    await prefs.remove(SettingsKeys.coverMap);
  }
}
