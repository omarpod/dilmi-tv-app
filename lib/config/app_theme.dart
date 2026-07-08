/// app_theme.dart
/// --------------
/// يجمع كل ألوان وتنسيقات التطبيق في مكان واحد لكلا الوضعين (مظلم/فاتح)،
/// حتى يبقى الشكل متناسقاً في كل الشاشات، ويسهل تغيير الهوية البصرية
/// لاحقاً من هنا فقط.
import 'package:flutter/material.dart';

class AppTheme {
  // اللون الأساسي لهوية Dilmi TV (يمكنك تغييره ليطابق شعارك)
  static const Color primary = Color(0xFF0F9D8C);   // أخضر مزرق (رياضي/تلفزيوني)
  static const Color primaryDark = Color(0xFF083C36);
  static const Color accent = Color(0xFFFF5A36);    // برتقالي للتفاصيل المهمة (مباشر الآن)

  // ============================================================================
  // الثيم المظلم (Dark Theme)
  // ============================================================================
  static ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryDark.withValues(alpha: 0.9),
        indicatorColor: primary.withValues(alpha: 0.4),
      ),
    );
  }

  // ============================================================================
  // الثيم الفاتح (Light Theme)
  // ============================================================================
  static ThemeData get lightThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF0B2B27),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: 0.15),
      ),
    );
  }

  /// الخلفية المتدرجة، تختلف حسب الوضع الحالي (مظلم/فاتح).
  static BoxDecoration backgroundGradientFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B2B27), // أعلى: أخضر داكن جداً
            Color(0xFF06181A), // وسط: أزرق داكن
            Color(0xFF030B0F), // أسفل: أسود مائل للأزرق
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      );
    }
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE9F7F4), // أعلى: أخضر فاتح جداً
          Color(0xFFF5FBFA), // وسط: أبيض مائل للأخضر
          Color(0xFFFFFFFF), // أسفل: أبيض
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }
}

/// عنصر واجهة بسيط: يضع الخلفية المتدرجة المناسبة للوضع الحالي خلف أي
/// شاشة تلفّها به (يقرأ الوضع تلقائياً من الثيم الفعّال، دون الحاجة لأي
/// إعداد إضافي في كل شاشة).
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: AppTheme.backgroundGradientFor(brightness),
      child: child,
    );
  }
}

/// ألوان نصوص تتكيف تلقائياً حسب الوضع الحالي (مظلم/فاتح)، بدل كتابة
/// Colors.white أو Colors.black يدوياً في كل شاشة (وهو ما كان سيكسر
/// الوضع الفاتح لو تُرك كما هو).
class AppTextColors {
  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0B2B27);

  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black45;

  static Color faint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black26;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04);
}
