import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class ArticleDetailPage2 extends StatelessWidget {
  final String articleId;

  const ArticleDetailPage2({Key? key, required this.articleId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ArticleBloc>().add(FetchArticleById(articleId));

    return WillPopScope(
      // This listens for back button presses
      onWillPop: () async {
        final storage = FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        if (userId != null) {
          context.read<ArticleBloc>().add(FetchAllArticles());
        }
        return true;
      },

      child: Scaffold(
        appBar: UniversalAppBar(title: ""),
        body: BlocBuilder<ArticleBloc, ArticleState>(
          builder: (context, state) {
            if (state is ArticleLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ArticleError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            } else if (state is ArticleDetailLoaded) {
              return _buildArticleDetail(context, state.article);
            }
            return const Center(child: Text('Article not found'));
          },
        ),
      ),
    );
  }

  Widget _buildArticleDetail(BuildContext context, Article article) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final Map<String, Color> categoryColors = {
      "health": Colors.green,
      "social": Colors.blue,
      "relationships": Colors.pink,
      "growth": Colors.orange,
      "coping strategies": Colors.purple,
      "mental wellness": Colors.teal,
      "self-care": Colors.red,
    };

    double contentPadding = screenWidth > 600 ? 32.0 : 20.0;
    double titleFontSize = screenWidth > 600 ? 24.0 : 22.0;
    double bodyFontSize = screenWidth > 600 ? 20.0 : 18.0;
    double specialistFontSize = screenWidth > 600 ? 18.0 : 16.0;
    double maxContentWidth = 800.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    article.heroImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                article.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 10),
              Text(
                'By ${article.specialistName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: specialistFontSize,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Wrap(
                  spacing: screenWidth > 600 ? 12.0 : 8.0,
                  runSpacing: screenWidth > 600 ? 6.0 : 4.0,
                  children: article.categories.map((category) {
                    String capitalizedCategory = category
                        .split(' ')
                        .map(
                            (word) => word[0].toUpperCase() + word.substring(1))
                        .join(' ');

                    return Chip(
                      label: Text(
                        capitalizedCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: screenWidth > 600 ? 16.0 : 14.0,
                        ),
                      ),
                      backgroundColor:
                          categoryColors[category] ?? theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 16.0 : 12.0,
                        vertical: screenWidth > 600 ? 8.0 : 6.0,
                      ),
                    );
                  }).toList(),
                ),
              ),
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
    );
  }
}
