import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/config/global_loader.dart';
import 'dart:ui';

class ArticleDetailPage extends StatelessWidget {
  final String articleId;

  const ArticleDetailPage({Key? key, required this.articleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    context.read<ArticleBloc>().add(FetchArticleById(articleId));

    return WillPopScope(
      onWillPop: () async {
        final storage = FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        if (userId != null) {
          context.read<ArticleBloc>().add(FetchRecommendedArticles(userId));
        }
        Navigator.pop(context);
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () async {
              final storage = FlutterSecureStorage();
              final userId = await storage.read(key: 'userId');

              if (userId != null) {
                context.read<ArticleBloc>().add(FetchAllArticles());
              }

              Navigator.pop(context);
            },
          ),
          // title: Text(
          //   "Specialist Details",
          //   style: TextStyle(
          //     color: Theme.of(context).colorScheme.onPrimaryContainer,
          //     fontWeight: FontWeight.w600,
          //     fontSize: 18,
          //   ),
          // ),
          // centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// Background image
            Image.asset(
              "images/login_bg_image.png",
              fit: BoxFit.cover,
            ),

            /// Frosted glass blur
            Container(
              color: theme.colorScheme.surface.withOpacity(0.6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: const SizedBox.expand(),
              ),
            ),
            BlocBuilder<ArticleBloc, ArticleState>(
            builder: (context, state) {
              if (state is ArticleLoading) {
                return GlobalLoader.loader;
              } else if (state is ArticleError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              } else if (state is ArticleDetailLoaded) {
                return _buildArticleDetail(context, state.article);
              }
              return const Center(child: Text('Article not found'));
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleDetail(BuildContext context, Article article) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // final Map<String, Color> categoryColors = {
    //   "health": Colors.green,
    //   "social": Colors.blue,
    //   "relationships": Colors.pink,
    //   "growth": Colors.orange,
    //   "coping strategies": Colors.purple,
    //   "mental wellness": Colors.teal,
    //   "self-care": Colors.red,
    // };

    double contentPadding = screenWidth > 600 ? 32.0 : 20.0;
    double titleFontSize = screenWidth > 600 ? 24.0 : 22.0;
    double bodyFontSize = screenWidth > 600 ? 20.0 : 18.0;
    double specialistFontSize = screenWidth > 600 ? 18.0 : 16.0;
    double maxContentWidth = 800.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.network(
                  article.heroImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 50),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'By ${article.specialistName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: specialistFontSize,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: article.categories.map((category) {
                            String capitalizedCategory = category
                                .split(' ')
                                .map((word) =>
                                    word[0].toUpperCase() + word.substring(1))
                                .join(' ');

                            return Chip(
                              label: Text(
                                capitalizedCategory,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                              backgroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(thickness: 1, height: 24),
                    Text(
                      article.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: bodyFontSize,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
