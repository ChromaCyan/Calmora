import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/article/article.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;

  const ArticleDetailPage({Key? key, required this.articleId})
      : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Article? article;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    try {
      final fetchedArticle =
          await ApiRepository().getArticleById(widget.articleId);
      setState(() {
        article = fetchedArticle;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(article?.title ?? 'Article Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : article == null
                  ? Center(
                      child: Text(
                        'Article not found',
                        style: TextStyle(color: theme.colorScheme.onBackground),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              article!.heroImage,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, size: 50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Article Title
                          Text(
                            article!.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Specialist Name
                          Text(
                            'By ${article!.specialistName}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: article!.categories.map((category) {
                                String capitalizedCategory = category
                                    .split(' ')
                                    .map((word) => word[0].toUpperCase() + word.substring(1))
                                    .join(' ');
                                return Chip(
                                  label: Text(
                                    capitalizedCategory,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                );
                              }).toList(),
                            ),
                          ),
                          
                          Text(
                            article!.content,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
    );
  }
}
