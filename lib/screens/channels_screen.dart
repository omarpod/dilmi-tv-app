/// channels_screen.dart
/// --------------------
/// تعرض قائمة القنوات القادمة من الـ API، وتفتح رابط البث عند الضغط عليها.
/// القنوات المفضّلة (المفضلة الذكية) تظهر دائماً في أعلى القائمة.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/channel.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  // late Future: سيُملأ لاحقاً في initState، لكنه "التزام" بأنه سيُملأ قبل الاستخدام
  late Future<List<Channel>> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _channelsFuture = ApiService.fetchChannels();
  }

  /// يُعاد استدعاؤها عند السحب للأسفل للتحديث (Pull to refresh)
  Future<void> _reload() async {
    setState(() {
      _channelsFuture = ApiService.fetchChannels();
    });
  }

  Future<void> _openStream(Channel channel) async {
    final uri = Uri.parse(channel.streamUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('stream_open_failed')}: ${channel.streamUrl}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<Channel>>(
        future: _channelsFuture,
        builder: (context, snapshot) {
          // حالة 1: لا تزال البيانات قيد التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // حالة 2: حدث خطأ (مثلاً السيرفر غير مُشغّل)
          if (snapshot.hasError) {
            return _ErrorView(message: snapshot.error.toString(), onRetry: _reload);
          }

          final channels = snapshot.data ?? [];

          // حالة 3: نجح الطلب لكن لا توجد قنوات مضافة بعد في لوحة التحكم
          if (channels.isEmpty) {
            return Center(
              child: Text(context.tr('no_channels'), style: TextStyle(color: AppTextColors.secondary(context))),
            );
          }

          // حالة 4: كل شيء تمام، نعرض القائمة على شكل بطاقات
          return Consumer<FavoritesService>(
            builder: (context, favorites, _) {
              // "المفضلة الذكية": نرتّب القنوات المفضّلة في الأعلى دائماً
              final sortedChannels = [...channels]..sort((a, b) {
                  final aFav = favorites.isChannelFavorite(a.id) ? 0 : 1;
                  final bFav = favorites.isChannelFavorite(b.id) ? 0 : 1;
                  return aFav.compareTo(bFav);
                });

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: sortedChannels.length,
                itemBuilder: (context, index) {
                  final channel = sortedChannels[index];
                  final isFavorite = favorites.isChannelFavorite(channel.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTextColors.surface(context),
                        backgroundImage: channel.logoUrl != null ? NetworkImage(channel.logoUrl!) : null,
                        child: channel.logoUrl == null
                            ? Icon(Icons.tv, color: AppTextColors.muted(context))
                            : null,
                      ),
                      title: Text(
                        channel.name,
                        style: TextStyle(color: AppTextColors.primary(context), fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(channel.category, style: TextStyle(color: AppTextColors.muted(context))),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? const Color(0xFFFF5A36) : AppTextColors.muted(context),
                            ),
                            onPressed: () => favorites.toggleChannelFavorite(channel.id),
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFFF5A36),
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      onTap: () => _openStream(channel),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// عنصر واجهة بسيط قابل لإعادة الاستخدام: يعرض رسالة خطأ مع زر "إعادة المحاولة"
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: AppTextColors.faint(context)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppTextColors.secondary(context))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
