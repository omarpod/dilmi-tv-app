/// news_screen.dart
/// ----------------
/// تعرض قائمة أخبار المباريات القادمة من الـ API، مع إمكانية إضافة أي خبر
/// للمفضلة (يظهر لاحقاً في شاشة المفضلة المستقلة).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/news_article.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiService.fetchNews();
  }

  Future<void> _reload() async {
    setState(() {
      _newsFuture = ApiService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<List<NewsArticle>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              // ListView (وليس Column) حتى يعمل RefreshIndicator بالسحب حتى مع الخطأ
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTextColors.secondary(context)),
                    ),
                  ),
                ),
              ],
            );
          }

          final newsList = snapshot.data ?? [];

          if (newsList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(context.tr('no_news'), style: TextStyle(color: AppTextColors.secondary(context))),
                  ),
                ),
              ],
            );
          }

          return Consumer<FavoritesService>(
            builder: (context, favorites, _) {
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  final article = newsList[index];
                  final isFavorite = favorites.isNewsFavorite(article.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (article.imageUrl != null)
                          Image.network(
                            article.imageUrl!,
                            height: 160,
                            fit: BoxFit.cover,
                            // في حال فشل تحميل الصورة، لا يتوقف التطبيق بل يعرض بديلاً
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 160,
                              color: AppTextColors.surface(context),
                              child: Icon(Icons.image_not_supported, color: AppTextColors.faint(context)),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTextColors.primary(context),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => favorites.toggleNewsFavorite(article.id),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? const Color(0xFFFF5A36) : AppTextColors.muted(context),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppTextColors.muted(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
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
