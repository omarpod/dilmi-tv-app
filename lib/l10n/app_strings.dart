/// app_strings.dart
/// -----------------
/// نظام ترجمة بسيط: كل النصوص التي تظهر للمستخدم موجودة هنا في مكان واحد،
/// بدل نظام flutter's ARB/gen-l10n المعقّد (الذي يحتاج خطوة بناء إضافية).
///
/// طريقة الإضافة لأي شاشة جديدة مستقبلاً: أضف "مفتاحاً" جديداً هنا بنفس
/// الاسم في كلا اللغتين، ثم استخدمه في الواجهة عبر: context.tr('key').
library;

class AppStrings {
  static const Map<String, Map<String, String>> translations = {
    'ar': {
      'app_name': 'Dilmi TV',
      'app_slogan': 'قنواتك الرياضية في مكان واحد',
      'live_tv': 'البث المباشر',
      'match_news': 'أخبار المباريات',
      'settings': 'الإعدادات',
      'contact_us': 'اتصل بنا',
      'favorites': 'المفضلة',
      'version': 'الإصدار',
      // شاشة القنوات
      'no_channels': 'لا توجد قنوات مضافة بعد',
      'retry': 'إعادة المحاولة',
      'stream_open_failed': 'تعذر فتح رابط البث',
      // شاشة الأخبار
      'no_news': 'لا توجد أخبار منشورة بعد',
      // شاشة المفضلة
      'favorite_channels': 'القنوات المفضّلة',
      'favorite_news': 'الأخبار المفضّلة',
      'no_favorite_channels': 'لم تُضِف أي قناة إلى المفضلة بعد',
      'no_favorite_news': 'لم تُضِف أي خبر إلى المفضلة بعد',
      'add_to_favorites_hint': 'اضغط على أيقونة القلب لإضافة عنصر للمفضلة',
      // شاشة الإعدادات
      'language': 'اللغة',
      'dark_mode': 'الوضع المظلم',
      'notifications_section': 'الإشعارات',
      'send_test_notification': 'إرسال إشعار تجريبي',
      'notifications_permission_needed': 'يجب السماح بالإشعارات من إعدادات الهاتف أولاً',
      'test_notification_sent': 'تم إرسال الإشعار التجريبي',
      // اتصل بنا
      'contact_message': 'يسعدنا استقبال ملاحظاتكم واقتراحاتكم لتطوير التطبيق.',
      'email': 'البريد الإلكتروني',
      'telegram': 'تيليجرام',
      'facebook': 'فيسبوك',
    },
    'fr': {
      'app_name': 'Dilmi TV',
      'app_slogan': 'Toutes vos chaînes sportives au même endroit',
      'live_tv': 'Direct',
      'match_news': 'Actualités des matchs',
      'settings': 'Paramètres',
      'contact_us': 'Contactez-nous',
      'favorites': 'Favoris',
      'version': 'Version',
      'no_channels': 'Aucune chaîne ajoutée pour le moment',
      'retry': 'Réessayer',
      'stream_open_failed': "Impossible d'ouvrir le lien du direct",
      'no_news': 'Aucune actualité publiée pour le moment',
      'favorite_channels': 'Chaînes favorites',
      'favorite_news': 'Actualités favorites',
      'no_favorite_channels': "Vous n'avez ajouté aucune chaîne aux favoris",
      'no_favorite_news': "Vous n'avez ajouté aucune actualité aux favoris",
      'add_to_favorites_hint': "Appuyez sur le cœur pour ajouter aux favoris",
      'language': 'Langue',
      'dark_mode': 'Mode sombre',
      'notifications_section': 'Notifications',
      'send_test_notification': 'Envoyer une notification test',
      'notifications_permission_needed': "Veuillez autoriser les notifications dans les paramètres du téléphone",
      'test_notification_sent': 'Notification test envoyée',
      'contact_message': 'Nous sommes heureux de recevoir vos remarques et suggestions.',
      'email': 'E-mail',
      'telegram': 'Telegram',
      'facebook': 'Facebook',
    },
  };
}
