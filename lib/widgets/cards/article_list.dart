import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/article/article.dart';

class ArticleList extends StatefulWidget {
  final String searchQuery;

  const ArticleList({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Fetch patientId from secure storage
  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    setState(() {
      _patientId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If patientId is not loaded yet, show a loading indicator
    if (_patientId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 230,
      child: FutureBuilder<List<Article>>(
        future: ApiRepository().getRecommendedArticles(_patientId!), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          final articles = snapshot.data!;
          final filteredArticles = articles.where((article) {
            return article.title.toLowerCase().contains(widget.searchQuery.toLowerCase());
          }).toList();

          if (filteredArticles.isEmpty) {
            return const Center(child: Text('No matching articles found.'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredArticles.length,
            itemBuilder: (context, index) {
              final article = filteredArticles[index];
              return ArticleCard(
                articleId: article.id,
                imageUrl: article.heroImage,
                title: article.title,
                publisher: 'By ${article.specialistName}',
              );
            },
          );
        },
      ),
    );
  }
}
