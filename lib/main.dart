/// main.dart
/// ---------
/// نقطة انطلاق التطبيق. هنا يبدأ كل شيء.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/favorites_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  // مطلوبة لأننا سنُنفّذ كوداً غير متزامن (async) قبل استدعاء runApp
  WidgetsFlutterBinding.ensureInitialized();

  // نُهيّئ خدمة الإشعارات مرة واحدة فقط عند بدء التطبيق
  await NotificationService.init();

  // نُحضّر الـ Providers ونحمّل تفضيلات المستخدم المحفوظة سابقاً (اللغة،
  // الوضع المظلم/الفاتح، المفضلة) قبل عرض أي واجهة، لتفادي "ومضة" قصيرة
  // بالإعدادات الافتراضية قبل ظهور الإعدادات الحقيقية للمستخدم.
  final localeProvider = LocaleProvider();
  final themeProvider = ThemeProvider();
  final favoritesService = FavoritesService();

  await Future.wait([
    localeProvider.loadSavedLocale(),
    themeProvider.loadSavedTheme(),
    favoritesService.loadFavorites(),
  ]);

  runApp(DilmiTvApp(
    localeProvider: localeProvider,
    themeProvider: themeProvider,
    favoritesService: favoritesService,
  ));
}

class DilmiTvApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final FavoritesService favoritesService;

  const DilmiTvApp({
    super.key,
    required this.localeProvider,
    required this.themeProvider,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: favoritesService),
      ],
      // Consumer2: يعيد بناء MaterialApp فقط عند تغيّر اللغة أو الوضع،
      // وهذا يكفي لأن باقي الشجرة تحتها تُعاد بناؤها معه تلقائياً.
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: 'Dilmi TV',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightThemeData,
            darkTheme: AppTheme.darkThemeData,
            themeMode: themeProvider.themeMode,

            // دعم اللغتين: العربية (تلقائياً RTL) والفرنسية (تلقائياً LTR)
            locale: localeProvider.locale,
            supportedLocales: const [Locale('ar'), Locale('fr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
