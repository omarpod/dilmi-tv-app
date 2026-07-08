/// locale_provider.dart
/// ---------------------
/// يحتفظ باللغة الحالية للتطبيق (عربي/فرنسي)، ويحفظ اختيار المستخدم
/// بشكل دائم على الهاتف حتى يبقى نفس الاختيار بعد إغلاق التطبيق.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_language_code';

  // العربية هي اللغة الافتراضية عند أول تشغيل للتطبيق
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  /// يجب استدعاؤها مرة واحدة عند بدء التطبيق لاسترجاع آخر لغة اختارها المستخدم
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_storageKey);
    if (savedCode != null) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  /// يغيّر اللغة الحالية ويحفظ الاختيار الجديد بشكل دائم.
  /// [languageCode] مثال: 'ar' أو 'fr'
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
  }
}
