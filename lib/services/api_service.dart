/// api_service.dart
/// -----------------
/// هذا الملف هو "الجسر" الوحيد بين التطبيق وسيرفر Django.
/// كل الشاشات تستدعي الدوال هنا، ولا تتصل بالإنترنت مباشرة بنفسها.
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'server_settings.dart';
import '../models/channel.dart';
import '../models/news_article.dart';

class ApiService {
  /// دالة عامة مساعدة: تُنفّذ طلب GET وتتحقق من نجاحه، وتُرجع قائمة
  /// العناصر من مفتاح "results" (بسبب نظام التصفح/Pagination في Django REST).
  static Future<List<dynamic>> _getList(String endpoint) async {
    final baseUrl = await ServerSettings.getBaseUrl();
    final uri = Uri.parse('$baseUrl/$endpoint/');

    try {
      final response = await http.get(uri).timeout(
        // ملاحظة مهمة عن Render (الخطة المجانية):
        // السيرفر "ينام" تلقائياً بعد فترة عدم استخدام، وأول طلب بعد
        // النوم قد يستغرق حتى 50 ثانية لإيقاظه. لذلك جعلنا المهلة أطول
        // من المعتاد لتفادي ظهور خطأ خاطئ بأن "السيرفر لا يعمل".
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception(
            'استغرق السيرفر وقتاً طويلاً للرد.\n'
            'إذا كانت هذه أول مرة تفتح فيها التطبيق منذ فترة، فقد يكون '
            'سيرفر Render لا يزال "يستيقظ" من وضع النوم. حاول مرة أخرى '
            'خلال دقيقة.',
          );
        },
      );

      if (response.statusCode == 200) {
        // decode: تحويل نص JSON (بترميز utf8 لدعم العربية) إلى بيانات Dart
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        // Django REST Framework يُرجع الشكل: { count, next, previous, results }
        if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
          return decoded['results'] as List<dynamic>;
        }
        // احتياطاً، إذا كان الرد قائمة مباشرة بدون تصفح
        return decoded as List<dynamic>;
      } else {
        throw Exception('فشل الاتصال بالسيرفر: رمز الحالة ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
        'تعذر الوصول للسيرفر. تأكد من اتصال هاتفك بالإنترنت وحاول مرة أخرى.',
      );
    } on FormatException {
      throw Exception('وصل رد غير متوقع من السيرفر. حاول مرة أخرى لاحقاً.');
    }
  }

  /// يجلب قائمة القنوات المفعّلة من: /api/channels/
  static Future<List<dynamic>> fetchChannelsRaw() => _getList('channels');

  /// يجلب قائمة الأخبار المنشورة من: /api/news/
  static Future<List<dynamic>> fetchNewsRaw() => _getList('news');

  /// النسخة المُنسّقة (typed) التي تستخدمها الشاشات مباشرة
  static Future<List<Channel>> fetchChannels() async {
    final rawList = await fetchChannelsRaw();
    return rawList.map((item) => Channel.fromJson(item)).toList();
  }

  static Future<List<NewsArticle>> fetchNews() async {
    final rawList = await fetchNewsRaw();
    return rawList.map((item) => NewsArticle.fromJson(item)).toList();
  }
}
