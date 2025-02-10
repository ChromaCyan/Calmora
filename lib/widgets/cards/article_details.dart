import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/appbar.dart';
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
    return Scaffold(
      appBar: UniversalAppBar(
        title: article?['title'] ??
            'Article Details',
        onBackPressed: () {
          Navigator.pop(context);
        },
        actions: [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : article == null
                  ? const Center(child: Text('Article not found'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            article!['heroImage'] ?? '',
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article!['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'By ${article!['specialistId']?['firstName'] ?? "Unknown"} ${article!['specialistId']?['lastName'] ?? ""}'
                                      .trim(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  article!['content'] ?? 'No content available',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
