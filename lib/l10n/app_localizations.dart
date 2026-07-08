/// app_localizations.dart
/// ------------------------
/// يوفر extension بسيطاً على BuildContext حتى تستطيع أي شاشة كتابة:
///     Text(context.tr('settings'))
/// بدل التعامل المباشر مع خرائط الترجمة في كل مكان.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import 'app_strings.dart';

extension AppLocalizationExtension on BuildContext {
  /// يُرجع النص المترجم بناءً على اللغة الحالية المختارة في التطبيق.
  /// listen: false لأن اللغة تتغيّر من الشاشة العليا (main.dart) التي
  /// تُعيد بناء كل الشجرة أصلاً عند تغيّر اللغة، فلا حاجة للاستماع هنا مرة أخرى.
  String tr(String key) {
    final languageCode = Provider.of<LocaleProvider>(this, listen: false).locale.languageCode;
    return AppStrings.translations[languageCode]?[key] ??
        AppStrings.translations['ar']![key] ??
        key;
  }
}
