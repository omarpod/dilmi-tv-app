/// contact_screen.dart
/// -------------------
/// شاشة بسيطة لمعلومات التواصل. عدّل البيانات أدناه بمعلوماتك الحقيقية.
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(context.tr('contact_us'))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ContactTile(icon: Icons.email_outlined, title: context.tr('email'), value: 'contact@dilmitv.example'),
            _ContactTile(icon: Icons.telegram, title: context.tr('telegram'), value: '@dilmitv'),
            _ContactTile(icon: Icons.facebook, title: context.tr('facebook'), value: 'facebook.com/dilmitv'),
            const SizedBox(height: 20),
            Text(
              context.tr('contact_message'),
              style: TextStyle(color: AppTextColors.muted(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTextColors.secondary(context)),
        title: Text(title, style: TextStyle(color: AppTextColors.secondary(context), fontSize: 12)),
        subtitle: Text(value, style: TextStyle(color: AppTextColors.primary(context), fontSize: 15)),
      ),
    );
  }
}
