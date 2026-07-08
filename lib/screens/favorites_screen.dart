/// favorites_screen.dart
/// ----------------------
/// تعرض القنوات والأخبار التي أضافها المستخدم للمفضلة، في تبويبين منفصلين.
/// تُبنى البيانات من نفس استدعاءات الـ API الموجودة أصلاً (ApiService)،
/// ثم تُصفّى محلياً حسب معرّفات المفضلة المحفوظة في FavoritesService.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/channel.dart';
import '../models/news_article.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<Channel>> _channelsFuture;
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _channelsFuture = ApiService.fetchChannels();
    _newsFuture = ApiService.fetchNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openStream(BuildContext context, Channel channel) async {
    final uri = Uri.parse(channel.streamUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('stream_open_failed')}: ${channel.streamUrl}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(context.tr('favorites')),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: const Icon(Icons.live_tv_outlined), text: context.tr('favorite_channels')),
              Tab(icon: const Icon(Icons.article_outlined), text: context.tr('favorite_news')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _FavoriteChannelsTab(channelsFuture: _channelsFuture, onOpenStream: _openStream),
            _FavoriteNewsTab(newsFuture: _newsFuture),
          ],
        ),
      ),
    );
  }
}

class _FavoriteChannelsTab extends StatelessWidget {
  final Future<List<Channel>> channelsFuture;
  final void Function(BuildContext, Channel) onOpenStream;

  const _FavoriteChannelsTab({required this.channelsFuture, required this.onOpenStream});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesService>(
      builder: (context, favorites, _) {
        return FutureBuilder<List<Channel>>(
          future: channelsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allChannels = snapshot.data ?? [];
            final favoriteChannels =
                allChannels.where((c) => favorites.isChannelFavorite(c.id)).toList();

            if (favoriteChannels.isEmpty) {
              return _EmptyFavoritesView(
                message: context.tr('no_favorite_channels'),
                hint: context.tr('add_to_favorites_hint'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteChannels.length,
              itemBuilder: (context, index) {
                final channel = favoriteChannels[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTextColors.surface(context),
                      backgroundImage: channel.logoUrl != null ? NetworkImage(channel.logoUrl!) : null,
                      child: channel.logoUrl == null
                          ? Icon(Icons.tv, color: AppTextColors.muted(context))
                          : null,
                    ),
                    title: Text(channel.name, style: TextStyle(color: AppTextColors.primary(context))),
                    subtitle: Text(channel.category, style: TextStyle(color: AppTextColors.muted(context))),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Color(0xFFFF5A36)),
                      onPressed: () => favorites.toggleChannelFavorite(channel.id),
                    ),
                    onTap: () => onOpenStream(context, channel),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FavoriteNewsTab extends StatelessWidget {
  final Future<List<NewsArticle>> newsFuture;

  const _FavoriteNewsTab({required this.newsFuture});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesService>(
      builder: (context, favorites, _) {
        return FutureBuilder<List<NewsArticle>>(
          future: newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allNews = snapshot.data ?? [];
            final favoriteNews = allNews.where((n) => favorites.isNewsFavorite(n.id)).toList();

            if (favoriteNews.isEmpty) {
              return _EmptyFavoritesView(
                message: context.tr('no_favorite_news'),
                hint: context.tr('add_to_favorites_hint'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoriteNews.length,
              itemBuilder: (context, index) {
                final article = favoriteNews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(article.title, style: TextStyle(color: AppTextColors.primary(context))),
                    subtitle: Text(
                      article.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTextColors.muted(context)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Color(0xFFFF5A36)),
                      onPressed: () => favorites.toggleNewsFavorite(article.id),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  final String message;
  final String hint;

  const _EmptyFavoritesView({required this.message, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: AppTextColors.faint(context)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppTextColors.secondary(context))),
            const SizedBox(height: 6),
            Text(hint, textAlign: TextAlign.center, style: TextStyle(color: AppTextColors.faint(context), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
