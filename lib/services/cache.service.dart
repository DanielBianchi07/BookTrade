// lib/services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  Future<void> cacheMessages(List<String> messageIds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cachedMessages', messageIds);
  }

  Future<List<String>?> getCachedMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cachedMessages');
  }
}
