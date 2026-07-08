/// settings_screen.dart
/// --------------------
/// بعد تثبيت رابط السيرفر على Render، لم تعد هذه الشاشة بحاجة لحقل
/// إدخال IP يدوي. أصبحت الآن مخصصة لتفضيلات المستخدم: اللغة، الوضع
/// المظلم/الفاتح، وتجربة الإشعارات.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(context.tr('settings'))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ================= قسم اللغة =================
            Text(
              context.tr('language'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTextColors.primary(context)),
            ),
            const SizedBox(height: 10),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _LanguageOption(
                        label: 'العربية',
                        isSelected: localeProvider.locale.languageCode == 'ar',
                        onTap: () => localeProvider.setLocale('ar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LanguageOption(
                        label: 'Français',
                        isSelected: localeProvider.locale.languageCode == 'fr',
                        onTap: () => localeProvider.setLocale('fr'),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),
            Divider(color: AppTextColors.faint(context)),
            const SizedBox(height: 16),

            // ================= قسم الوضع المظلم =================
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr('dark_mode'),
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTextColors.primary(context)),
                  ),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: AppTextColors.secondary(context),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.setDarkMode(value),
                );
              },
            ),

            const SizedBox(height: 20),
            Divider(color: AppTextColors.faint(context)),
            const SizedBox(height: 16),

            // ================= قسم الإشعارات =================
            Text(
              context.tr('notifications_section'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTextColors.primary(context)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.notifyMatchStarted(
                  homeTeam: 'الفريق الأول',
                  awayTeam: 'الفريق الثاني',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('test_notification_sent'))),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(context.tr('send_test_notification')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.18) : AppTextColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTextColors.secondary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
