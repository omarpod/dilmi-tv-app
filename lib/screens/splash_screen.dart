/// splash_screen.dart
/// -------------------
/// شاشة ترحيب تظهر لثوانٍ عند فتح التطبيق، بتأثير تكبير وتلاشي (Fade + Scale)
/// للشعار، ثم تنتقل تلقائياً للشاشة الرئيسية. هذا يعطي انطباعاً احترافياً
/// أول ما يفتح المستخدم التطبيق (مشابه لتطبيقات مثل ياسين TV).
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController: "المايسترو" الذي يتحكم بتوقيت كل الحركات
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Curves.easeOutBack يعطي إحساس "ارتداد" خفيف يجعل ظهور الشعار حيوياً
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _controller.forward();

    // بعد انتهاء التأثير + مهلة قصيرة، ننتقل تلقائياً للشاشة الرئيسية
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, animation, __) => const HomeScreen(),
            // انتقال بتلاشي ناعم بين شاشة الترحيب والشاشة الرئيسية
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // نفرض الخلفية الداكنة دائماً هنا (بغض النظر عن اختيار المستخدم
      // للوضع الفاتح/المظلم) لأن هذه شاشة هوية العلامة التجارية، وتصميمها
      // ثابت دائماً كما في أغلب التطبيقات المشابهة.
      decoration: AppTheme.backgroundGradientFor(Brightness.dark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.live_tv, color: Colors.white, size: 54),
                ),
                const SizedBox(height: 22),
                Text(
                  context.tr('app_name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('app_slogan'),
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
