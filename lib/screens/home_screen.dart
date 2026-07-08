/// home_screen.dart
/// ----------------
/// الشاشة الرئيسية: تحتوي القائمة الجانبية (Drawer)، شريط تنقل سفلي
/// سريع (Bottom Navigation)، وخلفية متدرجة جميلة خلف كل المحتوى.
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
import 'channels_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // كل شاشة هنا مرة واحدة فقط في الذاكرة (وليست تُبنى من جديد كل تبديل)
  final List<Widget> _screens = const [
    ChannelsScreen(),
    NewsScreen(),
  ];

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? context.tr('live_tv') : context.tr('match_news')),
        ),
        drawer: AppDrawer(onSelectTab: _onSelectTab),
        // IndexedStack: يبقي كل الشاشات محمّلة في الخلفية، فقط يُظهر واحدة
        // في كل مرة. هذا يمنع إعادة تحميل البيانات من الـ API كل مرة تبدّل التبويب.
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onSelectTab,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.live_tv_outlined), label: context.tr('live_tv')),
            NavigationDestination(icon: const Icon(Icons.article_outlined), label: context.tr('match_news')),
          ],
        ),
      ),
    );
  }
}
