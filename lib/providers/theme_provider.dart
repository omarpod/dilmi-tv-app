/// theme_provider.dart
/// --------------------
/// يحتفظ بحالة الوضع الحالي (مظلم/فاتح)، ويحفظ اختيار المستخدم بشكل دائم.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _storageKey = 'is_dark_mode';

  // نبدأ بالوضع المظلم افتراضياً (هو التصميم الأساسي الذي بنيناه أولاً)
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// يجب استدعاؤها مرة واحدة عند بدء التطبيق لاسترجاع اختيار المستخدم السابق
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_storageKey);
    if (saved != null) {
      _isDarkMode = saved;
      notifyListeners();
    }
  }

  /// يبدّل الوضع الحالي ويحفظ الاختيار الجديد بشكل دائم.
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, isDark);
  }
}
