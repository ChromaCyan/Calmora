import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/config/global_loader.dart';
class ArticleList extends StatelessWidget {
  final String searchQuery;

  const ArticleList({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: FutureBuilder<List<Article>>(
        future: ApiRepository().getAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GlobalLoader.loader;
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          final articles = snapshot.data!;
          final filteredArticles = articles.where((article) {
            return article.title.toLowerCase().contains(searchQuery.toLowerCase());
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
                publisher: 'By ${article.specialistName}', // Direct access from model
              );
            },
          );
        },
      ),
    );
  }
}
