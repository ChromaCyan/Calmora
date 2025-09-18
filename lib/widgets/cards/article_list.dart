import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/config/global_loader.dart';

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

  Future<void> _loadUserId() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    print("🔵 User ID Loaded: $userId");

    if (userId != null) {
      setState(() {
        _patientId = userId;
      });

      print("🟡 Dispatching FetchRecommendedArticles event...");
      context.read<ArticleBloc>().add(FetchRecommendedArticles(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patientId == null) {
      return GlobalLoader.loader;
    }

    return SizedBox(
      height: 230,
      child: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return GlobalLoader.loader;
          } else if (state is ArticleError) {
            return RefreshIndicator(
              onRefresh: () async {
                if (_patientId != null) {
                  context
                      .read<ArticleBloc>()
                      .add(FetchRecommendedArticles(_patientId!));
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 230,
                  child: Center(
                    child: Text(
                      "Something went wrong. Pull down to retry.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            );
          } else if (state is ArticleLoaded) {
            final filteredArticles = state.articles.where((article) {
              return article.title
                  .toLowerCase()
                  .contains(widget.searchQuery.toLowerCase());
            }).toList();

            if (filteredArticles.isEmpty) {
              return const Center(child: Text('No matching articles found.'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: SizedBox(
                    width: 245,
                    child: ArticleCard(
                      articleId: article.id,
                      imageUrl: article.heroImage,
                      title: article.title,
                      publisher: 'By ${article.specialistName}',
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No articles found.'));
          }
        },
      ),
    );
  }
}
