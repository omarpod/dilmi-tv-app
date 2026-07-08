/// app_drawer.dart
/// ---------------
/// القائمة الجانبية الرئيسية للتطبيق، تحتوي روابط لكل الأقسام:
/// البث المباشر، أخبار المباريات، المفضلة، الإعدادات، اتصل بنا.
///
/// ملاحظة تصميم: خلفية القائمة داكنة دائماً (بلون الهوية) بغض النظر عن
/// الوضع الفاتح/المظلم المختار في التطبيق، تماماً كتطبيقات مشابهة، لذلك
/// نصوصها تبقى بيضاء ثابتة هنا فقط (وليس عبر AppTextColors).
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../screens/contact_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  /// دالة تُستدعى عند اختيار "البث المباشر" أو "أخبار المباريات"
  /// لتبديل التبويب في الشاشة الرئيسية دون فتح شاشة جديدة فوقها.
  final void Function(int tabIndex) onSelectTab;

  const AppDrawer({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryDark,
      child: SafeArea(
        child: Column(
          children: [
            // رأس القائمة: شعار واسم التطبيق
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.live_tv, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('app_name'),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    context.tr('app_slogan'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            _DrawerItem(
              icon: Icons.live_tv_outlined,
              label: context.tr('live_tv'),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة الجانبية أولاً
                onSelectTab(0);
              },
            ),
            _DrawerItem(
              icon: Icons.article_outlined,
              label: context.tr('match_news'),
              onTap: () {
                Navigator.pop(context);
                onSelectTab(1);
              },
            ),
            _DrawerItem(
              icon: Icons.favorite_outline,
              label: context.tr('favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            const Divider(color: Colors.white24, height: 24),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: context.tr('settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.mail_outline,
              label: context.tr('contact_us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactScreen()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${context.tr('version')} 1.0.0',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: color: AppTheme.primary.withOpacity(0.5),
    );
  }
}
