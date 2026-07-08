/// channel.dart
/// ------------
/// يمثل هذا الـ class "قناة واحدة" قادمة من الـ API.
/// دور fromJson: تحويل البيانات القادمة كـ Map (من JSON) إلى كائن Dart منظم
/// وسهل الاستخدام في الواجهة، بدلاً من التعامل مع Map["key"] في كل مكان.
class Channel {
  final int id;
  final String name;
  final String? logoUrl;
  final String streamUrl;
  final String category;
  final bool isActive;

  Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.category,
    required this.isActive,
    this.logoUrl,
  });

  /// factory constructor: طريقة خاصة لبناء الكائن من بيانات JSON قادمة من Django
  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'] ?? '',
      // logo قد تكون null إذا لم يرفع المدير صورة بعد
      logoUrl: json['logo'],
      streamUrl: json['stream_url'] ?? '',
      category: json['category'] ?? 'sports',
      isActive: json['is_active'] ?? true,
    );
  }
}
