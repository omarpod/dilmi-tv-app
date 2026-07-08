/// notification_service.dart
/// --------------------------
/// إشعارات محلية (Local Notifications) تُطلق من داخل التطبيق نفسه.
///
/// == الإصلاحات في هذه النسخة (كانت سبب عدم عمل الإشعارات سابقاً) ==
/// 1) أندرويد 13 (API 33) فما فوق يتطلب طلب صلاحية POST_NOTIFICATIONS
///    صراحة من المستخدم، وإلا تُرفض كل الإشعارات صامتة دون أي خطأ ظاهر.
/// 2) iOS يتطلب طلب صلاحية العرض (alert/badge/sound) بشكل صريح أيضاً.
/// 3) يُفضّل إنشاء "قناة الإشعارات" (Notification Channel) بشكل صريح على
///    أندرويد 8+ بدل تركها تُنشأ ضمنياً عند أول إشعار فقط، لضمان ظهورها
///    بشكل صحيح في إعدادات الهاتف من أول تشغيل.
///
/// == الخطوة التالية لجعلها تعمل تلقائياً عند بدء مباراة حقيقية ==
/// هذا الملف يوفر "آلية العرض" فقط. لتفعيلها تلقائياً عند اكتشاف أن
/// مباراة أصبحت status == 'live' من الـ API، تحتاج لاحقاً إما:
///   1) فحص دوري (polling) أثناء فتح التطبيق فقط (الأبسط)
///   2) ربط Django بخدمة Firebase Cloud Messaging لإشعارات Push حقيقية
///      تصل حتى لو كان التطبيق مغلقاً تماماً (الأقوى، لاحقاً)
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _matchesChannel = AndroidNotificationChannel(
    'dilmi_tv_matches',       // معرّف القناة
    'إشعارات المباريات',       // الاسم الذي يراه المستخدم في إعدادات هاتفه
    description: 'إشعارات عند بدء بث مباشر لمباراة مهمة',
    importance: Importance.high,
  );

  /// يجب استدعاؤها مرة واحدة فقط عند بدء التطبيق (من main.dart).
  /// تُرجع true إذا مُنحت صلاحية الإشعارات، و false إذا رفضها المستخدم.
  static Future<bool> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS: نطلب الصلاحيات هنا أيضاً (وليس فقط عبر أندرويد)
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // إنشاء قناة الإشعارات صراحة على أندرويد (بدون تأثير على iOS)
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_matchesChannel);

    // طلب صلاحية الإشعارات صراحة (إلزامي على أندرويد 13+، وإلا تُرفض
    // الإشعارات صامتة دون أي رسالة خطأ تشرح السبب)
    final granted = await androidPlugin?.requestNotificationsPermission();

    return granted ?? true; // على iOS الصلاحية تُطلب تلقائياً أعلاه
  }

  /// يعرض إشعاراً فورياً للمستخدم.
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _matchesChannel.id,
      _matchesChannel.name,
      channelDescription: _matchesChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // معرّف فريد للإشعار
        title,
        body,
        details,
      );
    } catch (e) {
      // لا نُسقط التطبيق أبداً بسبب فشل إشعار غير أساسي؛ فقط نسجّل الخطأ
      // أثناء التطوير حتى يسهل تتبعه.
      debugPrint('فشل عرض الإشعار: $e');
    }
  }

  /// مثال جاهز: إشعار خاص ببدء مباراة مباشرة.
  static Future<void> notifyMatchStarted({
    required String homeTeam,
    required String awayTeam,
  }) {
    return showNotification(
      title: '🔴 بث مباشر الآن',
      body: 'بدأت مباراة $homeTeam ضد $awayTeam، شاهدها الآن على Dilmi TV',
    );
  }
}
