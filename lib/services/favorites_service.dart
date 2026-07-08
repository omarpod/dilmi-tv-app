/// favorites_service.dart
/// -----------------------
/// يدير قائمة "المفضلة" للقنوات والأخبار، ويحفظها بشكل دائم على الهاتف
/// عبر SharedPreferences (كنص JSON بسيط: قائمة أرقام المعرّفات المفضّلة).
///
/// نستخدم ChangeNotifier حتى تتحدّث كل الشاشات (القنوات، الأخبار، شاشة
/// المفضلة نفسها) تلقائياً فور إضافة/إزالة عنصر من المفضلة في أي مكان،
/// دون الحاجة لإعادة تحميل الشاشة يدوياً.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const String _channelsKey = 'favorite_channel_ids';
  static const String _newsKey = 'favorite_news_ids';

  Set<int> _favoriteChannelIds = {};
  Set<int> _favoriteNewsIds = {};

  Set<int> get favoriteChannelIds => _favoriteChannelIds;
  Set<int> get favoriteNewsIds => _favoriteNewsIds;

  bool isChannelFavorite(int id) => _favoriteChannelIds.contains(id);
  bool isNewsFavorite(int id) => _favoriteNewsIds.contains(id);

  /// يجب استدعاؤها مرة واحدة عند بدء التطبيق لاسترجاع المفضلة المحفوظة سابقاً.
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteChannelIds = _decodeIds(prefs.getString(_channelsKey));
    _favoriteNewsIds = _decodeIds(prefs.getString(_newsKey));
    notifyListeners();
  }

  /// يضيف القناة للمفضلة إن لم تكن موجودة، أو يزيلها إن كانت موجودة بالفعل.
  Future<void> toggleChannelFavorite(int channelId) async {
    if (_favoriteChannelIds.contains(channelId)) {
      _favoriteChannelIds.remove(channelId);
    } else {
      _favoriteChannelIds.add(channelId);
    }
    notifyListeners();
    await _saveIds(_channelsKey, _favoriteChannelIds);
  }

  Future<void> toggleNewsFavorite(int newsId) async {
    if (_favoriteNewsIds.contains(newsId)) {
      _favoriteNewsIds.remove(newsId);
    } else {
      _favoriteNewsIds.add(newsId);
    }
    notifyListeners();
    await _saveIds(_newsKey, _favoriteNewsIds);
  }

  Set<int> _decodeIds(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded.map((e) => e as int).toSet();
  }

  Future<void> _saveIds(String key, Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(ids.toList()));
  }
}
