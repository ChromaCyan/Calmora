import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId;

  const ArticleDetailPage({Key? key, required this.articleId})
      : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? article;
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
      appBar: AppBar(title: Text(article?['title'] ?? 'Article Details')),
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
                          Image.network(
                            article!['heroImage'] ?? '',
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            article!['title'] ?? 'No Title',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By ${article!['specialistId']?['firstName'] ?? "Unknown"} ${article!['specialistId']?['lastName'] ?? ""}'
                                .trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            article!['content'] ?? 'No content available',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
    );
  }
}
